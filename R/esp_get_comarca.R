#' Get 'comarcas' of Spain as [`sf`][sf::st_sf] `POLYGON`
#'
#' @description
#' Returns 'comarcas' of Spain as `sf` `POLYGON` objects.
#'
#' @source
#' INE: PC_Axis files, IGN, Ministry of Agriculture, Fisheries and Food (MAPA).
#'
#' @return A [`sf`][sf::st_sf] polygon object.
#'
#' @family political
#'
#' @param region A vector of names and/or codes for provinces or `NULL` to get
#'   all the comarcas. See **Details**.
#'
#' @param comarca A name or [`regex`][base::grep()] expression with the names of
#'   the required comarcas. `NULL` would return all the possible comarcas.
#'
#' @param type One of `"INE"`, `"IGN"`, `"AGR"`, `"LIV"`. Type of comarca to
#'   return, see **Details**.
#'
#' @inheritParams esp_get_munic
#'
#' @inheritSection  esp_get_nuts About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @export
#'
#' @details
#'
#' ## About comarcas
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
#' ## Types
#'
#' `esp_get_comarcas()` can retrieve several types of comarcas, each one
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
#' ## Misc
#'
#' When using `region` you can use and mix names and NUTS codes
#' (levels 1, 2 or 3), ISO codes (corresponding to level 2 or 3) or
#' "cpro" (see [esp_codelist]).
#'
#' When calling a higher level (Province, Autonomous Community or NUTS1),
#' all the comarcas of that level would be added.
#'
#' ## Legal Notice
#'
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
#'
#' # Livestock Comarcas with Mountains or Alt(o,a) in the name
#'
#' comarcas_alto <- esp_get_comarca(
#'   comarca = "Montaña|Monte|Sierra|Alt",
#'   type = "LIV",
#'   epsg = 3857
#' )
#'
#' ggplot(comarcas_alto) +
#'   geom_sf(aes(fill = ine.ccaa.name)) +
#'   geom_sf_text(aes(label = name), check_overlap = TRUE) +
#'   labs(fill = "CCAA")
#' }
#'
esp_get_comarca <- function(region = NULL, comarca = NULL, moveCAN = TRUE,
                            type = c("INE", "IGN", "AGR", "LIV"),
                            epsg = "4258", update_cache = FALSE,
                            cache_dir = NULL, verbose = FALSE) {
  init_epsg <- as.character(epsg)
  type <- match.arg(type)
  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Url
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



  data_sf <- esp_hlp_dwnload_sianedata(
    api_entry = api_entry,
    filename = filename,
    cache_dir = cache_dir,
    verbose = verbose,
    update_cache = update_cache,
    cache = TRUE
  )

  if (!is.null(comarca)) {
    comarca <- paste(comarca, collapse = "|")
    data_sf <- data_sf[grep(comarca, data_sf$name, ignore.case = TRUE), ]
  }

  if (!is.null(region)) {
    tonuts <- esp_hlp_all2prov(region)

    # toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)

    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  if (nrow(data_sf) == 0) {
    stop(
      "The combination of region and/or comarca does ",
      "not return any result"
    )
  }

  # Move CAN

  # Checks

  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1


  if (moving) {
    if (length(grep("05", data_sf$codauto)) > 0) {
      penin <- data_sf[-grep("05", data_sf$codauto), ]
      can <- data_sf[grep("05", data_sf$codauto), ]

      # Move CAN
      can <- esp_move_can(can, moveCAN = moveCAN)

      # Regenerate
      if (nrow(penin) > 0) {
        data_sf <- rbind(penin, can)
      } else {
        data_sf <- can
      }
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  return(data_sf)
}
