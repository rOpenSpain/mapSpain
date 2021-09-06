#' Get a `sf` hexbin or squared polygon of Spain
#'
#' @description
#' Loads a hexbin map (`sf` object) or a map of squares with the boundaries of
#' the provinces or autonomous communities of Spain.
#'
#' @rdname esp_get_gridmap
#' @name  esp_get_gridmap
#'
#' @family political
#'
#' @return A `sf` POLYGON object.
#'
#'
#' @export
#'
#' @inheritParams esp_get_prov
#'
#' @inheritParams esp_get_ccaa
#'
#' @inheritSection  esp_get_nuts  About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @details
#'
#' Hexbin or grid map has an advantage over usual choropleth maps.
#' In choropleths, a large polygon data looks more emphasized just because
#' of its size, what introduces a bias. Here with hexbin, each region is
#' represented equally dismissing the bias.
#'
#' You can use and mix names, ISO codes, "codauto"/"cpro" codes (see
#' [esp_codelist]) and NUTS codes of different levels.
#'
#' When using a code corresponding of a higher level (e.g.
#' `esp_get_prov("Andalucia")`) all the corresponding units of that level are
#' provided (in this case , all the provinces of Andalucia).
#'
#'
#' Results are provided in **EPSG:4258**, use [sf::st_transform()]
#' to change the projection.
#'
#'
#' @example inst/examples/esp_get_gridmap.R
#'
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
