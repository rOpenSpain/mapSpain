#' Hypsometry and bathymetry of Spain - SIANE
#'
#' @description
#' Dataset representing the hypsometry and bathymetry of Spain.
#' - **Hypsometry** represents the  the elevation and depth of features of the
#'   Earth's surface relative to mean sea level.
#' - **Bathymetry** is the measurement of the depth of water in oceans, rivers,
#'   or lakes.
#'
#' @encoding UTF-8
#' @family natural
#' @inheritParams esp_get_ccaa_siane
#' @inherit esp_get_ccaa_siane
#' @export
#'
#' @param resolution character string or number. Resolution of the geospatial
#'   data. One of:
#'   * "6.5": 1:6.5 million.
#'   * "3": 1:3 million.
#'
#' @param spatialtype character string. Spatial type of the output. Use
#'   `"area"` for `POLYGON` or `"line"` for `LINESTRING`.
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
#' # Tints from Wikipedia
#' # https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Maps/Conventions/
#' # Topographic_maps
#'
#'
#' levels <- sort(unique(hypsobath$val_inf))
#'
#' # Create Manual pal
#' br_bath <- length(levels[levels < 0])
#' br_terrain <- length(levels) - br_bath
#' pal <- c(
#'   tidyterra::hypso.colors(br_bath, "wiki-2.0_bathy"),
#'   tidyterra::hypso.colors(br_terrain, "wiki-2.0_hypso")
#' )
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
#'     reverse = TRUE,
#'     keyheight = .8
#'   ))
#' }
esp_get_hypsobath <- function(
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = c(3, 6.5),
  spatialtype = c("area", "line")
) {
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))
  res <- match_arg_pretty(resolution)
  res <- gsub("6.5", "6m5", res)

  sptype <- match_arg_pretty(spatialtype)

  # Create url
  api_entry <- "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/"

  url_penin <- paste0(
    api_entry,
    "se89_",
    res,
    "_orog_hipso_",
    substr(sptype, 0, 1),
    "_x.gpkg"
  )

  url_can <- paste0(
    api_entry,
    "se89_",
    res,
    "_orog_hipso_",
    substr(sptype, 0, 1),
    "_y.gpkg"
  )

  # Not cached are read from url
  if (!cache) {
    msg <- paste0("{.url ", url_penin, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_penin <- read_geo_file_sf(url_penin)

    msg <- paste0("{.url ", url_can, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_can <- read_geo_file_sf(url_can)

    data_sf <- rbind_fill(list(data_sf_penin, data_sf_can))
  } else {
    file_local_penin <- download_url(
      url_penin,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    file_local_can <- download_url(
      url_can,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    # Download
    data_sf <- lapply(c(file_local_penin, file_local_can), read_geo_file_sf)

    data_sf <- rbind_fill(data_sf)
    if (is.null(data_sf)) {
      return(NULL)
    }
  }
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf
}
