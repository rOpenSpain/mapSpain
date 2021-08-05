#' Get `sf` polygons of the drainage basin demarcations of Spain
#'
#' @description
#' Loads a `sf` polygon object containing areas with the required
#' hydrographic elements of Spain.
#'
#' @concept natural
#'
#' @return A `sf` polygon object.
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#' @export
#'
#' @param domain Possible values are `"land"`, that includes only
#' the ground part or the ground or `"landsea"`, that includes both the ground
#' and the related sea waters of the basin
#'
#' @inheritParams esp_get_rivers
#'
#' @inheritParams esp_get_nuts
#'
#' @inheritSection  esp_get_nuts  About caching
#'
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
#'   tm_fill("skyblue4") +
#'   tm_shape(all) +
#'   tm_polygons("grey90") +
#'   tm_shape(hydroland) +
#'   tm_polygons("skyblue", alpha = 0.5, border.col = "blue") +
#'   tm_text(
#'     text = "rotulo",
#'     remove.overlap = TRUE,
#'     size = 0.5,
#'     fontface = "bold",
#'     shadow = TRUE
#'   ) +
#'   tm_layout(bg.color = "grey95")
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
