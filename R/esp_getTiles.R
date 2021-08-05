#' Get static tiles from public administrations of Spanish.
#'
#' @description
#' Get static map tiles based on a spatial object. Maps can be fetched from
#' various open map servers.
#'
#' This function is a implementation of the javascript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **v1.2.0**.
#'
#' @concept imagery
#'
#' @return
#' A `RasterBrick` is returned, with 3 (RGB) or 4 (RGBA) layers, depending on
#' the provider. See [raster::brick()].
#' .
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#'  **v1.2.0**.
#'
#'
#' @seealso
#' [leaflet.providersESP.df], [raster::brick()]
#' [addProviderEspTiles()].
#'
#' For plotting, you can use [raster::plotRGB()], [tmap::tm_rgb()].
#'
#' @export
#'
#' @param x An `sf` object.
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
#' t <- tibble::tribble(
#'  ~zoom, ~"area to represent",
#'  0, "whole world",
#'  3, "large country",
#'  5, "state",
#'  8, "county",
#'  10, "metropolitan area",
#'  11, "city",
#'  13, "village or suburb",
#'  16, "streets",
#'  18, "some buildings, trees"
#'  )
#'
#' knitr::kable(t)
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
#' library(tmap)
#'
#' tm_shape(Tile, raster.downsample = FALSE) +
#'   tm_rgb(interpolate = FALSE) +
#'   tm_shape(Murcia) +
#'   tm_borders()
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
                         verbose = FALSE) {
  # nocov start
  if (isFALSE(requireNamespace("rgdal", quietly = TRUE))) {
    stop("`rgdal` package required for esp_getTiles()")
  }


  # Disable warnings related with crs
  oldw <- getOption("warn")
  options(warn = -1)

  # A. Check providers
  leafletProvidersESP <- mapSpain::leaflet.providersESP.df
  provs <-
    leafletProvidersESP[leafletProvidersESP$provider == type, ]

  if (nrow(provs) == 0) {
    stop(
      "No match for type = '",
      type,
      "' found. Available providers are:\n\n",
      paste0("'", unique(leafletProvidersESP$provider), "'", collapse = ", ")
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
  if (length(x) & "POINT" %in% sf::st_geometry_type(x)) {
    x <- sf::st_buffer(sf::st_geometry(x), 50)
    crop <- FALSE
    # Auto zoom = 18 if not set
    if (is.null(zoom)) {
      zoom <- 18
      if (verbose) message("Auto zoom on point set to 18")
    }
  }


  # Create cache dir
  cache_dir <- esp_hlp_cachedir(cache_dir)
  cache_dir <- esp_hlp_cachedir(paste0(cache_dir, "/", type))


  if (provs[provs$field == "type", "value"] == "WMS") {
    rout <-
      getWMS(
        x,
        provs,
        update_cache,
        cache_dir,
        verbose,
        res,
        transparent,
        bbox_expand
      )
  } else {
    rout <-
      getWMTS(
        x,
        provs,
        update_cache,
        cache_dir,
        verbose,
        res,
        zoom,
        zoommin,
        type,
        transparent
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

  # reproject rout

  rout <-
    raster::projectRaster(from = rout, crs = sf::st_crs(x)$proj4string)

  rout <- raster::clamp(rout,
    lower = 0,
    upper = 255,
    useValues = TRUE
  )


  # crop management
  if (crop == TRUE) {
    cb <- sf::st_bbox(x)

    k <-
      min(c(bbox_expand * (cb[4] - cb[2]), bbox_expand * (cb[3] - cb[1])))
    cb <- cb + c(-k, -k, k, k)
    rout <- raster::crop(rout, cb[c(1, 3, 2, 4)])
  }

  # Mask
  if (mask & class(x)[1] != "RasterBrick") {
    rout <- raster::mask(rout, x)
  }

  # Restore warnings
  options(warn = oldw)
  on.exit(options(warn = oldw))

  # Result
  return(rout)
  # nocov end
}
