#' Spatial ggplot2 layer for `SpatRaster` objects
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This is a wrapper of [ggspatial::layer_spatial.Raster()] that works with
#' `SpatRaster` objects.
#'
#' This function is likely to be deprecated in the future when **ggspatial**
#' (or any other package) provides native support to `SpatRaster` on
#' **ggplot**. See also <https://github.com/paleolimbot/ggspatial/issues/91>
#'
#' Other packages that supports natively `SpatRaster`:
#'
#' - [**tmap**](https://CRAN.R-project.org/package=tmap)
#' - [**mapsf**](https://CRAN.R-project.org/package=mapsf)
#' - [**rasterVis**]( https://CRAN.R-project.org/package=rasterVis)
#'
#' @seealso [ggspatial::layer_spatial.Raster()], [raster::stack()].
#'
#' @details
#' This function requires both **ggspatial** and **raster** packages.
#'
#' You can install both running
#' `install.packages("ggspatial", dependencies = TRUE)`
#'
#'
#' @export
#'
#' @param data A `SpatRaster` object created with [terra::rast()].
#' @inheritDotParams ggspatial::layer_spatial
#' @family imagery utilities
#'
#' @return A ggplot2 layer
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # Get a SpatRaster
#'
#' x <- esp_get_ccaa("Galicia")
#'
#' tile <- esp_getTiles(x, "IDErioja")
#'
#' class(tile)
#'
#' library(ggplot2)
#'
#' ggplot(x) +
#'   layer_spatraster(tile) +
#'   geom_sf(color = "yellow", fill = NA) +
#'   theme_minimal()
#' }
#'
layer_spatraster <- function(data, ...) {
  if (!inherits(data, "SpatRaster")) {
    stop("data object is not SpatRaster. See ?terra::rast()")
  }

  # nocov start
  if (!requireNamespace("ggspatial", quietly = TRUE) ||
    !requireNamespace("raster", quietly = TRUE)) {
    stop(
      "ggspatial and raster packages required for using this function. ",
      "Run install.packages('ggspatial', dependencies = TRUE)"
    )
  }
  # nocov end

  # Suppress annoying warnings of rgdal
  torast <- suppressWarnings(raster::stack(data))

  suppressWarnings(ggspatial::layer_spatial(torast, ...))
}
