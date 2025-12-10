#' Get static tiles from public administrations of Spain
#'
#' @description
#' Get static map tiles based on a spatial object. Maps can be fetched from
#' various open map servers.
#'
#' This function is a implementation of the javascript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **`r leafletprovidersESP_v`**.
#'
#' @family imagery utilities
#' @seealso [terra::rast()].
#'
#' @return
#' A `SpatRaster` is returned, with 3 (RGB) or 4 (RGBA) layers, depending on
#' the provider. See [terra::rast()].
#' .
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#'  **`r leafletprovidersESP_v`**.
#'
#' @export
#'
#' @param x An [`sf`][sf::st_sf] or [`sfc`][sf::st_sfc] object.
#'
#' @param type This parameter could be either:
#'   - The name of one of the  pre-defined providers
#'     (see [esp_tiles_providers()]).
#'   - A list with two named elements `id` and `q` with your own parameters.
#'     See [esp_make_provider()] and examples.
#' @param zoom Zoom level. If `NULL`, it is determined automatically. If set,
#'   it overrides `zoommin`. Only valid for WMTS tiles. On a single point it
#'   applies a buffer to the point and on `zoom = NULL` the function set a zoom
#'   level of 18. See **Details**.
#' @param zoommin Delta on default `zoom`. The default value is designed to
#'   download fewer tiles than you probably want. Use `1` or `2` to
#'   increase the resolution.
#' @param crop `TRUE` if results should be cropped to the specified `x` extent,
#'   `FALSE` otherwise. If `x` is an [`sf`][sf::st_sf] object with one `POINT`,
#'   `crop` is set to `FALSE`.
#' @param res Resolution (in pixels) of the final tile. Only valid for WMS.
#' @param bbox_expand A numeric value that indicates the expansion percentage
#' of the bounding box of `x`.
#' @param transparent Logical. Provides transparent background, if supported.
#' Depends on the selected provider on `type`.
#' @param mask `TRUE` if the result should be masked to `x`.
#' @param options A named list containing additional options to pass to the
#'   query.
#'
#' @inheritParams esp_get_nuts
#'
#' @inheritSection esp_get_nuts About caching
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
#' Most WMS/WMTS providers provide tiles on "EPSG:3857". In case that the tile
#' looks deformed, try projecting first `x`:
#'
#' `x <- sf::st_transform(x, 3857)`
#'
#'
#' @examples
#' \dontrun{
#' # This script downloads tiles to your local machine
#' # Run only if you are online
#'
#' segovia <- esp_get_prov_siane("segovia", epsg = 3857)
#' tile <- esp_getTiles(segovia, "IGNBase.Todo")
#'
#' library(ggplot2)
#' library(tidyterra)
#'
#' ggplot(segovia) +
#'   geom_spatraster_rgb(data = tile, maxcell = Inf) +
#'   geom_sf(fill = NA)
#'
#' # Another provider
#'
#' tile2 <- esp_getTiles(segovia, type = "MDT")
#'
#' ggplot(segovia) +
#'   geom_spatraster_rgb(data = tile2, maxcell = Inf) +
#'   geom_sf(fill = NA)
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
#' custom_wms_tile <- esp_getTiles(segovia, custom_wms)
#'
#' autoplot(custom_wms_tile, maxcell = Inf) +
#'   geom_sf(data = segovia, fill = NA, color = "red")
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
#' custom_wmts_tile <- esp_getTiles(segovia, custom_wmts)
#'
#' autoplot(custom_wmts_tile, maxcell = Inf) +
#'   geom_sf(data = segovia, fill = NA, color = "white", linewidth = 2)
#'
#' # Example from https://leaflet-extras.github.io/leaflet-providers/preview/
#' cartodb_voyager <- list(
#'   id = "CartoDB_Voyager",
#'   q = "https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png"
#' )
#' cartodb <- esp_getTiles(segovia, cartodb_voyager, zoommin = 1)
#'
#' autoplot(cartodb, maxcell = Inf) +
#'   geom_sf(data = segovia, fill = NA, color = "black", linewidth = 1)
#' }
esp_getTiles <- function(
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
  # Only sf and sfc objects allowed

  if (!inherits(x, "sf") && !inherits(x, "sfc")) {
    stop("Only sf and sfc objects allowed")
  }

  # If sfc convert to sf
  if (inherits(x, "sfc")) {
    x <- sf::st_as_sf(data.frame(x = 1), x)
  }

  # Some transformations
  res <- as.numeric(res)

  # Keep initial
  xinit <- x
  x <- sf::st_geometry(x)

  # A. Check providers
  if (is.list(type)) {
    # Custom query

    url_pieces <- type$q
    type <- type$id

    if (any(is.null(url_pieces), is.null(type))) {
      stop(
        "Custom provider should be a named list with an 'id' ",
        "and a 'q' field"
      )
    }

    url_pieces <- esp_hlp_split_url(url_pieces)
    extra_opts <- NULL
  } else {
    provs <- mapSpain::esp_tiles_providers

    if (!type %in% names(provs)) {
      stop(
        "No match for type = '",
        type,
        "' found. Check providers available in mapSpain::esp_tiles_providers"
      )
    }

    # Split url
    url_pieces <- provs[[type]]$static
    # And get extra optios
    extra_opts <- provs[[type]]$leaflet

    names(url_pieces) <- tolower(names(url_pieces))
    names(extra_opts) <- tolower(names(extra_opts))
  }
  # Create cache dir
  cache_dir <- create_cache_dir(cache_dir)
  cache_dir <- create_cache_dir(paste0(cache_dir, "/", type))

  # Attribution
  attr <- url_pieces$attribution

  url_pieces <- modifyList(url_pieces, list(attribution = NULL))

  # Get type of service
  if (is.null(url_pieces$service)) {
    # On null we assume WMTS, case of non INSPIRE serves OSM)
    typeprov <- "WMTS"
  } else {
    typeprov <- toupper(url_pieces$service)
  }
  # Add options
  if (is.list(options)) {
    names(options) <- tolower(names(options))

    if (typeprov == "WMS" && "version" %in% names(options)) {
      # Exception: need to change names depending on the version of WMS

      v_wms <- unlist(modifyList(
        list(v = url_pieces$version),
        list(v = options$version)
      ))

      # Assess version
      v_wms <- unlist(strsplit(v_wms, ".", fixed = TRUE))

      if (v_wms[1] >= "1" && v_wms[2] >= "3") {
        names(url_pieces) <- gsub("srs", "crs", names(url_pieces))
      } else {
        names(url_pieces) <- gsub("crs", "srs", names(url_pieces))
      }
    }

    # Ignore TileMatrix fields in WMTS
    if (typeprov == "WMTS") {
      ig <- !grepl("tilematrix", names(options), ignore.case = TRUE)
      options <- options[ig]
    }

    url_pieces <- modifyList(url_pieces, options)
    # Create new cache dir

    # Modify cache dir
    newdir <- paste0(names(options), "=", options, collapse = "&")
    newdir <- esp_get_md5(newdir)

    cache_dir <- file.path(cache_dir, newdir)
    cache_dir <- create_cache_dir(cache_dir)
  }

  # Get CRS of Tile
  crs <- unlist(
    url_pieces[names(url_pieces) %in% c("crs", "srs", "tilematrixset")]
  )
  # Caso some WMTS
  if (is.null(crs)) {
    crs <- "EPSG:3857"
  }

  if (tolower(crs) == tolower("GoogleMapsCompatible")) {
    crs <- "EPSG:3857"
  }
  crs <- toupper(crs)

  crs_sf <- sf::st_crs(crs)

  # Transform to crs of tile

  x <- sf::st_transform(x, crs_sf)

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

  newbbox <- esp_hlp_get_bbox(x, bbox_expand, typeprov)

  if (typeprov == "WMS") {
    rout <- getwms(
      newbbox,
      url_pieces,
      update_cache,
      cache_dir,
      verbose,
      res,
      transparent
    )
  } else {
    rout <- getwmts(
      newbbox,
      type,
      url_pieces,
      update_cache,
      cache_dir,
      verbose,
      zoom,
      zoommin,
      transparent,
      extra_opts
    )
  }

  # Regenerate
  # Display attributions

  if (verbose && !is.null(attr)) {
    message("\nData and map tiles sources:\n", attr)
  }

  x <- xinit
  x_terra <- terra::vect(x)

  # reproject rout if needed
  if (!sf::st_crs(x) == sf::st_crs(rout)) {
    # Sometimes it gets an error

    rout_end <- try(terra::project(rout, terra::crs(x_terra)), silent = TRUE)

    if (inherits(rout_end, "try-error")) {
      if (verbose) {
        message("Tile not reprojected.")
      }
      rout <- rout
    } else {
      rout <- rout_end
    }
  }

  rout <- terra::clamp(rout, lower = 0, upper = 255, values = TRUE)

  # crop management
  if (crop == TRUE) {
    newbbox <- sf::st_transform(newbbox, sf::st_crs(x))
    cb <- sf::st_bbox(newbbox)

    rout <- terra::crop(rout, cb[c(1, 3, 2, 4)])
  }

  # Mask
  if (mask) {
    rout <- terra::mask(rout, x_terra)
  }

  # Manage transparency

  if (!transparent && terra::nlyr(rout) == 4) {
    rout <- terra::subset(rout, 1:3)
  }

  # Manage RGB
  if (isFALSE(terra::has.RGB(rout))) {
    terra::RGB(rout) <- seq_len(terra::nlyr(rout))
  }

  # Result
  return(rout)
}

