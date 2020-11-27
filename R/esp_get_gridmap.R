#' @title Get an hexbin or a map of squares of Spain
#' @name esp_get_gridmap
#' @description Loads a hexbin map (\code{sf} object) or a map of squares
#' with the boundaries of the provinces or autonomous communities of Spain.
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
#' library(sf)
#' library(cartography)
#'
#' esp <- st_transform(esp_get_country(), 3857)
#'
#' hexccaa <- st_transform(esp_get_hex_ccaa(), 3857)
#'
#' plot_sf(hexccaa)
#' plot(st_geometry(esp),
#'      col = "grey80",
#'      border = NA,
#'      add = TRUE)
#' plot(st_geometry(hexccaa),
#'      col = hcl.colors(19, alpha = 0.5),
#'      add = TRUE)
#' labelLayer(hexccaa, txt = "label")
#'
#'
#'
#' hexprov <- st_transform(esp_get_hex_prov(), 3857)
#'
#' plot_sf(hexprov)
#' plot(st_geometry(esp),
#'      col = "grey80",
#'      border = NA,
#'      add = TRUE)
#' plot(st_geometry(hexprov),
#'      col = hcl.colors(19, alpha = 0.5),
#'      add = TRUE)
#' labelLayer(hexprov, txt = "label")
#'
#'
#'
#' gridccaa <- st_transform(esp_get_grid_ccaa(), 3857)
#'
#' plot_sf(gridccaa)
#' plot(st_geometry(esp),
#'      col = "grey80",
#'      border = NA,
#'      add = TRUE)
#' plot(st_geometry(gridccaa),
#'      col = hcl.colors(19, alpha = 0.5),
#'      add = TRUE)
#' labelLayer(gridccaa, txt = "label")
#'
#' gridprov <- st_transform(esp_get_grid_prov(), 3857)
#'
#' plot_sf(gridprov)
#' plot(st_geometry(esp),
#'      col = "grey80",
#'      border = NA,
#'      add = TRUE)
#' plot(st_geometry(gridprov),
#'      col = hcl.colors(19, alpha = 0.5),
#'      add = TRUE)
#' labelLayer(gridprov, txt = "label")
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

#' @rdname esp_get_gridmap
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

#' @rdname esp_get_gridmap
#' @export
esp_get_grid_prov <- function(prov = NULL) {
  region <- prov
  data.sf <- esp_grid_prov

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

#' @rdname esp_get_gridmap
#' @export
esp_get_grid_ccaa <- function(ccaa = NULL) {
  region <- ccaa

  data.sf <- esp_grid_ccaa

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

