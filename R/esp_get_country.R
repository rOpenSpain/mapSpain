#' Get the borders of Spain as a `sf` polygon
#'
#' @description
#' Returns the boundaries of Spain as a single `sf` polygon at a
#' specified scale.
#'
#' @family political
#'
#' @return A `sf` polygon object.
#'
#'
#' @export
#'
#' @inheritDotParams esp_get_nuts -nuts_level -region -spatialtype
#'
#' @inheritSection  esp_get_nuts  About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @examples
#'
#' OriginalCan <- esp_get_country(moveCAN = FALSE)
#'
#' # One row only
#'
#' nrow(OriginalCan)
#'
#' library(tmap)
#' qtm(OriginalCan, fill = "grey70")
#'
#' # Less resolution
#'
#' MovedCan <- esp_get_country(moveCAN = TRUE, resolution = "20")
#'
#' qtm(MovedCan, fill = "grey70")
esp_get_country <- function(...) {
  params <- list(...)
  params$nuts_level <- 1
  params$region <- NULL
  data_sf <- do.call(mapSpain::esp_get_nuts, params)

  # Extract geom column
  names <- names(data_sf)

  which.geom <-
    which(vapply(data_sf, function(f) {
      inherits(f, "sfc")
    }, TRUE))

  nm <- names(which.geom)

  # Join all
  init <- sf::st_crs(data_sf)
  data_sf <- sf::st_transform(data_sf, 3035)
  g <- sf::st_union(data_sf)
  g <- sf::st_transform(g, init)


  # Get df
  df <- sf::st_drop_geometry(esp_get_nuts(nuts_level = 0))

  # Generate sf object
  data_sf <- sf::st_as_sf(df, g)
  # Rename geometry to original value
  newnames <- names(data_sf)
  newnames[newnames == "g"] <- nm
  colnames(data_sf) <- newnames
  data_sf <- sf::st_set_geometry(data_sf, nm)

  return(data_sf)
}
