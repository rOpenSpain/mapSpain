#' Simplified map of provinces and autonomous communities of Spain
#'
#' @description
#'
#' Simplified map with the boundaries of the
#' provinces or autonomous communities of Spain, as provided by the **INE**
#' (Instituto Nacional de Estadistica).
#'
#' @rdname esp_get_simpl
#'
#' @encoding UTF-8
#' @family political
#' @inheritParams esp_get_prov
#' @inheritParams esp_get_ccaa
#' @inheritParams esp_get_nuts
#' @inherit esp_get_nuts return
#' @export
#'
#' @param prov,ccaa character. A vector of names and/or codes for provinces
#'   and autonomous communities or` `NULL to get all the data. See **Details**.
#'
#' @seealso [`esp_get_gridmap`][esp_get_gridmap].
#'
#' @source INE: PC_Axis files
#'
#' @details
#'
#' Results are provided **without CRS**, as provided on source.
#'
#' You can use and mix names, ISO codes, `"codauto"/ "cpro"` codes (see
#' [esp_codelist]) and NUTS codes of different levels.
#'
#' When using a code corresponding of a higher level (e.g.
#' `esp_get_prov("Andalucia")`) all the corresponding units of that level are
#' provided (in this case , all the provinces of Andalusia).
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
esp_get_simpl_prov <- function(
  prov = NULL,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  # Url
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/",
    "ine_prov_simplified.gpkg"
  )

  file_local <- download_url(
    url,
    cache_dir = cache_dir,
    subdir = "ine",
    update_cache = update_cache,
    verbose = verbose
  )
  if (is.null(file_local)) {
    return(NULL)
  }

  data_sf <- read_geo_file_sf(file_local)

  # Order
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]
  data_sf <- sanitize_sf(data_sf)
  sf::st_crs(data_sf) <- NA

  prov <- ensure_null(prov)
  if (is.null(prov)) {
    return(data_sf)
  }
  region <- convert_to_nuts_prov(prov)

  dfcpro <- mapSpain::esp_codelist
  dfcpro <- unique(dfcpro[, c("nuts3.code", "cpro")])
  cprocodes <- unique(dfcpro[dfcpro$nuts3.code %in% region, ]$cpro)

  data_sf <- data_sf[data_sf$cpro %in% cprocodes, ]

  data_sf
}

#' @rdname esp_get_simpl
#'
#' @export
esp_get_simpl_ccaa <- function(
  ccaa = NULL,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  # Url
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/",
    "ine_ccaa_simplified.gpkg"
  )

  file_local <- download_url(
    url,
    cache_dir = cache_dir,
    subdir = "ine",
    update_cache = update_cache,
    verbose = verbose
  )
  if (is.null(file_local)) {
    return(NULL)
  }

  data_sf <- read_geo_file_sf(file_local)

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]
  data_sf <- sanitize_sf(data_sf)
  sf::st_crs(data_sf) <- NA

  ccaa <- ensure_null(ccaa)
  if (is.null(ccaa)) {
    return(data_sf)
  }
  nuts_id <- convert_to_nuts_ccaa(ccaa)
  dfcodauto <- mapSpain::esp_codelist
  dfcodauto <- unique(dfcodauto[, c("nuts2.code", "codauto")])
  dfcodauto <- unique(dfcodauto[dfcodauto$nuts2.code %in% nuts_id, ]$codauto)

  data_sf <- data_sf[data_sf$codauto %in% dfcodauto, ]

  data_sf
}
