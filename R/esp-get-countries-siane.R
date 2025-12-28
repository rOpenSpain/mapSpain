#' Countries of the World - SIANE
#'
#' @description
#' This dataset contains the administrative boundaries at country level of the
#' world.
#'
#' @encoding UTF-8
#' @family political
#' @family siane
#' @inheritParams esp_get_ccaa_siane
#' @inheritParams esp_get_prov
#' @inherit esp_get_ccaa_siane source return
#' @export
#'
#' @seealso [giscoR::gisco_get_countries()].
#'
#' @param country character vector of country codes. It could be either a
#'   vector of country names, a vector of ISO3 country codes or a vector of
#'   ISO2 country codes. See also [countrycode::countrycode()].
#'
#' @examplesIf esp_check_access()
#' cntries <- esp_get_countries_siane()
#'
#' library(ggplot2)
#' ggplot(cntries) +
#'   geom_sf()
esp_get_countries_siane <- function(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  country = NULL
) {
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "ww84_60_admin_pais_a.gpkg"
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
    data_sf <- read_geo_file_sf(file_local)

    if (is.null(data_sf)) {
      return(NULL)
    }
  }
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  data_sf <- siane_filter_year(data_sf = data_sf, year = year)
  data_sf <- filter_country(data_sf, country)

  if (nrow(data_sf) == 0) {
    cli::cli_alert_warning(
      paste0(
        "The values on {.arg country} does not return any result"
      )
    )
    cli::cli_alert_info("Returning empty {.cls sf} object.")
  }

  data_sf
}


#' Filter data sf by country
#'
#' @param data_sf sf object
#' @param country character vector of country codes or names
#'
#' @return sf object filtered
#'
#' @noRd
filter_country <- function(data_sf, country = NULL) {
  if (!"id_iso3" %in% names(data_sf)) {
    return(data_sf) # nocov
  }
  fil_codes <- convert_country_code(country)
  if (is.null(fil_codes)) {
    return(data_sf)
  }

  data_sf <- data_sf[data_sf$id_iso3 %in% fil_codes, ]

  data_sf
}
