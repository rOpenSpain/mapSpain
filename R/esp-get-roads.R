#' Roads of Spain - SIANE
#'
#' @description
#' Object representing the main roads of Spain.
#'
#' @encoding UTF-8
#' @family infrastructure
#' @family siane
#' @inheritParams esp_get_railway
#' @inheritParams esp_get_ccaa_siane
#' @inherit esp_get_railway
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#'
#' country <- esp_get_country()
#' Roads <- esp_get_roads()
#'
#' library(ggplot2)
#'
#' ggplot(country) +
#'   geom_sf(fill = "grey90") +
#'   geom_sf(data = Roads, aes(color = tipo), show.legend = "line") +
#'   scale_color_manual(
#'     values = c("#003399", "#003399", "#ff0000", "#ffff00")
#'   ) +
#'   guides(color = guide_legend(direction = "vertical")) +
#'   theme_minimal() +
#'   labs(color = "Road type") +
#'   theme(legend.position = "bottom")
#' }
esp_get_roads <- function(
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  moveCAN = TRUE
) {
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_vias_ctra_l_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_vias_ctra_l_y.gpkg"
  )

  # Not cached are read from url
  if (!cache) {
    msg <- paste0("{.url ", url_penin, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_penin <- read_geo_file_sf(url_penin)
    data_sf_penin$codauto <- "XX"

    msg <- paste0("{.url ", url_can, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_can <- read_geo_file_sf(url_can)
    data_sf_can$codauto <- "05"

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

    # Read

    ok_down <- ensure_null(c(file_local_penin, file_local_can))
    if (is.null(ok_down)) {
      return(NULL)
    }

    data_sf_penin <- read_geo_file_sf(file_local_penin)
    data_sf_penin$codauto <- "XX"

    data_sf_can <- read_geo_file_sf(file_local_can)
    data_sf_can$codauto <- "05"

    data_sf <- rbind_fill(list(data_sf_penin, data_sf_can))
  }

  # Move can
  data_sf <- move_can(data_sf, moveCAN)
  data_sf <- data_sf[, setdiff(names(data_sf), "codauto")]

  data_sf <- data_sf[order(data_sf$t_ctra, data_sf$orden, data_sf$rotulo), ]

  # Transform
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  data_sf
}
