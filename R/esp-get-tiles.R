#' Get static map tiles from public administrations of Spain
#'
#' @description
#' Get static map tiles based on a spatial object. Maps can be fetched from
#' WMS and WMTS providers.
#'
#' This function is an implementation of the JavaScript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **`r leaf_providers_esp_v`**.
#'
#' @details
#' Zoom levels are described on the
#' [OpenStreetMap wiki](https://wiki.openstreetmap.org/wiki/Zoom_levels):
#'
#' ```{r, echo=FALSE}
#'
#' df <- data.frame(
#'   zoom = c(0, 3, 5, 8, 10, 11, 13, 16, 18),
#'   represents = c(
#'     "whole world",
#'     "large country",
#'     "state",
#'     "county",
#'     "metropolitan area",
#'     "city",
#'     "village or suburb",
#'     "streets",
#'     "some buildings, trees"
#'   )
#' )
#'
#' knitr::kable(df,
#'              col.names = c("zoom",
#'                            "area to represent")
#'                            )
#'
#' ```
#'
#' For a complete list of providers, see [esp_tiles_providers].
#'
#' Most WMS/WMTS providers provide tiles on
#' [`"EPSG:3857"`](https://epsg.io/3857). If the tile looks deformed, try
#' projecting `x` first:
#'
#' `x <- sf::st_transform(x, 3857)`
#'
#' @inheritSection esp_set_cache_dir Caching
#' @param x An [`sf`][sf::st_sf] or [`sfc`][sf::st_sfc] object.
#'
#' @param type This argument can be one of:
#'   - The name of one of the pre-defined providers (see
#'     [esp_tiles_providers]).
#'   - A list with two named elements `id` and `q` with your own arguments. See
#'     [esp_make_provider()] and examples.
#' @param zoom Character string or number. Only valid for WMTS providers, zoom
#'   level to be downloaded. If `NULL`, it is determined automatically. If set,
#'   it overrides `zoommin`. If a single `sf` `POINT` and `zoom = NULL`, the
#'   function sets a zoom level of 18. See **Details**.
#' @param zoommin Character string or number. Delta on default `zoom`.
#'   The default value is designed to download fewer tiles than you probably
#'   want. Use `1` or `2` to increase the resolution.
#' @param crop Logical. If `TRUE`, crop results to the specified `x` extent. If
#'   `x` is an [`sf`][sf::st_sf] object with one `POINT`, `crop` is set to
#'   `FALSE`. See [terra::crop()].
#' @param res Character string or number. Only valid for WMS providers.
#'   Resolution (in pixels) of the final tile.
#' @param bbox_expand Number. Expansion percentage of the bounding box of `x`.
#' @param transparent Logical. Whether to use a transparent background, if
#'   supported.
#' @param mask Logical. `TRUE` to mask the result to `x`. See [terra::mask()].
#' @param options A named list containing additional options to pass to the
#'   query.
#'
#' @inheritParams esp_get_nuts
#'
#' @return
#' A `SpatRaster` with 3 (RGB) or 4 (RGBA) layers, depending on
#' the provider. See [terra::rast()].
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/>, a plugin for
#' \CRANpkg{leaflet}, **`r leaf_providers_esp_v`**.
#'
#' @seealso
#' - [terra::rast()].
#' - [esp_tiles_providers].
#'
#' @family images
#' @rdname esp_get_tiles
#' @name esp_get_tiles
#' @order 1
#'
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' \dontrun{
#'
#' # This example downloads data to your local computer.
#'
#' segovia <- esp_get_prov_siane("segovia", epsg = 3857)
#' tile <- esp_get_tiles(segovia, "IGNBase.Todo")
#'
#' library(ggplot2)
#' library(tidyterra)
#'
#' ggplot(segovia) +
#'   geom_spatraster_rgb(data = tile, maxcell = Inf) +
#'   geom_sf(fill = NA, linewidth = 1)
#'
#' # Another provider.
#'
#' tile2 <- esp_get_tiles(segovia, type = "MDT")
#'
#' ggplot(segovia) +
#'   geom_spatraster_rgb(data = tile2, maxcell = Inf) +
#'   geom_sf(fill = NA, linewidth = 1, color = "red")
#'
#' # A custom WMTS provider.
#'
#' custom_wmts <- esp_make_provider(
#'   id = "cyl_wmts",
#'   q = "https://www.ign.es/wmts/pnoa-ma?",
#'   service = "WMTS",
#'   layer = "OI.OrthoimageCoverage"
#' )
#'
#' custom_wmts_tile <- esp_get_tiles(segovia, custom_wmts)
#'
#' autoplot(custom_wmts_tile, maxcell = Inf) +
#'   geom_sf(data = segovia, fill = NA, color = "white", linewidth = 1)
#'
#' # Example from https://leaflet-extras.github.io/leaflet-providers/preview/.
#' cartodb_dark <- list(
#'   id = "CartoDB_DarkMatter",
#'   q = "https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
#' )
#' cartodb_dark_tile <- esp_get_tiles(segovia, cartodb_dark,
#'   zoommin = 1,
#'   update_cache = TRUE
#' )
#'
#' autoplot(cartodb_dark_tile, maxcell = Inf) +
#'   geom_sf(data = segovia, fill = NA, color = "white", linewidth = 1)
#' }
esp_get_tiles <- function(
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

  # Validate spatial input.

  if (!any(inherits(x, "sf"), inherits(x, "sfc"))) {
    cli::cli_abort(paste0(
      "{.arg x} must be an {.cls sf} ",
      "or {.cls sfc} object, not {.obj_type_friendly {x}}."
    ))
  }

  geom <- sf::st_geometry(x)
  provider <- prepare_tile_provider(type, options, res)
  prov_list <- provider$prov_list
  prov_type <- provider$prov_type

  tile_geom <- prepare_tile_geometry(geom, zoom, crop, prov_type)
  geom <- tile_geom$geom
  zoom <- tile_geom$zoom
  crop <- tile_geom$crop

  geom <- sf::st_transform(geom, provider$prov_crs)
  bbox <- get_tile_bbox(geom, bbox_expand = bbox_expand, prov_type = prov_type)

  tile_map <- get_tile_map(
    bbox,
    prov_list,
    prov_type,
    zoom,
    zoommin,
    update_cache,
    cache_dir,
    verbose
  )
  if (is.null(tile_map)) {
    return(NULL)
  }

  finish_tile_map(
    tile_map,
    x,
    bbox,
    prov_list,
    crop,
    mask,
    transparent,
    verbose
  )
}

