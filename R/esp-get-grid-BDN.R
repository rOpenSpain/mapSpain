#' National geographic grids from BDN (Nature Data Bank)
#'
#' @description
#' Loads a [`sf`][sf::st_sf] `POLYGON` object with the geographic grids of
#' Spain as provided by the Banco de Datos de la Naturaleza (Nature Data Bank),
#' under the Ministry of Environment (MITECO).
#'
#' This dataset provides:
#'   - [esp_get_grid_BDN()] extracts country-wide regular grids with resolutions
#'     of 5x5 or 10x10 kilometres (mainland Spain or Canary Islands).
#'   - [esp_get_grid_BDN_ccaa()] extracts 1x1 kilometre resolution grids for
#'     individual Autonomous Communities.
#'
#' These grids are useful for biodiversity analysis, environmental monitoring,
#' and spatial statistical applications.
#'
#' @encoding UTF-8
#' @family grids
#' @inheritParams esp_get_nuts
#' @inherit esp_get_nuts return
#' @export
#'
#' @details
#' The BDN provides standardized geographic grids for Spain that follow the
#' Nature Data Bank's specifications. The data is maintained via a custom CDN
#' and is regularly updated.
#'
#' @source
#' Data sourced from the Banco de Datos de la Naturaleza (BDN) via a custom
#' CDN. See the repository structure:
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>
#'
#' For more information about BDN grids and other resources, visit:
#'
#' ```{r, echo=FALSE, results='asis'}
#' cat(paste0(" <https://www.miteco.gob.es/es/biodiversidad/servicios/",
#'       "banco-datos-naturaleza/informacion-disponible/",
#'       "bdn-cart-aux-descargas-ccaa.html>."))
#' ```
#'
#' @param resolution numeric. Resolution of the grid in kilometres.
#'   Must be one of:
#'   * `5`: 5x5 kilometre cells
#'   * `10`: 10x10 kilometre cells (default)
#' @param type character. The geographic scope of the grid:
#'   * `"main"`: Mainland Spain (default)
#'   * `"canary"`: Canary Islands
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # Load a 10x10 km grid for mainland Spain
#' grid <- esp_get_grid_BDN(resolution = 10, type = "main")
#'
#' # Visualize the grid
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf(fill = NA, color = "steelblue") +
#'   theme_light() +
#'   labs(title = "BDN Geographic Grid: 10x10 km Spain")
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
    subdir = "grid",
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
#'
#' @description
#' `esp_get_grid_BDN_ccaa()` provides higher-resolution 1x1 kilometre grids
#' for specific Autonomous Communities, useful for regional analysis with
#' finer spatial detail.
#'
#' @param ccaa character string. A vector of names and/or codes for Autonomous
#'   Communities. See **Details** on [esp_get_ccaa()] for accepted formats.
#'
#' @seealso
#' [esp_get_ccaa()]
#'
esp_get_grid_BDN_ccaa <- function(
  ccaa,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  ccaa <- validate_non_empty_arg(ccaa)

  ccaa <- ccaa[!is.na(ccaa)]

  region <- ccaa
  nuts_id <- convert_to_nuts_ccaa(region)

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
