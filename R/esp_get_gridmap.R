#' Get an hexbin or a map of squares of Spain
#'
#' @description
#' Loads a hexbin map (`sf` object) or a map of squares with the boundaries of
#' the provinces or autonomous communities of Spain.
#'
#' @rdname esp_get_gridmap
#'
#' @concept political
#'
#' @return A `POLYGON` object.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @seealso
#' [esp_get_nuts()], [esp_get_ccaa()], [esp_get_prov()], [esp_get_munic()],
#' [esp_codelist]
#'
#' @export
#'
#' @inheritParams esp_get_prov
#'
#' @inheritParams esp_get_ccaa
#'
#' @details
#'
#' Hexbin or grid map has an advantage over usual choropleth maps.
#' In choropleths, a large polygon data looks more emphasized just because
#' of its size, what introduces a bias. Here with hexbin, each region is
#' represented equally dismissing the bias.
#'
#' Results are provided in **EPSG:4258**, use [sf::st_transform()]
#' to change the projection.
#'
#' See  [esp_get_ccaa()], [esp_get_prov()] for Details.
#'
#' @examples
#'
#' library(sf)
#' library(cartography)
#'
#' esp <- st_transform(esp_get_country(), 3857)
#'
#' hexccaa <- st_transform(esp_get_hex_ccaa(), 3857)
#'
#' plot_sf(hexccaa)
#' plot(st_geometry(esp),
#'   col = "grey80",
#'   border = NA,
#'   add = TRUE
#' )
#' plot(st_geometry(hexccaa),
#'   col = hcl.colors(19, alpha = 0.5),
#'   add = TRUE
#' )
#' labelLayer(hexccaa, txt = "label")
#'
#'
#'
#' hexprov <- st_transform(esp_get_hex_prov(), 3857)
#'
#' plot_sf(hexprov)
#' plot(st_geometry(esp),
#'   col = "grey80",
#'   border = NA,
#'   add = TRUE
#' )
#' plot(st_geometry(hexprov),
#'   col = hcl.colors(19, alpha = 0.5),
#'   add = TRUE
#' )
#' labelLayer(hexprov, txt = "label")
#'
#'
#'
#' gridccaa <- st_transform(esp_get_grid_ccaa(), 3857)
#'
#' plot_sf(gridccaa)
#' plot(st_geometry(esp),
#'   col = "grey80",
#'   border = NA,
#'   add = TRUE
#' )
#' plot(st_geometry(gridccaa),
#'   col = hcl.colors(19, alpha = 0.5),
#'   add = TRUE
#' )
#' labelLayer(gridccaa, txt = "label")
#'
#' gridprov <- st_transform(esp_get_grid_prov(), 3857)
#'
#' plot_sf(gridprov)
#' plot(st_geometry(esp),
#'   col = "grey80",
#'   border = NA,
#'   add = TRUE
#' )
#' plot(st_geometry(gridprov),
#'   col = hcl.colors(19, alpha = 0.5),
#'   add = TRUE
#' )
#' labelLayer(gridprov, txt = "label")
esp_get_hex_prov <- function(prov = NULL) {
  region <- prov
  data_sf <- esp_hexbin_prov

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

  return(data_sf)
}

#' @rdname esp_get_gridmap
#'
#' @concept political
#'
#' @export
esp_get_hex_ccaa <- function(ccaa = NULL) {
  region <- ccaa

  data_sf <- esp_hexbin_ccaa

  region <- unique(region)


  if (!is.null(region)) {
    nuts_id <- esp_hlp_all2ccaa(region)

    nuts_id <- unique(nuts_id)
    if (length(nuts_id) == 0) {
      stop(
        "region ",
        paste0("'", region, "'", collapse = ", "),
        " is not a valid name"
      )
    }

    data_sf <- data_sf[data_sf$nuts2.code %in% nuts_id, ]
  }

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  return(data_sf)
}

#' @rdname esp_get_gridmap
#'
#' @concept political
#'
#' @export
esp_get_grid_prov <- function(prov = NULL) {
  region <- prov
  data_sf <- esp_grid_prov

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

  return(data_sf)
}

#' @rdname esp_get_gridmap
#'
#' @concept political
#'
#' @export
esp_get_grid_ccaa <- function(ccaa = NULL) {
  region <- ccaa

  data_sf <- esp_grid_ccaa

  region <- unique(region)


  if (!is.null(region)) {
    nuts_id <- esp_hlp_all2ccaa(region)

    nuts_id <- unique(nuts_id)
    if (length(nuts_id) == 0) {
      stop(
        "region ",
        paste0("'", region, "'", collapse = ", "),
        " is not a valid name"
      )
    }

    data_sf <- data_sf[data_sf$nuts2.code %in% nuts_id, ]
  }

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  return(data_sf)
}
