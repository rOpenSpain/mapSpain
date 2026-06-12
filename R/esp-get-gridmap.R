#' Get a [`sf`][sf::st_sf] hexbin or squared `POLYGON` of Spain
#'
#' @description
#' Loads a hexbin map ([`sf`][sf::st_sf] object) or a map of squares with the
#' boundaries of the provinces or Autonomous Communities of Spain.
#'
#' @details
#'
#' Hexbin (or grid) maps have an advantage over traditional choropleth maps.
#' In choropleths, regions with larger polygons tend to appear more prominent
#' simply because of their size, which introduces visual bias. With hexbin
#' maps, each region is represented equally, reducing this bias.
#'
#' You can use and mix names, ISO codes, `"codauto"` or `"cpro"` codes (see
#' [esp_codelist]) and NUTS codes of different levels.
#'
#' When using a code corresponding to a higher level (for example,
#' `esp_get_prov("Andalucia")`) all the corresponding units of that level are
#' provided (in this case, all the provinces of Andalusia).
#'
#' Results are provided in **EPSG:4258**. Use [sf::st_transform()]
#' to change the projection.
#'
#' @param prov,ccaa Character. A vector of names, codes or both for provinces
#'   and Autonomous Communities, or `NULL` to get all the data. See
#'   **Details**.
#'
#' @inherit esp_get_nuts return
#'
#' @seealso [esp_get_simpl()].
#'
#' @family political
#' @encoding UTF-8
#' @rdname esp_get_gridmap
#' @name esp_get_gridmap
#' @export
#' @examplesIf esp_check_access()
#' \donttest{
#' esp <- esp_get_spain()
#' hexccaa <- esp_get_hex_ccaa()
#'
#' library(ggplot2)
#'
#' ggplot(hexccaa) +
#'   geom_sf(data = esp) +
#'   geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
#'   geom_sf_text(aes(label = label), check_overlap = TRUE) +
#'   theme_void() +
#'   labs(title = "Hexbin: Autonomous Communities")
#'
#' hexprov <- esp_get_hex_prov()
#'
#' ggplot(hexprov) +
#'   geom_sf(data = esp) +
#'   geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
#'   geom_sf_text(aes(label = label), check_overlap = TRUE) +
#'   theme_void() +
#'   labs(title = "Hexbin: Provinces")
#'
#' gridccaa <- esp_get_grid_ccaa()
#'
#' ggplot(gridccaa) +
#'   geom_sf(data = esp) +
#'   geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
#'   geom_sf_text(aes(label = label), check_overlap = TRUE) +
#'   theme_void() +
#'   labs(title = "Grid: Autonomous Communities")
#'
#' gridprov <- esp_get_grid_prov()
#'
#' ggplot(gridprov) +
#'   geom_sf(data = esp) +
#'   geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
#'   geom_sf_text(aes(label = label), check_overlap = TRUE) +
#'   theme_void() +
#'   labs(title = "Grid: Provinces")
#' }
esp_get_hex_prov <- function(prov = NULL) {
  get_gridmap_prov(prov = prov, type = "hex")
}

#' @rdname esp_get_gridmap
#'
#' @export
esp_get_hex_ccaa <- function(ccaa = NULL) {
  get_gridmap_ccaa(ccaa = ccaa, type = "hex")
}

#' @rdname esp_get_gridmap
#'
#' @export
esp_get_grid_prov <- function(prov = NULL) {
  get_gridmap_prov(prov = prov, type = "grid")
}

#' @rdname esp_get_gridmap
#'
#' @export
esp_get_grid_ccaa <- function(ccaa = NULL) {
  get_gridmap_ccaa(ccaa = ccaa, type = "grid")
}

#' Internal functions for easier maintenance
#' @noRd
get_gridmap_prov <- function(prov = NULL, type = "hex") {
  data_sf <- switch(type,
    "hex" = esp_hexbin_prov,
    esp_grid_prov
  )
  # Order grid cells.
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]
  data_sf <- sanitize_sf(data_sf)

  prov <- ensure_null(prov)
  if (is.null(prov)) {
    return(data_sf)
  }
  data_sf <- filter_by_cpro_region(data_sf, prov)

  data_sf
}

get_gridmap_ccaa <- function(ccaa = NULL, type = "hex") {
  data_sf <- switch(type,
    "hex" = esp_hexbin_ccaa,
    esp_grid_ccaa
  )
  # Order grid cells.
  data_sf <- data_sf[order(data_sf$codauto), ]
  data_sf <- sanitize_sf(data_sf)

  ccaa <- ensure_null(ccaa)
  if (is.null(ccaa)) {
    return(data_sf)
  }
  data_sf <- filter_by_codauto_region(data_sf, ccaa)

  data_sf
}
