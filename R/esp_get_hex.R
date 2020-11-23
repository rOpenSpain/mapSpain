#' @title Get an hexbin map with the boundaries of Spain
#' @name esp_get_hex
#' @description Loads a hexbin map (\code{sf} object) with the
#' boundaries of the provinces or autonomous communities of Spain.
#' @return A \code{POLYGON} object.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @seealso \link{esp_get_nuts}, \link{esp_get_ccaa}, \link{esp_get_prov},
#' \link{esp_get_munic}, \link{esp_codelist}
#' @export
#'
#' @param prov See \link{esp_get_prov}
#' @param ccaa See \link{esp_get_ccaa}
#' @details Hexbin or grid map has an advantage over usual choropleth maps.
#' In choropleths, a large polygon data looks more emphasized just because
#' of its size, what introduces a bias. Here with hexbin, each region is
#' represented equally dismissing the bias.
#' @examples
#'
#' library(sf)
#'
#'
#' ccaa <- esp_get_hex_ccaa()
#' plot(st_geometry(ccaa), col = hcl.colors(4))
#'
#' prov <- esp_get_hex_prov()
#' plot(st_geometry(prov), col = hcl.colors(15))
esp_get_hex_prov <- function(prov = NULL) {
  region <- prov
  data.sf <- esp_hexbin_prov

  region <- unique(region)

  if (!is.null(region)) {
    region <- esp_hlp_all2prov(region)

    region <- unique(region)
    if (length(region) == 0)
      stop("region ",
           paste0("'", region, "'", collapse = ", "),
           " is not a valid name")

    dfcpro <- mapSpain::esp_codelist
    dfcpro <- unique(dfcpro[, c("nuts3.code", "cpro")])
    cprocodes <-
      unique(dfcpro[dfcpro$nuts3.code %in% region, ]$cpro)

    data.sf <- data.sf[data.sf$cpro %in% cprocodes, ]
  }

  # Order
  data.sf <- data.sf[order(data.sf$codauto, data.sf$cpro), ]

  return(data.sf)
}

#' @rdname esp_get_hex
#' @export
esp_get_hex_ccaa <- function(ccaa = NULL) {
  region <- ccaa

  data.sf <- esp_hexbin_ccaa

  region <- unique(region)


  if (!is.null(region)) {
    nuts_id <- esp_hlp_all2ccaa(region)

    nuts_id <- unique(nuts_id)
    if (length(nuts_id) == 0)
      stop("region ",
           paste0("'", region, "'", collapse = ", "),
           " is not a valid name")

    data.sf <- data.sf[data.sf$nuts2.code %in% nuts_id, ]
  }

  # Order
  data.sf <- data.sf[order(data.sf$codauto), ]

  return(data.sf)
}
