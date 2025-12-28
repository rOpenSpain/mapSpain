esp_get_tiles2 <- function(
  x,
  type = "IDErioja",
  zoom = NULL,
  zoommin = 0,
  crop = TRUE,
  res = 512,
  bbox_expand = 0.05,
  transparent = TRUE,
  mask = FALSE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  options = NULL
) {
  x <- validate_non_empty_arg(x)

  # Only sf and sfc allowed

  if (!any(inherits(x, "sf"), inherits(x, "sfc"))) {
    cli::cli_abort(
      paste0(
        "{.arg x} should be an {.cls sf} ",
        "or {.cls sfc} object, not {.obj_type_friendly {x}}."
      )
    )
  }

  geom <- sf::st_geometry(x)

  # Validate
  prov_list <- validate_provider(type)

  # Add options
  prov_list <- modify_provider_list(prov_list, options)

  # Extension
  prov_ext <- get_tile_ext(prov_list)
  valid_ext <- c("png", "jpeg", "jpg", "tiff", "geotiff")

  prov_ext <- match_arg_pretty(prov_ext, valid_ext)

  # Get crs of Tile
  prov_crs <- get_tile_crs(prov_list)

  # Type of provider
  prov_type <- guess_provider_type(prov_list)

  # On WMS add here the target resolution
  if (prov_type == "WMS") {
    prov_list$width <- res
    prov_list$height <- res
  }

  # Mix info of provider and geom
  zoom <- ensure_null(zoom)

  # Single point would be buffered
  if (all(length(geom) == 1, sf::st_geometry_type(geom) == "POINT")) {
    geom_buff <- sf::st_buffer(sf::st_transform(geom, 3857), 50)
    geom <- sf::st_transform(geom_buff, sf::st_crs(geom))

    # Modify some defaults
    crop <- FALSE
    if (is.null(zoom)) {
      zoom <- 18
      make_msg(
        "info",
        prov_type == "WMTS",
        "Autozoom in single {.str POINT} set to {.val 18}"
      )
    }
  }

  geom <- sf::st_transform(geom, prov_crs)
  bbox <- get_tile_bbox(geom, bbox_expand = bbox_expand, prov_type = prov_type)

  if (prov_type == "WMS") {
    tile_map <- get_wms_tile(bbox, prov_list, update_cache, cache_dir, verbose)
  } else {
    tile_map <- get_wmts_tile(
      bbox,
      prov_list,
      zoom,
      zoommin,
      update_cache,
      cache_dir,
      verbose
    )
  }
  if (is.null(tile_map)) {
    return(NULL)
  }

  # In some cases need to colorize (e.g. Catastro)
  if (all(terra::nlyr(tile_map) == 1)) {
    tile_map <- terra::colorize(tile_map, to = "rgb", alpha = TRUE)
  }

  x_terra <- terra::vect(x)
  bbox_terra <- terra::vect(bbox)

  # Finish
  tile_map <- terra::clamp(tile_map, lower = 0, upper = 255, values = TRUE)
  # reproject tile_map if needed
  if (terra::crs(x_terra) != terra::crs(tile_map)) {
    tile_map <- terra::project(tile_map, x_terra, mask = mask)
  }

  # Attribution

  attrib <- ensure_null(prov_list$attribution)
  make_msg(
    "info",
    all(verbose, !is.null(attrib)),
    "{.emph Data and map tiles sources}:",
    paste0("{.strong ", attrib, "}.")
  )

  # crop management
  if (crop == TRUE) {
    bbox_terra <- terra::project(bbox_terra, terra::crs(tile_map))

    tile_map <- terra::crop(tile_map, bbox_terra)
  }

  # mask
  if (mask) {
    tile_map <- terra::mask(tile_map, x_terra)
  }

  # Transparency
  if (all(transparent, terra::nlyr(tile_map) == 4)) {
    tomask <- terra::subset(tile_map, 4)
    tomask[tomask == 0] <- NA

    tile_map <- terra::mask(tile_map, tomask)
  }
  if (!transparent) {
    tile_map <- terra::subset(tile_map, 1:3)
  }

  # Names and attributes
  nm <- c("red", "green", "blue", "alpha")
  nl <- seq_len(terra::nlyr(tile_map))
  names(tile_map) <- nm[nl]
  terra::RGB(tile_map) <- nl

  tile_map
}


