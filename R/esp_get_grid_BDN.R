#' Get \CRANpkg{sf} polygons of the national geographic grids provided by BDN
#'
#' @description
#' Loads a \CRANpkg{sf} polygon with the geographic grids of Spain as provided
#' on the Banco de Datos de la Naturaleza (Nature Data Bank), by the Ministry
#' of Environment (MITECO):
#'   * [esp_get_grid_BDN()] extracts country-wide grids with resolutions
#'     5x5 or 10x10 kms.
#'   * [esp_get_grid_BDN_ccaa()] extracts grids by Autonomous Community with
#'     resolution 1x1 km.
#'
#' @family grids
#'
#' @return A \CRANpkg{sf} polygon
#'
#'
#' @source BDN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>).
#'
#' See original metadata and source on
#' <https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/bdn-cart-aux-descargas-ccaa.html>
#'
#' @export
#'
#' @param resolution Resolution of the grid in kms. Could be `5` or `10`.
#' @param type The scope of the grid. It could be mainland Spain (`"main"`) or
#'   the Canary Islands (`"canary"`).
#'
#' @inheritParams esp_get_nuts
#'
#' @inheritSection esp_get_nuts About caching
#' @examplesIf esp_check_access()
#' \donttest{
#' grid <- esp_get_grid_BDN(resolution = "10", type = "main")
#'
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf() +
#'   theme_light() +
#'   labs(title = "BDN Grid for Spain")
#' }
esp_get_grid_BDN <- function(resolution = 10,
                             type = "main",
                             update_cache = FALSE,
                             cache_dir = NULL,
                             verbose = FALSE) {
  # Check grid
  res <- as.numeric(resolution)

  if (!res %in% c(5, 10)) {
    stop("resolution should be one of 5, 10")
  }

  if (!type %in% c("main", "canary")) {
    stop("type should be one of 'main', 'canary'")
  }


  # Url
  api_entry <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/",
    "sianedata/MITECO/dist/"
  )

  # Filename
  if (res == 10) {
    filename <- switch(type,
      "main" = "Malla10x10_Ter_p.gpkg",
      "Malla10x10_Ter_c.gpkg"
    )
  } else {
    filename <- switch(type,
      "main" = "Malla_5x5_tierra_p.gpkg",
      "Malla_5x5_tierra_c.gpkg"
    )
  }
  result <- esp_hlp_dwnload_sianedata(
    api_entry = api_entry,
    filename = filename,
    cache_dir = cache_dir,
    verbose = verbose,
    update_cache = update_cache,
    cache = TRUE
  )

  return(result)
}

#' @rdname esp_get_grid_BDN
#' @export
#' @param ccaa A vector of names and/or codes for autonomous communities.
#'   See **Details** on [esp_get_ccaa()].
#' @seealso [esp_get_ccaa()]

esp_get_grid_BDN_ccaa <- function(ccaa,
                                  update_cache = FALSE,
                                  cache_dir = NULL,
                                  verbose = FALSE) {
  # Get region id

  ccaa <- ccaa[!is.na(ccaa)]


  region <- ccaa
  if (is.null(region)) {
    stop("ccaa can't be null")
  } else {
    nuts_id <- esp_hlp_all2ccaa(region)

    nuts_id <- unique(nuts_id)
  }

  # Check if it is a valid NUTS, if not throws an error

  data <- mapSpain::esp_codelist

  if (!nuts_id %in% data$nuts2.code) stop(ccaa, " is not a CCAA")


  # Switch name. The ids are the same than the NUTS code removing the "ES" part
  id <- gsub("ES", "", nuts_id)


  api_entry <- paste0(
    "https://github.com/rOpenSpain/mapSpain/",
    "raw/sianedata/MITECO/dist/"
  )
  filename <- paste0("malla1x1_", id, ".gpkg")

  result <- esp_hlp_dwnload_sianedata(
    api_entry = api_entry,
    filename = filename,
    cache_dir = cache_dir,
    verbose = verbose,
    update_cache = update_cache,
    cache = TRUE
  )


  return(result)
}
