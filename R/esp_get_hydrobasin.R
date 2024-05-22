#' Get [`sf`][sf::st_sf] polygons of the drainage basin demarcations of Spain
#'
#' @description
#' Loads a [`sf`][sf::st_sf] polygon object containing areas with the required
#' hydrographic elements of Spain.
#'
#' @family natural
#'
#' @return A [`sf`][sf::st_sf] polygon object.
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
#' @examplesIf esp_check_access()
#' \donttest{
#' hydroland <- esp_get_hydrobasin(domain = "land")
#' hydrolandsea <- esp_get_hydrobasin(domain = "landsea")
#'
#' library(ggplot2)
#'
#'
#' ggplot(hydroland) +
#'   geom_sf(data = hydrolandsea, fill = "skyblue4", alpha = .4) +
#'   geom_sf(fill = "skyblue", alpha = .5) +
#'   geom_sf_text(aes(label = rotulo),
#'     size = 3, check_overlap = TRUE,
#'     fontface = "bold",
#'     family = "serif"
#'   ) +
#'   coord_sf(
#'     xlim = c(-9.5, 4.5),
#'     ylim = c(35, 44)
#'   ) +
#'   theme_void()
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
