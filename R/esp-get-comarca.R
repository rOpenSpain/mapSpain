#' 'Comarcas' of Spain
#'
#' @description
#' Returns
#' [Comarcas of
#' Spain](https://en.wikipedia.org/wiki/Comarcas_of_Spain). Comarcas are
#' traditional informal territorial division, comprising several municipalities
#' sharing geographical, economic or cultural traits, typically with not well
#' defined limits.
#'
#' @source
#' INE: PC_Axis files, IGN, Ministry of Agriculture, Fisheries and Food (MAPA).
#'
#'
#' @encoding UTF-8
#' @family political
#' @inheritParams esp_get_prov
#' @inheritParams esp_get_prov
#' @inherit esp_get_nuts
#' @export
#'
#' @param region character. A vector of names and/or codes for provinces or
#'   `NULL` to get all the comarcas. See **Details**.
#' @param comarca character. A name or [`regex`][base::grep()] expression with
#'   the names of the required comarcas. `NULL` would return all the possible
#'   comarcas.
#' @param type character. One of `"INE"`, `"IGN"`, `"AGR"`, `"LIV"`. Type of
#'   comarca to return, see **Details**.
#'
#' @details
#' When using `region` you can use and mix names and NUTS codes
#' (levels 1, 2 or 3), ISO codes (corresponding to level 2 or 3) or
#' "cpro" (see [esp_codelist]).
#'
#' When calling a higher level (Province, Autonomous Community or NUTS1),
#' all the comarcas of that level would be added.
#'
#' # About comarcas
#'
#' 'Comarcas' (English equivalent: district, county, area or zone) does not
#' always have a formal legal status. They correspond mainly to natural areas
#' (valleys, river basins etc.) or even to historical regions or ancient
#' kingdoms.
#'
#' In the case of Spain, comarcas only have an administrative character legally
#' recognized in Catalonia, the Basque Country, Navarra (named merindades
#' instead), in the region of El Bierzo (Castilla y Leon) and Aragon. Galicia,
#' the Principality of Asturias, and Andalusia have functional comarcas.
#'
#' # Types
#'
#' `esp_get_comarca()` can retrieve several types of comarcas, each one
#' provided under different classification criteria.
#'
#' - `"INE"`: Comarcas as defined by the National Statistics Institute (INE).
#' - `"IGN"`: Official comarcas, only available on some Autonomous Communities,
#'   provided by the National Geographic Institute.
#' - `"AGR"`: Agrarian comarcas defined by the Ministry of Agriculture,
#'   Fisheries and Food (MAPA).
#'
#' - `"LIV"`: Livestock comarcas defined by the Ministry of Agriculture,
#'   Fisheries and Food (MAPA).
#'
#'
#' @note
#' The use of the information contained on the
#' [INE website](https://www.ine.es/en/index.htm) may be carried out by users or
#' re-use agents, at their own risk, and they will be the sole liable parties
#' in the case of having to answer to third parties due to damages arising
#' from such use.
#'
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' comarcas <- esp_get_comarca(moveCAN = FALSE)
#'
#' library(ggplot2)
#'
#' ggplot(comarcas) +
#'   geom_sf()
#'
#' # IGN provides recognized comarcas
#'
#' rec <- esp_get_comarca(type = "IGN")
#'
#' ggplot(rec) +
#'   geom_sf(aes(fill = t_comarca))
#'
#' # Legal Comarcas of Catalunya
#'
#' comarcas_cat <- esp_get_comarca("Catalunya", type = "IGN")
#'
#' ggplot(comarcas_cat) +
#'   geom_sf(aes(fill = ine.prov.name)) +
#'   labs(fill = "Province")
#' }
#'
esp_get_comarca <- function(
  region = NULL,
  comarca = NULL,
  moveCAN = TRUE,
  type = c("INE", "IGN", "AGR", "LIV"),
  epsg = 4258,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))
  type <- match_arg_pretty(type)

  # url
  api_entry <- switch(type,
    "INE" = "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/",
    "IGN" = "https://github.com/rOpenSpain/mapSpain/raw/sianedata/IGNComarcas/",
    "AGR" = "https://github.com/rOpenSpain/mapSpain/raw/sianedata/MITECO/dist/",
    "LIV" = "https://github.com/rOpenSpain/mapSpain/raw/sianedata/MITECO/dist/",
  )

  filename <- switch(type,
    "INE" = "esp_com_99.gpkg",
    "IGN" = "comarcas_ign.gpkg",
    "AGR" = "comarcas_agrarias.gpkg",
    "LIV" = "comarcas_ganaderas.gpkg"
  )

  url <- paste0(api_entry, filename)

  file_local <- download_url(
    url,
    cache_dir = cache_dir,
    subdir = "comarcas",
    update_cache = update_cache,
    verbose = verbose
  )

  if (is.null(file_local)) {
    return(NULL)
  }

  # Download
  data_sf <- read_geo_file_sf(file_local)
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  comarca <- ensure_null(comarca)

  if (!is.null(comarca)) {
    comarca <- paste(comarca, collapse = "|")
    data_sf <- data_sf[grep(comarca, data_sf$name, ignore.case = TRUE), ]
  }
  region <- ensure_null(region)

  if (!is.null(region)) {
    tonuts <- convert_to_nuts_prov(region)

    # toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df$cpro)

    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  if (nrow(data_sf) == 0) {
    cli::cli_alert_warning(
      paste0(
        "The combination of {.arg region} and/or {.arg comarca} does not ",
        "return any result"
      )
    )
    cli::cli_alert_info("Returning empty {.cls sf} object.")
    return(data_sf)
  }

  # Move CAN
  data_sf <- move_can(data_sf, moveCAN)

  # Rematch
  data_sf <- sanitize_sf(data_sf)

  data_sf
}
