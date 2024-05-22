#' Get [`sf`][sf::st_sf] lines and points with the railways of Spain
#'
#' @description
#' Loads a [`sf`][sf::st_sf] lines or point object representing the nodes and
#' railway lines of Spain.
#'
#' @family infrastructure
#'
#' @return A [`sf`][sf::st_sf] line or point object.
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#' @export
#'
#' @param year Release year.
#'
#' @param spatialtype Spatial type of the output. Use `"line"`
#'   for extracting the railway as lines and `"point"` for extracting
#'   stations.
#'
#' @inheritParams esp_get_roads
#'
#' @inheritSection  esp_get_nuts  About caching
#'
#' @examplesIf esp_check_access()
#' \donttest{
#'
#' provs <- esp_get_prov()
#' ccaa <- esp_get_ccaa()
#'
#' # Railways
#' rails <- esp_get_railway()
#'
#' # Stations
#' stations <- esp_get_railway(spatialtype = "point")
#'
#' # Map
#'
#' library(ggplot2)
#'
#' ggplot(provs) +
#'   geom_sf(fill = "grey99", color = "grey50") +
#'   geom_sf(data = ccaa, fill = NA) +
#'   geom_sf(
#'     data = rails, aes(color = tipo),
#'     show.legend = FALSE, linewidth = 1.5
#'   ) +
#'   geom_sf(
#'     data = stations,
#'     color = "red", alpha = 0.5
#'   ) +
#'   coord_sf(
#'     xlim = c(-7.5, -2.5),
#'     ylim = c(38, 41)
#'   ) +
#'   scale_color_manual(values = hcl.colors(
#'     length(unique(rails$tipo)), "viridis"
#'   )) +
#'   theme_minimal()
#' }
esp_get_railway <- function(year = Sys.Date(),
                            epsg = "4258",
                            cache = TRUE,
                            update_cache = FALSE,
                            cache_dir = NULL,
                            verbose = FALSE,
                            spatialtype = "line") {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }


  # Valid spatialtype
  validspatialtype <- c("line", "point")

  if (!spatialtype %in% validspatialtype) {
    stop(
      "spatialtype should be one of '",
      paste0(validspatialtype, collapse = "', "),
      "'"
    )
  }

  type <- paste0("ffcc", spatialtype)


  data_sf <- esp_hlp_get_siane(type,
    "3",
    cache,
    cache_dir,
    update_cache,
    verbose,
    year = Sys.Date()
  )

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
}