get_wms_tile <- function(bbox, prov_list, update_cache, cache_dir, verbose) {
  # Prepare call
  bbox_num <- as.double(sf::st_bbox(bbox))

  id <- prov_list$id
  q <- prov_list$q

  remove_fields <- c("id", "q", "min_zoom", "attribution")
  rest <- prov_list[!names(prov_list) %in% remove_fields]
  rest$bbox <- paste0(bbox_num, collapse = ",")
  q_end <- paste0(q, paste0(names(rest), "=", rest, collapse = "&"))
  ext <- get_tile_ext(prov_list)

  # File name

  file_name <- paste0(cli::hash_raw_md5(charToRaw(q_end)), ".", ext)

  file_local <- download_url(
    q_end,
    name = file_name,
    cache_dir = cache_dir,
    subdir = id,
    update_cache = update_cache,
    verbose = verbose
  )
  if (is.null(file_local)) {
    return(NULL)
  }

  r <- terra::rast(file_local, noflip = TRUE)

  # Extension and crs
  terra::ext(r) <- terra::ext(terra::vect(bbox))
  crs_tile <- get_tile_crs(prov_list)
  terra::crs(r) <- terra::crs(crs_tile$input)
  r
}

get_wmts_tile <- function(
  bbox,
  prov_list,
  zoom,
  zoommin,
  update_cache,
  cache_dir,
  verbose
) {
  # Need bbox in 4326
  bbox_4326 <- sf::st_transform(bbox, 4326)
  bbox_4326 <- sf::st_bbox(bbox_4326)
  as.numeric(NULL)
  # Zoom management
  zoom <- ensure_null(as.numeric(zoom))
  zoommin <- ensure_null(as.numeric(zoommin))
  min_zoom <- ensure_null(as.numeric(prov_list$min_zoom))
  tile_grid <- bbox_tile_query(bbox_4326)

  # Need autozoom
  if (is.null(zoom)) {
    zoom <- min(tile_grid[tile_grid$total_tiles %in% seq(4, 12), ]$zoom) +
      zoommin
    make_msg(
      "info",
      verbose,
      paste0("Autozoom level: {.val ", zoom, "}.")
    )
  }

  # Check provider
  if (all(!is.null(min_zoom), min_zoom > zoom)) {
    make_msg(
      "info",
      TRUE,
      paste0(
        "Minimum {.arg zoom} admitted by this provider is ",
        "{.val ",
        min_zoom,
        "}. Increasing {.arg zoom} (it was {.val ",
        zoom,
        "})."
      )
    )
    zoom <- max(zoom, min_zoom)
  }

  # Composing grid
  # get tile list
  tile_numbers <- bbox_to_tile_grid(
    bbox = bbox_4326,
    zoom = as.numeric(zoom)
  )
  tile_numbers_df <- tile_numbers$tiles

  # Prepare query
  prov_ext <- get_tile_ext(prov_list)
  prov_folder <- prov_list$id

  q <- prov_list$q
  remove_fields <- c("id", "q", "min_zoom", "attribution")
  rest <- prov_list[!names(prov_list) %in% remove_fields]
  if (length(rest) > 0) {
    q <- paste0(q, paste0(names(rest), "=", rest, collapse = "&"))
  }

  # Perform query
  tile_iter <- seq_len(nrow(tile_numbers_df))

  tile_list <- lapply(tile_iter, function(i) {
    #  x and y
    xtile <- tile_numbers_df[i, ]$x
    ytile <- tile_numbers_df[i, ]$y
    ztile <- zoom
    q_tile <- q

    # Replace in q
    q_tile <- gsub(
      pattern = "{x}",
      replacement = xtile,
      x = q_tile,
      fixed = TRUE
    )
    q_tile <- gsub(
      pattern = "{y}",
      replacement = ytile,
      x = q_tile,
      fixed = TRUE
    )
    q_tile <- gsub(
      pattern = "{z}",
      replacement = ztile,
      x = q_tile,
      fixed = TRUE
    )
    file_name <- paste0("tile_", ztile, "_", xtile, "_", ytile, ".", prov_ext)
    file_local <- download_url(
      url = q_tile,
      name = file_name,
      cache_dir = cache_dir,
      subdir = prov_folder,
      update_cache = update_cache,
      verbose = verbose
    )

    file_local <- ensure_null(file_local)
    if (is.null(file_local)) {
      return(NULL)
    }

    r <- terra::rast(file_local, noflip = TRUE)

    # Extension and crs
    ext_tile <- tile_bbox(xtile, ytile, ztile)
    ext_tile <- sf::st_as_sfc(ext_tile)
    ext_tile <- terra::vect(ext_tile)

    terra::ext(r) <- terra::ext(ext_tile)
    crs_tile <- get_tile_crs(prov_list)
    terra::crs(r) <- terra::crs(crs_tile$input)
    r
  })

  if (all(lengths(tile_list) == 0)) {
    return(NULL)
  }
  tile_list <- tile_list[lengths(tile_list) != 0]

  make_msg(
    "info",
    verbose,
    paste0("{.strong ", length(tile_list), "} tile(s) downloaded.")
  )

  # SpatRasterCollection
  r_all <- terra::sprc(tile_list)
  r_all <- terra::merge(r_all)

  r_all
}
