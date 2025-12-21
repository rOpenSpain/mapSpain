#' Get a [`sf`][sf::st_sf] hexbin or squared `POLYGON` of Spain
#'
#' @description
#' Loads a hexbin map ([`sf`][sf::st_sf] object) or a map of squares with the
#' boundaries of the provinces or autonomous communities of Spain.
#'
#' @rdname esp_get_gridmap
#' @name esp_get_gridmap
#' @family political
#' @export
#' @inherit esp_get_nuts return
#'
#' @param prov,ccaa character. A vector of names and/or codes for provinces
#'   and autonomous communities or` `NULL to get all the data. See **Details**.
#'
#' @seealso [`esp_get_simpl`][esp_get_simpl].
#'
#' @details
#'
#' Hexbin (or grid) maps have an advantage over traditional choropleth maps.
#' In choropleths, regions with larger polygons tend to appear more prominent
#' simply because of their size, which introduces visual bias. With hexbin
#' maps, each region is represented equally, reducing this bias.
#'
#' You can use and mix names, ISO codes, `"codauto"/ "cpro"` codes (see
#' [esp_codelist]) and NUTS codes of different levels.
#'
#' When using a code corresponding of a higher level (e.g.
#' `esp_get_prov("Andalucia")`) all the corresponding units of that level are
#' provided (in this case , all the provinces of Andalusia).
#'
#'
#' Results are provided in **EPSG:4258**, use [sf::st_transform()]
#' to change the projection.
#'
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' esp <- esp_get_country()
#' hexccaa <- esp_get_hex_ccaa()
#'
#' library(ggplot2)
#'
#' ggplot(hexccaa) +
#'   geom_sf(data = esp) +
#'   geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
#'   geom_sf_text(aes(label = label), check_overlap = TRUE) +
#'   theme_void() +
#'   labs(title = "Hexbin: CCAA")
#'
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
#'
#' gridccaa <- esp_get_grid_ccaa()
#'
#' ggplot(gridccaa) +
#'   geom_sf(data = esp) +
#'   geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
#'   geom_sf_text(aes(label = label), check_overlap = TRUE) +
#'   theme_void() +
#'   labs(title = "Grid: CCAA")
#'
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

#' Internal funs for easier maintenance
#' @noRd
get_gridmap_prov <- function(prov = NULL, type = "hex") {
  data_sf <- switch(type,
    "hex" = esp_hexbin_prov,
    esp_grid_prov
  )
  # Order
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]
  data_sf <- sanitize_sf(data_sf)

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

get_gridmap_ccaa <- function(ccaa = NULL, type = "hex") {
  data_sf <- switch(type,
    "hex" = esp_hexbin_ccaa,
    esp_grid_ccaa
  )
  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]
  data_sf <- sanitize_sf(data_sf)

  ccaa <- ensure_null(ccaa)
  if (is.null(ccaa)) {
    return(data_sf)
  }
  nuts_id <- convert_to_nuts_ccaa(ccaa)
  data_sf <- data_sf[data_sf$nuts2.code %in% nuts_id, ]

  data_sf
}
