#' Get a simplified map of provinces and autonomous communities of Spain
#'
#' @description
#' Loads a simplified map (\CRANpkg{sf} object) with the boundaries of the
#' provinces or autonomous communities of Spain, as provided by the **INE**
#' (Instituto Nacional de Estadistica).
#'
#' @rdname esp_get_simplified
#'
#' @export
#'
#' @family political
#'
#' @return A \CRANpkg{sf} POLYGON object.
#'
#' @inheritParams esp_get_prov
#'
#' @inheritParams esp_get_ccaa
#'
#' @inheritSection  esp_get_nuts About caching
#'
#' @seealso [esp_get_hex_prov()], [esp_get_hex_ccaa()]
#'
#' @source INE: PC_Axis files
#'
#' @details
#'
#' Results are provided **without CRS**, as provided on source.
#'
#' You can use and mix names, ISO codes, "codauto"/"cpro" codes (see
#' [esp_codelist]) and NUTS codes of different levels.
#'
#' When using a code corresponding of a higher level (e.g.
#' `esp_get_simpl_prov("Andalucia")`) all the corresponding units of that level
#' are provided (in this case , all the provinces of Andalucia).
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' prov_simp <- esp_get_simpl_prov()
#'
#' library(ggplot2)
#'
#' ggplot(prov_simp) +
#'   geom_sf(aes(fill = ine.ccaa.name)) +
#'   labs(fill = "CCAA")
#'
#' # Provs of Single CCAA
#'
#' and_simple <- esp_get_simpl_prov("Andalucia")
#'
#' ggplot(and_simple) +
#'   geom_sf()
#'
#' # CCAAs
#'
#' ccaa_simp <- esp_get_simpl_ccaa()
#'
#' ggplot(ccaa_simp) +
#'   geom_sf() +
#'   geom_sf_text(aes(label = ine.ccaa.name), check_overlap = TRUE)
#' }
esp_get_simpl_prov <- function(prov = NULL,
                               update_cache = FALSE,
                               cache_dir = NULL,
                               verbose = FALSE) {
  region <- prov

  # Url
  api_entry <- "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/"
  filename <- "ine_prov_simplified.gpkg"


  data_sf <- esp_hlp_dwnload_sianedata(
    api_entry = api_entry,
    filename = filename,
    cache_dir = cache_dir,
    verbose = verbose,
    update_cache = update_cache,
    cache = TRUE
  )



  region <- unique(region)


  if (!is.null(region)) {
    region <- esp_hlp_all2prov(region)

    region <- unique(region)
    if (length(region) == 0) {
      stop(
        "region ",
        paste0("'", region, "'", collapse = ", "),
        " is not a valid name"
      )
    }

    dfcpro <- mapSpain::esp_codelist
    dfcpro <- unique(dfcpro[, c("nuts3.code", "cpro")])
    cprocodes <-
      unique(dfcpro[dfcpro$nuts3.code %in% region, ]$cpro)

    data_sf <- data_sf[data_sf$cpro %in% cprocodes, ]
  }

  # Order
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]

  sf::st_crs(data_sf) <- NA


  return(data_sf)
}

#' @rdname esp_get_simplified
#'
#' @export
esp_get_simpl_ccaa <- function(ccaa = NULL,
                               update_cache = FALSE,
                               cache_dir = NULL,
                               verbose = FALSE) {
  region <- ccaa

  # Url
  api_entry <- "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/"
  filename <- "ine_ccaa_simplified.gpkg"


  data_sf <- esp_hlp_dwnload_sianedata(
    api_entry = api_entry,
    filename = filename,
    cache_dir = cache_dir,
    verbose = verbose,
    update_cache = update_cache,
    cache = TRUE
  )



  region <- unique(region)


  if (!is.null(region)) {
    nuts_id <- esp_hlp_all2ccaa(region)
    # to codauto
    codauto <- esp_dict_region_code(nuts_id,
      origin = "nuts",
      destination = "codauto"
    )


    codauto <- unique(codauto)
    codauto <- codauto[!is.na(codauto)]
    if (length(codauto) == 0) {
      stop(
        "region ",
        paste0("'", region, "'", collapse = ", "),
        " is not a valid name"
      )
    }

    data_sf <- data_sf[data_sf$codauto %in% codauto, ]
  }

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  sf::st_crs(data_sf) <- NA

  return(data_sf)
}
