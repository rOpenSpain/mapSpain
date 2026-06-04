#' Comarcas of Spain
#'
#' @description
#' Returns
#' [Comarcas of
#' Spain](https://en.wikipedia.org/wiki/Comarcas_of_Spain). Comarcas are
#' traditional informal territorial divisions, comprising several municipalities
#' sharing geographical, economic or cultural traits, typically with
#' poorly defined limits.
#'
#' @details
#' When using `region` you can use and mix names and NUTS codes
#' (levels 1, 2 or 3), ISO codes (corresponding to level 2 or 3) or
#' "cpro" (see [esp_codelist]).
#'
#' When calling a higher level (province, Autonomous Community or NUTS1),
#' all the comarcas of that level will be added.
#'
#' # About comarcas
#'
#' Comarcas (English equivalent: district, county, area or zone) do not
#' always have a formal legal status. They correspond mainly to natural areas
#' (valleys, river basins and similar areas), historical regions or ancient
#' kingdoms.
#'
#' In the case of Spain, comarcas only have an administrative character legally
#' recognized in Catalonia, the Basque Country, Navarra (named merindades
#' instead), in the region of El Bierzo (Castilla y Leon) and Aragon. Galicia,
#' the Principality of Asturias and Andalusia have functional comarcas.
#'
#' # Types
#'
#' `esp_get_comarca()` can retrieve several types of comarcas, each one
#' provided under different classification criteria.
#' - `"INE"`: Comarcas defined by the National Statistics Institute (INE).
#' - `"IGN"`: Official comarcas, only available in some Autonomous Communities,
#'   provided by the National Geographic Institute.
#' - `"AGR"`: Agrarian comarcas defined by the Ministry of Agriculture,
#'   Fisheries and Food (MAPA).
#' - `"LIV"`: Livestock comarcas defined by the Ministry of Agriculture,
#'   Fisheries and Food (MAPA).
#'
#' @param region Character string. A vector of names, codes or both for
#'   provinces, or `NULL` to get all the comarcas. See **Details**.
#' @param comarca Character string. A name or [`regex`][base::grep()] expression
#'   with the names of the required comarcas. `NULL` will return all the
#'   possible comarcas.
#' @param type Character string. One of `"INE"`, `"IGN"`, `"AGR"`, `"LIV"`.
#'   Type of comarca to return. See **Details**.
#'
#' @inheritParams esp_get_prov
#' @inheritParams esp_get_nuts
#' @inherit esp_get_nuts return
#' @source
#' INE: PC_Axis files, IGN, Ministry of Agriculture, Fisheries and Food (MAPA).
#'
#' @note
#' The use of the information contained on the
#' [INE website](https://www.ine.es/en/index.htm) may be carried out by users or
#' re-use agents, at their own risk, and they will be the sole liable parties
#' in the case of having to answer to third parties due to damages arising
#' from such use.
#'
#' @family political
#' @encoding UTF-8
#' @export
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
#' # Legal comarcas of Catalunya
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
  init_epsg <- validate_epsg(epsg)
  type <- match_arg_pretty(type)

  # URL
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

  data_sf <- download_and_read_geo_file(
    url,
    subdir = "comarcas",
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )

  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf <- filter_by_name_pattern(data_sf, comarca, "name")
  data_sf <- filter_by_cpro_region(data_sf, region)

  if (nrow(data_sf) == 0) {
    return(return_empty_combination_sf(data_sf, "comarca"))
  }

  # Move the Canary Islands.
  data_sf <- move_can(data_sf, moveCAN)

  # Rematch
  data_sf <- sanitize_sf(data_sf)

  data_sf
}
