#' Railways of Spain - SIANE
#'
#' @description
#' Loads a [`sf`][sf::st_sf] `LINESTRING` or `POINT` object representing the
#' nodes and railway lines of Spain.
#'
#' @rdname esp_get_railway
#' @encoding UTF-8
#' @family infrastructure
#' @family siane
#' @inheritParams esp_get_ccaa_siane
#' @inherit esp_get_ccaa_siane return source
#' @export
#'
#' @param year Ignored.
#' @param spatialtype `r lifecycle::badge("deprecated")` character string.
#'   Use [mapSpain::esp_get_stations()] instead of `"point"` for stations.
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
#' stations <- esp_get_stations()
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
esp_get_railway <- function(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  spatialtype = c("line", "point")
) {
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))
  sp <- match_arg_pretty(spatialtype)

  if (sp == "point") {
    lifecycle::deprecate_soft(
      when = "1.0.0",
      what = "mapSpain::esp_get_railway(spatialtype)",
      details = "Please use `esp_get_stations()` instead."
    )

    cli::cli_alert_info(
      "Redirecting the arguments to {.fn mapSpain::esp_get_stations}"
    )

    data_sf <- esp_get_stations(
      year = year,
      epsg = epsg,
      cache = cache,
      update_cache = update_cache,
      cache_dir = cache_dir,
      verbose = verbose
    )
    return(data_sf)
  }

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/",
    "dist/se89_3_vias_ffcc_l_x.gpkg"
  )

  # Not cached are read from url
  if (!cache) {
    msg <- paste0("{.url ", url, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf <- read_geo_file_sf(url)
  } else {
    file_local <- download_url(
      url,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    # Download
    data_sf <- lapply(file_local, read_geo_file_sf)

    data_sf <- rbind_fill(data_sf)
    if (is.null(data_sf)) {
      return(NULL)
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  data_sf
}