#' Helper to get bboxes
#' @noRd
esp_hlp_get_bbox <- function(x, bbox_expand = 0.05, typeprov = "WMS") {
  bbox <- as.double(sf::st_bbox(x))
  dimx <- (bbox[3] - bbox[1])
  dimy <- (bbox[4] - bbox[2])
  center <- c(bbox[1] + dimx / 2, bbox[2] + dimy / 2)

  bbox_expand <- 1 + bbox_expand

  if (typeprov == "WMS") {
    maxdist <- max(dimx, dimy)
    dimy <- maxdist
    dimx <- dimy
  }

  newbbox <- c(
    center[1] - bbox_expand * dimx / 2,
    center[2] - bbox_expand * dimy / 2,
    center[1] + bbox_expand * dimx / 2,
    center[2] + bbox_expand * dimy / 2
  )

  class(newbbox) <- "bbox"

  newbbox <- sf::st_as_sfc(newbbox)

  sf::st_crs(newbbox) <- sf::st_crs(x)

  return(newbbox)
}

# Helper to split urls
esp_hlp_split_url <- function(url_static) {
  split <- unlist(strsplit(url_static, "?", fixed = TRUE))

  if (length(split) == 1) {
    return(list(q = split))
  }

  urlsplit <- list()
  urlsplit$q <- paste0(split[1], "?")

  opts <- unlist(strsplit(split[2], "&"))

  names_opts <- vapply(
    opts,
    function(x) {
      n <- strsplit(x, "=", fixed = TRUE)
      return(unlist(n)[1])
    },
    FUN.VALUE = character(1)
  )

  values_opts <- vapply(
    opts,
    function(x) {
      n <- strsplit(x, "=", fixed = TRUE)

      unl <- unlist(n)
      if (length(unl) == 2) {
        return(unl[2])
      }
      return("")
    },
    FUN.VALUE = character(1)
  )

  names(values_opts) <- tolower(names_opts)

  urlsplit <- modifyList(urlsplit, as.list(values_opts))

  return(urlsplit)
}

esp_get_md5 <- function(x) {
  tmp <- tempfile(fileext = ".txt")
  writeLines(x, tmp)

  md5 <- unname(tools::md5sum(tmp))

  return(md5)
}
