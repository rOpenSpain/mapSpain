#' Get static tiles from public administrations of Spain
#'
#' @description
#' Get static map tiles based on a spatial object. Maps can be fetched from
#' various open map servers.
#'
#' This function is a implementation of the javascript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **`r leaf_providers_esp_v`**.
#'
#' @family images
#' @seealso [terra::rast()].
#'
#' @rdname esp_get_tiles
#' @name esp_get_tiles
#'
#' @return
#' A `SpatRaster` with 3 (RGB) or 4 (RGBA) layers, depending on
#' the provider. See [terra::rast()].
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#'  **`r leaf_providers_esp_v`**.
#'
#' @export
#'
#' @param x An [`sf`][sf::st_sf] or [`sfc`][sf::st_sfc] object.
#'
#' @param type This argument could be either:
#'   - The name of one of the  pre-defined providers (see
#'     [esp_tiles_providers()]).
#'   - A list with two named elements `id` and `q` with your own arguments. See
#'     [esp_make_provider()] and examples.
#' @param zoom character string or number. Only valid for WMTS providers, zoom
#'   level to be downloaded. If `NULL`, it is determined automatically. If set,
#'   it overrides `zoommin`. On a single `sf` `POINT` and `zoom = NULL` the
#'   function set a zoom level of 18. See **Details**.
#' @param zoommin character string or number. Delta on default `zoom`.
#'   The default value is designed to download fewer tiles than you probably
#'   want. Use `1` or `2` to increase the resolution.
#' @param crop logical. On `TRUE` the results would be cropped to the specified
#'   `x` extent. If `x` is an [`sf`][sf::st_sf] object with one `POINT`,
#'   `crop` is set to `FALSE`. See [terra::crop()].
#' @param res character string or number. Only valid for WMS providers.
#'   Resolution (in pixels) of the final tile.
#' @param bbox_expand number. Expansion percentage of the bounding box of `x`.
#' @param transparent logical. Provides transparent background, if supported.
#' @param mask logical. `TRUE` if the result should be masked to `x`, See
#'   [terra::mask()].
#' @param options A named list containing additional options to pass to the
#'   query.
#'
#' @inheritParams esp_get_nuts
#'
#'
#' @details
#' Zoom levels are described on the
#' [OpenStreetMap wiki](https://wiki.openstreetmap.org/wiki/Zoom_levels):
#'
#' ```{r, echo=FALSE}
#'
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
#'
#' knitr::kable(df,
#'              col.names = c("zoom",
#'                            "area to represent")
#'                            )
#'
#'
#' ```
#'
#' For a complete list of providers see [esp_tiles_providers].
#'
#'
#' Most WMS/WMTS providers provide tiles on
#' [`"EPSG:3857"`](https://epsg.io/3857). In case that the tile looks deformed,
#' try projecting first `x`:
#'
#' `x <- sf::st_transform(x, 3857)`
#'
#'
#' @examplesIf esp_check_access()
#' \dontrun{
#'
#' # This example downloads data to your local computer!
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
#' # Another provider
#'
#' tile2 <- esp_get_tiles(segovia, type = "MDT")
#'
#' ggplot(segovia) +
#'   geom_spatraster_rgb(data = tile2, maxcell = Inf) +
#'   geom_sf(fill = NA, linewidth = 1, color = "red")
#'
#' # A custom WMS provided
#'
#' custom_wms <- esp_make_provider(
#'   id = "an_id_for_caching",
#'   q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
#'   service = "WMS",
#'   version = "1.3.0",
#'   format = "image/png",
#'   layers = "geolog_cyl_litologia"
#' )
#'
#' custom_wms_tile <- esp_get_tiles(segovia, custom_wms)
#'
#' autoplot(custom_wms_tile, maxcell = Inf) +
#'   geom_sf(data = segovia, fill = NA, color = "red", linewidth = 1)
#'
#' # A custom WMTS provider
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
#' # Example from https://leaflet-extras.github.io/leaflet-providers/preview/
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
        "Autozoom in single {.str POINT} set to {.val 18}."
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
  # Need bbox in 4326
  bbox_4326 <- sf::st_transform(bbox, 4326)
  bbox_4326 <- sf::st_bbox(bbox_4326)

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
        "Minimum {.arg zoom} supported by this provider is ",
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
    terra::crs(r) <- crs_tile
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


#' @export
#' @rdname esp_get_tiles
#' @usage NULL
esp_getTiles <- esp_get_tiles
