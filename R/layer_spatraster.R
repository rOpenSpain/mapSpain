#' Deprecated: Use `tidyterra::geom_spatraster_rgb()`
#'
#' @description
#'
#' This function is deprecated. Use [tidyterra::geom_spatraster_rgb()] for
#' plot tiles with ggplot2.
#'
#' @seealso [tidyterra::geom_spatraster_rgb()].
#'
#' @export
#'
#' @keywords internal
#'
#' @param data Deprecated.
#' @param ... Deprecated
#'
#' @return An error
#'
#' @examplesIf esp_check_access()
#' \dontrun{
#'
#' # Get a SpatRaster
#'
#' x <- esp_get_ccaa("Galicia")
#'
#' tile <- esp_getTiles(x, "IDErioja")
#'
#' class(tile)
#'
#' library(ggplot2)
#' # Use tidyterra
#' library(tidyterra)
#'
#' ggplot(x) +
#'   geom_spatraster_rgb(data = tile) +
#'   geom_sf(color = "yellow", fill = NA) +
#'   theme_minimal()
#' }
#'
layer_spatraster <- function(data, ...) {
  stop(
    "`layer_spatraster() is deprecated on mapSpain v0.6.2`. Use ",
    "`tidyterra::geom_spatraster_rgb()` instead."
  )
}
