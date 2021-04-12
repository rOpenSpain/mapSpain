#' Get the drainage basin demarcations of Spain
#'
#' @description
#' Loads a simple feature (`sf`) object containing areas with the required
#' hydrograpic elements of Spain.
#'
#' @concept natural
#'
#' @return A `POLYGON` object.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @export
#'
#' @param domain Possible values are "land", that includes only
#' the ground part or the ground or "landsea", that includes both the ground
#' and the related sea waters of the basin
#'
#' @inheritParams esp_get_rivers
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.
#'
#' @examples
#' \donttest{
#' all <- esp_get_prov(moveCAN = FALSE)
#' hydroland <- esp_get_hydrobasin(domain = "land")
#' hydrolandsea <- esp_get_hydrobasin(domain = "landsea")
#'
#' library(tmap)
#'
#' tm_shape(hydrolandsea, bbox = c(-9.5, 35, 4.5, 44)) +
#'   tm_fill("skyblue3") +
#'   tm_shape(all) +
#'   tm_polygons("grey90") +
#'   tm_shape(hydroland) +
#'   tm_polygons("skyblue", alpha = 0.7, border.col = "blue") +
#'   tm_layout(bg.color = "grey90")
#' }
esp_get_hydrobasin <- function(epsg = "4258",
                               cache = TRUE,
                               update_cache = FALSE,
                               cache_dir = NULL,
                               verbose = FALSE,
                               resolution = "3",
                               domain = "land") {
  # Check epsg
  init_epsg <- as.character(epsg)
  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Valid spatialtype
  validdomain <- c("land", "landsea")

  if (!domain %in% validdomain) {
    stop(
      "domain should be one of '",
      paste0(validdomain, collapse = "', "),
      "'"
    )
  }

  type <- paste0("basin", domain)
  basin_sf <-
    esp_hlp_get_siane(
      type,
      resolution,
      cache,
      cache_dir,
      update_cache,
      verbose,
      Sys.Date()
    )

  basin_sf <-
    sf::st_transform(basin_sf, as.double(init_epsg))

  return(basin_sf)
}
