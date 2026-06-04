#' Simplified map of provinces and Autonomous Communities of Spain
#'
#' @description
#'
#' Simplified map with the boundaries of the provinces or Autonomous
#' communities of Spain, as provided by the **INE** (Instituto Nacional de
#' Estadistica).
#'
#' @details
#'
#' Results are provided **without CRS**, as provided by the source.
#'
#' You can use and mix names, ISO codes, `"codauto"` or `"cpro"` codes (see
#' [esp_codelist]) and NUTS codes of different levels.
#'
#' When using a code corresponding to a higher level (for example,
#' `esp_get_prov("Andalucia")`) all the corresponding units of that level are
#' provided (in this case, all the provinces of Andalusia).
#'
#' @param prov,ccaa Character. A vector of names, codes or both for provinces
#'   and Autonomous Communities, or `NULL` to get all the data. See
#'   **Details**.
#'
#' @inheritParams esp_get_prov
#' @inheritParams esp_get_ccaa
#' @inheritParams esp_get_nuts
#' @inherit esp_get_nuts return
#' @source INE: PC_Axis files
#'
#' @seealso [`esp_get_gridmap`][esp_get_gridmap].
#'
#' @family political
#' @encoding UTF-8
#' @rdname esp_get_simpl
#' @name esp_get_simpl
#'
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' prov_simp <- esp_get_simpl_prov()
#'
#' library(ggplot2)
#'
#' ggplot(prov_simp) +
#'   geom_sf(aes(fill = ine.ccaa.name)) +
#'   labs(fill = "Autonomous Communities")
#'
#' # Provinces of a single Autonomous Community.
#'
#' and_simple <- esp_get_simpl_prov("Andalucia")
#'
#' ggplot(and_simple) +
#'   geom_sf()
#'
#' # Autonomous Communities.
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
  # Build the download URL.
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/",
    "ine_prov_simplified.gpkg"
  )

  data_sf <- download_and_read_geo_file(
    url,
    subdir = "ine",
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )
  if (is.null(data_sf)) {
    return(NULL)
  }

  # Order features by Autonomous Community and province.
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]
  data_sf <- sanitize_sf(data_sf)
  sf::st_crs(data_sf) <- NA

  prov <- ensure_null(prov)
  if (is.null(prov)) {
    return(data_sf)
  }
  data_sf <- filter_by_cpro_region(data_sf, prov)

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
  # Build the download URL.
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/",
    "ine_ccaa_simplified.gpkg"
  )

  data_sf <- download_and_read_geo_file(
    url,
    subdir = "ine",
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )
  if (is.null(data_sf)) {
    return(NULL)
  }

  # Order features by Autonomous Community.
  data_sf <- data_sf[order(data_sf$codauto), ]
  data_sf <- sanitize_sf(data_sf)
  sf::st_crs(data_sf) <- NA

  ccaa <- ensure_null(ccaa)
  if (is.null(ccaa)) {
    return(data_sf)
  }
  data_sf <- filter_by_codauto_region(data_sf, ccaa)

  data_sf
}
