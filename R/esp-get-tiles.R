# nocov start
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

  zoom <- ensure_null(zoom)

  # Single point would be buffered
  if (all(length(geom) == 1, sf::st_geometry_type(geom) == "POINT")) {
    message("Remove: I am a single point")
    geom_buff <- sf::st_buffer(sf::st_transform(geom, 3857), 50)
    geom <- sf::st_transform(geom_buff, sf::st_crs(geom))

    # Modify some defaults
    crop <- FALSE
    if (is.null(zoom)) {
      zoom <- 15
      make_msg(
        "info",
        verbose,
        "Autozoom in single {.str POINT} set to {.val 15}"
      )
    }
  }
  # Buffer if single point
  if (length(x) == 1 && "POINT" %in% sf::st_geometry_type(x)) {
    xmod <- sf::st_transform(sf::st_geometry(x), 3857)
    xmod <- sf::st_buffer(xmod, 50)
    x <- sf::st_transform(xmod, sf::st_crs(x))
    crop <- FALSE
    # Auto zoom = 15 if not set
    if (is.null(zoom)) {
      zoom <- 15
      if (verbose) message("Auto zoom on point set to 15")
    }
  }

  # Validate
  prov_list <- validate_provider(type)

  # Extension
  prov_ext <- get_tile_ext(prov_list)
  valid_ext <- c("png", "jpeg", "jpg", "tiff", "geotiff")

  prov_ext <- match_arg_pretty(prov_ext, valid_ext)

  # Add options
  prov_list <- modify_provider_list(prov_list, options)

  # Get crs of Tile
  prov_crs <- get_tile_crs(prov_list)

  # Type of provider
  prov_type <- guess_provider_type(prov_list)

  # On WMS add here the target resolution
  if (prov_type == "WMS") {
    prov_list$width <- res
    prov_list$height <- res
  }

  geom <- sf::st_transform(geom, prov_crs)
  bbox <- get_tile_bbox(geom, bbox_expand = bbox_expand, prov_type = prov_type)

  if (prov_type == "WMS") {
    tile_map <- get_wms_tile(bbox, prov_list, update_cache, cache_dir, verbose)
  }

  # In some cases need to colorize (e.g. Catastro)
  if (all(terra::nlyr(tile_map) == 1)) {
    tile_map <- terra::colorize(tile_map, to = "rgb", alpha = TRUE)
  }

  x_terra <- terra::vect(x)

  # Finish
  tile_map <- terra::clamp(tile_map, lower = 0, upper = 255, values = TRUE)
  # reproject tile_map if needed
  if (terra::crs(x_terra) != terra::crs(tile_map)) {
    make_msg("info", verbose, "Reprojecting...")
    tile_map <- terra::project(tile_map, terra::crs(x_terra), mask = mask)
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
    tile_map <- terra::crop(tile_map, x_terra)
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
  file_name <- paste0(tools::md5sum(bytes = charToRaw(q_end)), ".", ext)

  file_local <- download_url(
    q_end,
    name = file_name,
    cache_dir = cache_dir,
    subdir = id,
    update_cache = update_cache,
    verbose = verbose
  )

  r <- terra::rast(file_local, noflip = TRUE)

  # Extension and crs
  terra::ext(r) <- terra::ext(terra::vect(bbox))
  crs_tile <- get_tile_crs(prov_list)
  terra::crs(r) <- terra::crs(crs_tile$input)
  r
}

# nocov end
