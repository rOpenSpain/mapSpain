#' Get boundaries of Spain
#'
#' Loads a single `sf` object containing the boundaries of Spain.
#'
#' @concept political
#'
#' @return A `MULTIPOLYGON/MULTIPOINT` object.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @seealso [esp_get_nuts()]
#'
#' @export
#'
#' @param ... Additional parameters from [esp_get_nuts()].
#'
#' @examples
#'
#' library(sf)
#'
#' OriginalCan <- esp_get_country(moveCAN = FALSE)
#'
#' plot(OriginalCan$geometry, col = hcl.colors(5))
#'
#' MovedCan <- esp_get_country(moveCAN = TRUE)
#'
#' plot(MovedCan$geometry, col = hcl.colors(5))
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
