#' Countries of the World - SIANE
#'
#' @description
#' This dataset contains the administrative boundaries at country level of the
#' world.
#'
#' The data included in this cartographic database do not imply any opinion of
#' the IGN regarding its legal status.
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
#' @param country Character vector of country codes. It can be either a
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
  init_epsg <- validate_epsg(epsg)

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "ww84_60_admin_pais_a.gpkg"
  )

  data_sf <- read_siane_files(
    url,
    cache = cache,
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )
  if (is.null(data_sf)) {
    return(NULL)
  }
  data_sf <- sanitize_transform_sf(data_sf, init_epsg)
  data_sf <- siane_filter_year(data_sf = data_sf, year = year)
  data_sf <- filter_country(data_sf, country)

  if (nrow(data_sf) == 0) {
    data_sf <- return_empty_sf(
      data_sf,
      "The values in {.arg country} do not return any results."
    )
  }

  data_sf
}

#' Filter data sf by country
#'
#' @param data_sf An `sf` object.
#' @param country Character vector of country codes or names.
#'
#' @return An `sf` object with rows filtered by the provided country vector.
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
