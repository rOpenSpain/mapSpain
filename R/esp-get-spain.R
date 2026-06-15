#' Boundaries of Spain from GISCO
#'
#' @description
#' Returns the boundaries of Spain as a single [`sf`][sf::st_sf] `POLYGON` at a
#' specified scale.
#'
#' @details
#' Dataset derived from NUTS data provided by GISCO. Check [esp_get_nuts()] for
#' details.
#'
#' @inheritParams esp_get_nuts
#' @inheritDotParams esp_get_nuts -nuts_level -region -spatialtype
#'
#' @inherit esp_get_nuts
#' @return A [`sf`][sf::st_sf] `POLYGON` object.
#'
#' @family political
#' @family nuts
#' @family gisco
#' @encoding UTF-8
#' @rdname esp_get_spain
#' @name esp_get_spain
#'
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' original_can <- esp_get_spain(moveCAN = FALSE)
#'
#' # One row only
#' original_can
#'
#' library(ggplot2)
#'
#' ggplot(original_can) +
#'   geom_sf(fill = "grey70")
#'
#' # Less resolution
#' moved_can <- esp_get_spain(moveCAN = TRUE, resolution = 20)
#'
#' ggplot(moved_can) +
#'   geom_sf(fill = "grey70")
#' }
esp_get_spain <- function(moveCAN = TRUE, ...) {
  params <- list(...)
  params$nuts_level <- 1
  params$region <- NULL
  params$moveCAN <- moveCAN

  data_sf <- do.call(mapSpain::esp_get_nuts, params)
  if (is.null(data_sf)) {
    return(NULL)
  }

  # Second call to get data frame only
  params2 <- params
  params2$nuts_level <- 0
  params2$verbose <- FALSE
  params2$resolution <- "60"

  for_data_frame <- do.call(mapSpain::esp_get_nuts, params2)

  # Combine everything
  g <- sf::st_union(data_sf)

  # Get country metadata.
  df <- sf::st_drop_geometry(for_data_frame)

  # Generate sf object
  data_sf <- sf::st_as_sf(df, g)

  # Arrange
  data_sf <- sanitize_sf(data_sf)

  data_sf
}

#' @rdname esp_get_spain
#' @usage NULL
#' @export
esp_get_country <- esp_get_spain
