#' Autonomous Communities of Spain - GISCO
#'
#' @description
#' Returns
#' [Autonomous Communities of
#' Spain](https://en.wikipedia.org/wiki/Autonomous_communities_of_Spain) at a
#' specified scale.
#'
#' @encoding UTF-8
#' @family political
#' @family gisco
#' @inheritParams esp_get_nuts
#' @inheritDotParams esp_get_nuts -nuts_level -region
#' @inherit esp_get_nuts
#' @export
#'
#' @rdname esp_get_ccaa
#' @name esp_get_ccaa
#'
#' @param ccaa A vector of names and/or codes for autonomous communities
#'   or `NULL` to get all the autonomous communities. See **Details**.
#'
#'
#' @details
#' When using `ccaa` you can use and mix names and NUTS codes (levels 1 or 2),
#' ISO codes (corresponding to level 2) or `codauto` (see [esp_codelist]).
#' Ceuta and Melilla are considered as Autonomous Communities on this function.
#'
#' When calling a NUTS1 level, all the Autonomous Communities of that level
#' would be added.
#'
#'
#' @examples
#' ccaa <- esp_get_ccaa()
#'
#' library(ggplot2)
#'
#' ggplot(ccaa) +
#'   geom_sf()
#'
#' # Random CCAA
#' random_ccaa <- esp_get_ccaa(ccaa = c(
#'   "Euskadi",
#'   "Catalunya",
#'   "ES-EX",
#'   "Canarias",
#'   "ES52",
#'   "01"
#' ))
#'
#'
#' ggplot(random_ccaa) +
#'   geom_sf(aes(fill = codauto), show.legend = FALSE) +
#'   geom_sf_label(aes(label = codauto), alpha = 0.3) +
#'   coord_sf(crs = 3857)
#'
#' # All CCAA of a Zone plus an addition
#'
#' mixed <- esp_get_ccaa(ccaa = c("La Rioja", "Noroeste"))
#'
#' ggplot(mixed) +
#'   geom_sf()
#'
#' # Combine with giscoR to get countries
#' \donttest{
#'
#' library(giscoR)
#' library(sf)
#'
#' res <- 20 # Set same resoluion
#'
#' europe <- gisco_get_countries(resolution = res)
#' ccaa <- esp_get_ccaa(moveCAN = FALSE, resolution = res)
#'
#'
#' ggplot(europe) +
#'   geom_sf(fill = "#DFDFDF", color = "#656565") +
#'   geom_sf(data = ccaa, fill = "#FDFBEA", color = "#656565") +
#'   coord_sf(
#'     xlim = c(23, 74) * 10e4,
#'     ylim = c(14, 55) * 10e4,
#'     crs = 3035
#'   ) +
#'   theme(panel.background = element_rect(fill = "#C7E7FB"))
#' }
esp_get_ccaa <- function(ccaa = NULL, moveCAN = TRUE, ...) {
  params <- list(...)

  # Get region id

  ccaa <- ccaa[!is.na(ccaa)]

  region <- ccaa
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- convert_to_nuts_ccaa(region)
  }

  params$region <- nuts_id
  params$nuts_level <- 2
  params$moveCAN <- moveCAN

  data_sf <- do.call(mapSpain::esp_get_nuts, params)
  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf$nuts2.code <- data_sf$NUTS_ID
  data_sf <- data_sf[, "nuts2.code"]

  # Get df
  df <- get_ccaa_codes_df()
  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts1
  dfnuts <- mapSpain::esp_codelist
  dfnuts <- unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])

  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

  data_sf <- data_sf[, unique(c(colnames(df), "nuts1.code", "nuts1.name"))]

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  data_sf <- sanitize_sf(data_sf)

  data_sf
}

get_ccaa_codes_df <- function() {
  getnames <- c(
    "codauto",
    "iso2.ccaa.code",
    "nuts1.code",
    "nuts2.code",
    "ine.ccaa.name",
    "iso2.ccaa.name.es",
    "iso2.ccaa.name.ca",
    "iso2.ccaa.name.gl",
    "iso2.ccaa.name.eu",
    "nuts2.name",
    "cldr.ccaa.name.en",
    "cldr.ccaa.name.es",
    "cldr.ccaa.name.ca",
    "cldr.ccaa.name.ga",
    "cldr.ccaa.name.eu",
    "ccaa.shortname.en",
    "ccaa.shortname.es",
    "ccaa.shortname.ca",
    "ccaa.shortname.ga",
    "ccaa.shortname.eu"
  )
  df_ccaa <- mapSpain::esp_codelist
  df_ccaa <- df_ccaa[, getnames]
  df_end <- unique(df_ccaa)
  df_end <- df_end[order(df_end$codauto), ]
  df_end
}