prepare_tile_provider <- function(type, options, res) {
  prov_list <- validate_provider(type)
  prov_list <- modify_provider_list(prov_list, options)

  validate_tile_ext(get_tile_ext(prov_list))

  prov_type <- guess_provider_type(prov_list)
  if (prov_type == "WMS") {
    prov_list$width <- res
    prov_list$height <- res
  }

  list(
    prov_list = prov_list,
    prov_type = prov_type,
    prov_crs = get_tile_crs(prov_list)
  )
}

validate_tile_ext <- function(ext) {
  valid_ext <- c("png", "jpeg", "jpg", "tiff", "geotiff")
  if (ext %in% valid_ext) {
    return(ext)
  }

  cli::cli_abort(paste0(
    "The requested file extension must be one of ",
    "{.str png}, {.str jpeg}, {.str jpg}, {.str tiff} or {.str geotiff}, ",
    "not {.str {ext}}."
  ))
}

prepare_tile_geometry <- function(geom, zoom, crop, prov_type) {
  zoom <- ensure_null(zoom)

  if (all(length(geom) == 1, sf::st_geometry_type(geom) == "POINT")) {
    geom_buff <- sf::st_buffer(sf::st_transform(geom, 3857), 50)
    geom <- sf::st_transform(geom_buff, sf::st_crs(geom))
    crop <- FALSE

    if (is.null(zoom)) {
      zoom <- 18
      make_msg(
        "info",
        prov_type == "WMTS",
        "Autozoom for a single {.cls POINT} set to {.val {18}}."
      )
    }
  }

  list(geom = geom, zoom = zoom, crop = crop)
}

