#' Get static tiles from public administrations of Spanish.
#'
#' @description
#' Get static map tiles based on a spatial object. Maps can be fetched from
#' various open map servers.
#'
#' This function is a implementation of the javascript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **v1.3.0**.
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
#'  **v1.3.0**.
#'
#' @export
#'
#' @param x An `sf` or `sfc` object.
#'
#' @param type Name of the provider. See [leaflet.providersESP.df].
#' @param zoom Zoom level. If `NULL`, it is determined automatically. If set,
#'   it overrides `zoommin`. Only valid for WMTS tiles. On a single point it
#'   applies a buffer to the point and on `zoom = NULL` the function set a zoom
#'   level of 18. See **Details**.
#' @param zoommin Delta on default `zoom`. The default value is designed to
#'   download fewer tiles than you probably want. Use `1` or `2` to
#'   increase the resolution.
#' @param crop `TRUE` if results should be cropped to the specified `x` extent,
#'   `FALSE` otherwise. If `x` is an `sf` object with one `POINT`, crop is set
#'   to `FALSE`.
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
#' For a complete list of providers see [leaflet.providersESP.df].
#'
#'
#' Most WMS/WMTS providers provide tiles on "EPSG:3857". In case that the tile
#' looks deformed, try projecting first `x`:
#'
#' `x <- sf::st_transform(x, 3857)`
#'
#' @examples
#' \dontrun{
#' # This script downloads tiles to your local machine
#' # Run only if you are online
#'
#' Murcia <- esp_get_ccaa_siane("Murcia", epsg = 3857)
#' Tile <- esp_getTiles(Murcia)
#'
#' library(ggplot2)
#'
#' ggplot(Murcia) +
#'   layer_spatraster(Tile) +
#'   geom_sf(fill = NA)
#' }
esp_getTiles <- function(x,
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
                         options = NULL) {
  # nocov start

  if (!requireNamespace("slippymath", quietly = TRUE)) {
    stop("slippymath package required for using this function")
  }
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("terra package required for using this function")
  }
  if (!requireNamespace("png", quietly = TRUE)) {
    stop("png package required for using this function")
  }
  # nocov end
  # Only sf and sfc objects allowed

  if (!inherits(x, "sf") && !inherits(x, "sfc")) {
    stop(
      "Only sf and sfc ",
      "objects allowed"
    )
  }

  # If sfc convert to sf
  if (inherits(x, "sfc")) {
    x <- sf::st_as_sf(
      data.frame(x = 1),
      x
    )
  }

  # A. Check providers
  leafletProvidersESP <- mapSpain::leaflet.providersESP.df
  provs <-
    leafletProvidersESP[leafletProvidersESP$provider == type, ]

  if (nrow(provs) == 0) {
    stop(
      "No match for type = '",
      type,
      "' found. Check providers available in mapSpain::leaflet.providersESP.df"
    )
  }

  # Some transformations
  res <- as.numeric(res)

  # Keep initial
  xinit <- x
  x <- sf::st_geometry(x)

  # Transform to 3857 as it is native for tiles

  x <- sf::st_transform(x, 3857)

  # Buffer if single point
  if (length(x) == 1 && "POINT" %in% sf::st_geometry_type(x)) {
    x <- sf::st_buffer(sf::st_geometry(x), 50)
    crop <- FALSE
    # Auto zoom = 15 if not set
    if (is.null(zoom)) {
      zoom <- 15
      if (verbose) message("Auto zoom on point set to 15")
    }
  }


  # Create cache dir
  cache_dir <- esp_hlp_cachedir(cache_dir)
  cache_dir <- esp_hlp_cachedir(paste0(cache_dir, "/", type))

  typeprov <- provs[provs$field == "type", "value"]

  newbbox <- esp_hlp_get_bbox(x, bbox_expand, typeprov)


  if (typeprov == "WMS") {
    rout <-
      getwms(
        newbbox,
        provs,
        update_cache,
        cache_dir,
        verbose,
        res,
        transparent,
        options
      )
  } else {
    rout <-
      getwmts(
        newbbox,
        provs,
        update_cache,
        cache_dir,
        verbose,
        res,
        zoom,
        zoommin,
        type,
        transparent,
        options
      )
  }

  # Regenerate
  # Display attributions

  if (verbose) {
    message(
      "\nData and map tiles sources:\n",
      provs[provs$field == "attribution_static", "value"]
    )
  }

  x <- xinit
  x_terra <- terra::vect(x)

  # reproject rout if needed
  if (!sf::st_crs(x) == sf::st_crs(rout)) {

    # Sometimes it gets an error

    rout_end <- try(terra::project(
      rout,
      terra::crs(x_terra)
    ), silent = TRUE)

    if (inherits(rout_end, "try-error")) {
      if (verbose) message("Tile not reprojected.")
      rout <- rout
    } else {
      rout <- rout_end
    }
  }

  rout <- terra::clamp(rout,
    lower = 0,
    upper = 255,
    values = TRUE
  )


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
    rout <- rout[[-4]]
  }


  # Result
  return(rout)
}

#' Helper to get bboxes
#' @noRd
esp_hlp_get_bbox <- function(x, bbox_expand = 0.05, typeprov = "WMS") {
  # Get bbox, this works with CRS 3857

  stopifnot(identical(sf::st_crs(3857), sf::st_crs(x)))

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
