#' Boundaries of Spain - SIANE
#'
#' @description
#' Returns the boundaries of Spain as a single [`sf`][sf::st_sf] `POLYGON`.
#'
#' @encoding UTF-8
#' @family political
#' @family siane
#' @inheritParams esp_get_ccaa_siane
#' @inheritDotParams esp_get_ccaa_siane -ccaa -rawcols
#' @inherit esp_get_ccaa_siane source return
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' original_can <- esp_get_spain_siane(moveCAN = FALSE)
#'
#' # One row only
#' original_can
#'
#'
#' library(ggplot2)
#'
#' ggplot(original_can) +
#'   geom_sf(fill = "grey70")
#'
#' # Less resolution
#' moved_can <- esp_get_spain_siane(moveCAN = TRUE, resolution = 10)
#'
#' ggplot(moved_can) +
#'   geom_sf(fill = "grey70")
#' }
esp_get_spain_siane <- function(moveCAN = TRUE, ...) {
  params <- list(...)
  params$ccaa <- NULL
  params$rawcols <- NULL

  params$moveCAN <- moveCAN

  data_sf <- do.call(mapSpain::esp_get_ccaa_siane, params)
  if (is.null(data_sf)) {
    return(NULL)
  }

  # Call to get data frame only
  for_data_frame <- mapSpain::esp_get_nuts(nuts_level = 0)

  # Combine everything
  g <- sf::st_union(data_sf)

  # Get df
  df <- sf::st_drop_geometry(for_data_frame)

  # Generate sf object
  data_sf <- sf::st_as_sf(df, g)

  # Arrange
  data_sf <- sanitize_sf(data_sf)

  data_sf
}
