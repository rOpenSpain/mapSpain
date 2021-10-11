#' Get `sf` polygons and lines with the hypsometry and bathymetry of Spain
#'
#' @description
#' Loads a `sf` polygon or line object representing the hypsometry and
#' bathymetry of Spain.
#'
#' * **Hypsometry** represents the  the elevation and depth of features of the
#'   Earth's surface relative to mean sea level.
#' * **Bathymetry** is the measurement of the depth of water in oceans, rivers,
#'   or lakes.
#'
#' @family natural
#'
#' @return A `sf` polygon or line object.
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#' @export
#'
#' @param resolution Resolution of the shape. Values available
#'   are `"3"` or `"6.5"`.
#'
#' @param spatialtype Spatial type of the output. Use `"area"` for polygons or
#'   `"line"` for lines.
#'
#' @inheritParams esp_get_nuts
#'
#' @inheritSection  esp_get_nuts  About caching
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # This code would produce a nice plot - It will take a few seconds to run
#' library(ggplot2)
#'
#' hypsobath <- esp_get_hypsobath()
#'
#' # Error on the data provided - There is an empty shape
#' # Remove:
#'
#' hypsobath <- hypsobath[!sf::st_is_empty(hypsobath), ]
#'
#' # Tints from Wikipedia
#' # https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Maps/Conventions/Topographic_maps
#'
#' bath_tints <- colorRampPalette(
#'   rev(
#'     c(
#'       "#D8F2FE", "#C6ECFF", "#B9E3FF",
#'       "#ACDBFB", "#A1D2F7", "#96C9F0",
#'       "#8DC1EA", "#84B9E3", "#79B2DE",
#'       "#71ABD8"
#'     )
#'   )
#' )
#'
#' hyps_tints <- colorRampPalette(
#'   rev(
#'     c(
#'       "#F5F4F2", "#E0DED8", "#CAC3B8", "#BAAE9A",
#'       "#AC9A7C", "#AA8753", "#B9985A", "#C3A76B",
#'       "#CAB982", "#D3CA9D", "#DED6A3", "#E8E1B6",
#'       "#EFEBC0", "#E1E4B5", "#D1D7AB", "#BDCC96",
#'       "#A8C68F", "#94BF8B", "#ACD0A5"
#'     )
#'   )
#' )
#'
#' levels <- sort(unique(hypsobath$val_inf))
#'
#' # Create palette
#' br_bath <- length(levels[levels < 0])
#' br_terrain <- length(levels) - br_bath
#'
#' pal <- c(bath_tints((br_bath)), hyps_tints((br_terrain)))
#'
#'
#' # Plot Canary Islands
#' ggplot(hypsobath) +
#'   geom_sf(aes(fill = as.factor(val_inf)),
#'     color = NA
#'   ) +
#'   coord_sf(
#'     xlim = c(-18.6, -13),
#'     ylim = c(27, 29.5)
#'   ) +
#'   scale_fill_manual(values = pal) +
#'   guides(fill = guide_legend(
#'     title = "Elevation",
#'     direction = "horizontal",
#'     label.position = "bottom",
#'     title.position = "top",
#'     nrow = 1
#'   )) +
#'   theme(legend.position = "bottom")
#'
#'
#' # Plot Mainland
#' ggplot(hypsobath) +
#'   geom_sf(aes(fill = as.factor(val_inf)),
#'     color = NA
#'   ) +
#'   coord_sf(
#'     xlim = c(-9.5, 4.4),
#'     ylim = c(35.8, 44)
#'   ) +
#'   scale_fill_manual(values = pal) +
#'   guides(fill = guide_legend(
#'     title = "Elevation",
#'     keyheight = .8
#'   ))
#' }
esp_get_hypsobath <- function(epsg = "4258",
                              cache = TRUE,
                              update_cache = FALSE,
                              cache_dir = NULL,
                              verbose = FALSE,
                              resolution = "3",
                              spatialtype = "area") {
  init_epsg <- as.character(epsg)
  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Valid res
  validres <- c("3", "6.5")

  if (!resolution %in% validres) {
    stop(
      "resolution should be one of '",
      paste0(validres, collapse = "', "),
      "'"
    )
  }

  # Valid spatialtype
  validspatialtype <- c("area", "line")

  if (!spatialtype %in% validspatialtype) {
    stop(
      "spatialtype should be one of '",
      paste0(validspatialtype, collapse = "', "),
      "'"
    )
  }

  type <- paste0("orog", spatialtype)

  data_sf <- esp_hlp_get_siane(type,
    resolution,
    cache,
    cache_dir,
    update_cache,
    verbose,
    year = Sys.Date()
  )
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
}