get_tile_map <- function(
  bbox,
  prov_list,
  prov_type,
  zoom,
  zoommin,
  update_cache,
  cache_dir,
  verbose
) {
  if (prov_type == "WMS") {
    return(get_wms_tile(bbox, prov_list, update_cache, cache_dir, verbose))
  }

  get_wmts_tile(
    bbox,
    prov_list,
    zoom,
    zoommin,
    update_cache,
    cache_dir,
    verbose
  )
}

finish_tile_map <- function(
  tile_map,
  x,
  bbox,
  prov_list,
  crop,
  mask,
  transparent,
  verbose
) {
  tile_map <- colorize_single_layer_tile(tile_map)

  x_terra <- terra::vect(x)
  bbox_terra <- terra::vect(bbox)

  tile_map <- terra::clamp(tile_map, lower = 0, upper = 255, values = TRUE)
  if (terra::crs(x_terra) != terra::crs(tile_map)) {
    tile_map <- terra::project(tile_map, x_terra, mask = mask)
  }

  show_tile_attribution(prov_list, verbose)

  if (crop) {
    bbox_terra <- terra::project(bbox_terra, terra::crs(tile_map))
    tile_map <- terra::crop(tile_map, bbox_terra)
  }

  if (mask) {
    tile_map <- terra::mask(tile_map, x_terra)
  }

  tile_map <- apply_tile_transparency(tile_map, transparent)
  name_tile_bands(tile_map)
}

colorize_single_layer_tile <- function(tile_map) {
  if (all(terra::nlyr(tile_map) == 1)) {
    return(terra::colorize(tile_map, to = "rgb", alpha = TRUE))
  }

  tile_map
}

show_tile_attribution <- function(prov_list, verbose) {
  attrib <- ensure_null(prov_list$attribution)
  make_msg(
    "info",
    all(verbose, !is.null(attrib)),
    "{.emph Data and static map tile sources}:",
    paste0("{.strong ", attrib, "}.")
  )
}

apply_tile_transparency <- function(tile_map, transparent) {
  if (all(transparent, terra::nlyr(tile_map) == 4)) {
    tomask <- terra::subset(tile_map, 4)
    tomask[tomask == 0] <- NA
    tile_map <- terra::mask(tile_map, tomask)
  }
  if (!transparent) {
    tile_map <- terra::subset(tile_map, 1:3)
  }

  tile_map
}

name_tile_bands <- function(tile_map) {
  nm <- c("red", "green", "blue", "alpha")
  nl <- seq_len(terra::nlyr(tile_map))
  names(tile_map) <- nm[nl]
  terra::RGB(tile_map) <- nl

  tile_map
}

get_wms_tile <- function(bbox, prov_list, update_cache, cache_dir, verbose) {
  # Prepare the provider call.
  bbox_num <- as.double(sf::st_bbox(bbox))

  id <- prov_list$id
  q <- prov_list$q

  remove_fields <- c("id", "q", "min_zoom", "attribution")
  rest <- prov_list[!names(prov_list) %in% remove_fields]
  rest$bbox <- paste0(bbox_num, collapse = ",")
  q_end <- paste0(q, paste0(names(rest), "=", rest, collapse = "&"))
  ext <- get_tile_ext(prov_list)

  # Build the cached file name.

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

  # Set extent and CRS.
  terra::ext(r) <- terra::ext(terra::vect(bbox))
  crs_tile <- get_tile_crs(prov_list)
  terra::crs(r) <- crs_tile
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
  bbox_4326 <- wmts_bbox_4326(bbox)
  zoom <- resolve_wmts_zoom(bbox_4326, prov_list, zoom, zoommin, verbose)
  tile_numbers <- bbox_to_tile_grid(bbox = bbox_4326, zoom = as.numeric(zoom))
  tile_numbers_df <- tile_numbers$tiles

  tile_query <- prepare_wmts_tile_query(prov_list)

  tile_list <- lapply(seq_len(nrow(tile_numbers_df)), function(i) {
    download_wmts_tile(
      tile_numbers_df[i, ],
      zoom,
      tile_query,
      prov_list,
      update_cache,
      cache_dir,
      verbose
    )
  })

  if (all(lengths(tile_list) == 0)) {
    return(NULL)
  }
  tile_list <- tile_list[lengths(tile_list) != 0]

  make_msg(
    "info",
    verbose,
    paste0("{.strong ", length(tile_list), "} tile{?s} downloaded.")
  )

  # Build a SpatRasterCollection.
  r_all <- terra::sprc(tile_list)
  r_all <- terra::merge(r_all)

  r_all
}

