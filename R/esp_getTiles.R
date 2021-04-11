#' Get Tiles from Public Administrations of Spanish.
#'
#' @concept imagery
#'
#' @description
#' Get static map tiles based on a spatial object. Maps can be fetched from
#' various open map servers.
#'
#' This function is a implementation of the javascript plugin
#' <https://dieghernan.github.io/leaflet-providersESP/> **v1.2.0**.
#'
#' @return
#' A `RasterBrick` is returned, with 3 (RGB) or 4 (RGBA) layers, depending on
#' the provider.
#' .
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#'  **v1.2.0**.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @seealso
#' [leaflet.providersESP.df], [addProviderEspTiles()], [raster::plotRGB()],
#' [cartography::getTiles()]
#'
#' @export
#'
#' @param x An `sf` object.
#'
#' @param type Name of the provider. See [leaflet.providersESP.df].
#' @param zoom Zoom level. If `NULL`, it is determined automatically.
#'   Only valid for WMTS.
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
#' @details
#' Zoom levels are described on the OpenStreetMap wiki:
#' <https://wiki.openstreetmap.org/wiki/Zoom_levels>.
#'
#' Results of `esp_getTiles` could be plotted using [raster::plotRGB()] or
#' [cartography::tilesLayer()]
#'
#' For a complete list of providers see [leaflet.providersESP.df].
#'
#'
#' Most WMS/WMTS providers provide tiles on EPSG:3857. In case that the tile
#' looks deformed, try projecting first `x`:
#'
#' `x <- sf::st_transform(x,3857)`
#'
#' Tiles are cached under the path `cache_dir/[type]`.
#'
esp_getTiles <- function(x,
                         type = "IDErioja",
                         zoom = NULL,
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
  # nocov end

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
  }


  # Create cache dir
  cache_dir <- esp_hlp_cachedir(cache_dir)
  cache_dir <- esp_hlp_cachedir(file.path(cache_dir, type))


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
}
