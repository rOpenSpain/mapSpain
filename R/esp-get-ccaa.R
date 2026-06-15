#' Autonomous Communities and Cities of Spain from GISCO
#'
#' @description
#' Get
#' [Autonomous Communities and Cities of
#' Spain](https://en.wikipedia.org/wiki/Autonomous_communities_of_Spain) at a
#' specified scale.
#'
#' @details
#' When using `ccaa` you can use and mix names and NUTS codes (levels 1 or 2),
#' ISO codes (corresponding to level 2) or `codauto` (see [esp_codelist]).
#' Ceuta and Melilla are included at the Autonomous Communities and Cities
#' level in this function.
#'
#' When calling a NUTS 1 level, all Autonomous Communities and Cities of that
#' level are added.
#'
#' @param ccaa Character string. A vector of names, codes or both for
#'   Autonomous Communities and Cities, or `NULL` to get all Autonomous
#'   Communities and Cities.
#'   See **Details**.
#'
#' @inheritParams esp_get_nuts
#' @inheritDotParams esp_get_nuts -nuts_level -region
#' @inherit esp_get_nuts
#'
#' @family political
#' @family gisco
#' @encoding UTF-8
#' @rdname esp_get_ccaa
#' @name esp_get_ccaa
#'
#' @export
#'
#' @examples
#' ccaa <- esp_get_ccaa()
#'
#' library(ggplot2)
#'
#' ggplot(ccaa) +
#'   geom_sf()
#'
#' # Random Autonomous Communities and Cities.
#' random_ccaa <- esp_get_ccaa(ccaa = c(
#'   "Euskadi",
#'   "Catalunya",
#'   "ES-EX",
#'   "Canarias",
#'   "ES52",
#'   "01"
#' ))
#'
#' ggplot(random_ccaa) +
#'   geom_sf(aes(fill = codauto), show.legend = FALSE) +
#'   geom_sf_label(aes(label = codauto), alpha = 0.3) +
#'   coord_sf(crs = 3857)
#'
#' # All Autonomous Communities and Cities of a NUTS 1 region plus one.
#'
#' mixed <- esp_get_ccaa(ccaa = c("La Rioja", "Noroeste"))
#'
#' ggplot(mixed) +
#'   geom_sf()
#'
#' # Combine with giscoR to get countries.
#' \donttest{
#'
#' library(giscoR)
#' library(sf)
#'
#' res <- 20 # Use the same resolution.
#'
#' europe <- gisco_get_countries(resolution = res)
#' ccaa <- esp_get_ccaa(moveCAN = FALSE, resolution = res)
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

  # Get the region identifier.
  nuts_id <- ensure_null(ccaa)

  if (!is.null(nuts_id)) {
    nuts_id <- convert_to_nuts_ccaa(nuts_id)
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

  # Get Autonomous Community or City metadata.
  df <- get_ccaa_codes_df()
  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Add NUTS 1 metadata.
  data_sf <- merge(data_sf, get_nuts1_codes_df(), all.x = TRUE)

  data_sf <- data_sf[, unique(c(colnames(df), "nuts1.code", "nuts1.name"))]

  # Order by Autonomous Community or City.
  data_sf <- data_sf[order(data_sf$codauto), ]

  data_sf <- sanitize_sf(data_sf)

  data_sf
}