wmts_bbox_4326 <- function(bbox) {
  bbox_4326 <- sf::st_transform(bbox, 4326)
  sf::st_bbox(bbox_4326)
}

resolve_wmts_zoom <- function(bbox_4326, prov_list, zoom, zoommin, verbose) {
  zoom <- ensure_null(as.numeric(zoom))
  zoommin <- ensure_null(as.numeric(zoommin))
  min_zoom <- ensure_null(as.numeric(prov_list$min_zoom))

  if (is.null(zoom)) {
    tile_grid <- bbox_tile_query(bbox_4326)
    zoom <- min(tile_grid[tile_grid$total_tiles %in% seq(4, 12), ]$zoom) +
      zoommin
    make_msg("info", verbose, paste0("Autozoom level: {.val {", zoom, "}}."))
  }

  if (all(!is.null(min_zoom), min_zoom > zoom)) {
    make_msg(
      "info",
      TRUE,
      paste0(
        "Minimum {.arg zoom} supported by this provider is ",
        "{.val {",
        min_zoom,
        "}}. Increasing {.arg zoom} (it was {.val {",
        zoom,
        "}})."
      )
    )
    zoom <- max(zoom, min_zoom)
  }

  zoom
}

prepare_wmts_tile_query <- function(prov_list) {
  q <- prov_list$q
  remove_fields <- c("id", "q", "min_zoom", "attribution")
  rest <- prov_list[!names(prov_list) %in% remove_fields]
  if (length(rest) > 0) {
    q <- paste0(q, paste0(names(rest), "=", rest, collapse = "&"))
  }

  list(
    q = q,
    ext = get_tile_ext(prov_list),
    folder = prov_list$id
  )
}

download_wmts_tile <- function(
  tile,
  zoom,
  tile_query,
  prov_list,
  update_cache,
  cache_dir,
  verbose
) {
  xtile <- tile$x
  ytile <- tile$y
  ztile <- zoom

  q_tile <- build_wmts_tile_url(tile_query$q, xtile, ytile, ztile)
  file_name <- paste0("tile_", ztile, "_", xtile, "_", ytile, ".")
  file_name <- paste0(file_name, tile_query$ext)
  file_local <- download_url(
    url = q_tile,
    name = file_name,
    cache_dir = cache_dir,
    subdir = tile_query$folder,
    update_cache = update_cache,
    verbose = verbose
  )

  file_local <- ensure_null(file_local)
  if (is.null(file_local)) {
    return(NULL)
  }

  r <- terra::rast(file_local, noflip = TRUE)
  r <- colorize_single_layer_tile(r)
  set_wmts_tile_extent_crs(r, xtile, ytile, ztile, prov_list)
}

build_wmts_tile_url <- function(q, xtile, ytile, ztile) {
  q <- gsub("{x}", xtile, q, fixed = TRUE)
  q <- gsub("{y}", ytile, q, fixed = TRUE)
  gsub("{z}", ztile, q, fixed = TRUE)
}

set_wmts_tile_extent_crs <- function(r, xtile, ytile, ztile, prov_list) {
  ext_tile <- tile_bbox(xtile, ytile, ztile)
  ext_tile <- sf::st_as_sfc(ext_tile)
  ext_tile <- terra::vect(ext_tile)

  terra::ext(r) <- terra::ext(ext_tile)
  terra::crs(r) <- get_tile_crs(prov_list)
  r
}

#' @rdname esp_get_tiles
#' @usage NULL
#' @export
esp_getTiles <- esp_get_tiles
