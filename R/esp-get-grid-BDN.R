#' Get [`sf`][sf::st_sf] `POLYGON` with the national geographic grids from BDN
#'
#' @description
#' Loads a [`sf`][sf::st_sf] `POLYGON` with the geographic grids of Spain as
#' provided on the Banco de Datos de la Naturaleza (Nature Data Bank), by the
#' Ministry of Environment (MITECO):
#'   - [esp_get_grid_BDN()] extracts country-wide grids with resolutions
#'     5x5 or 10x10 kms.
#'   - [esp_get_grid_BDN_ccaa()] extracts grids by Autonomous Community with
#'     resolution 1x1 km.
#'
#' @family grids
#'
#' @return A [`sf`][sf::st_sf] `POLYGON`.
#'
#'
#' @source
#' BDN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>).
#'
#' See original metadata and source on
#'
#' ```{r, echo=FALSE, results='asis'}
#' cat(paste0(" <https://www.miteco.gob.es/es/biodiversidad/servicios/",
#'       "banco-datos-naturaleza/informacion-disponible/",
#'       "bdn-cart-aux-descargas-ccaa.html>"))
#'
#' ```
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
esp_get_grid_BDN <- function(
  resolution = c(10, 5),
  type = c("main", "canary"),
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  # Check grid
  res <- match_arg_pretty(resolution)
  type <- match_arg_pretty(type)

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

  url <- paste0(api_entry, filename)

  data_sf <- download_url(
    url,
    name = filename,
    cache_dir = cache_dir,
    subdir = "grids",
    update_cache = update_cache,
    verbose = verbose
  )

  if (is.null(data_sf)) {
    return(NULL)
  }

  read_geo_file_sf(data_sf)
}

#' @rdname esp_get_grid_BDN
#' @export
#' @param ccaa A vector of names and/or codes for autonomous communities.
#'   See **Details** on [esp_get_ccaa()].
#' @seealso [esp_get_ccaa()]

esp_get_grid_BDN_ccaa <- function(
  ccaa,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  if (missing(ccaa)) {
    cli::cli_abort("{.arg ccaa} can't be missing value.")
  }

  ccaa <- ccaa[!is.na(ccaa)]

  region <- ccaa
  nuts_id <- esp_hlp_all2ccaa(region)

  nuts_id <- unique(nuts_id)

  # Check if it is a valid NUTS, if not throws an error

  data <- mapSpain::esp_codelist

  if (!nuts_id %in% data$nuts2.code) {
    cli::cli_abort("{.arg ccaa = {ccaa}} not mapped to a known CCAA.")
  }

  # Switch name. The ids are the same than the NUTS code removing the "ES" part
  id <- gsub("ES", "", nuts_id)

  api_entry <- paste0(
    "https://github.com/rOpenSpain/mapSpain/",
    "raw/sianedata/MITECO/dist/"
  )
  filename <- paste0("malla1x1_", id, ".gpkg")

  url <- paste0(api_entry, filename)

  data_sf <- download_url(
    url,
    name = filename,
    cache_dir = cache_dir,
    subdir = "grid",
    update_cache = update_cache,
    verbose = verbose
  )

  if (is.null(data_sf)) {
    return(NULL)
  }

  read_geo_file_sf(data_sf)
}
