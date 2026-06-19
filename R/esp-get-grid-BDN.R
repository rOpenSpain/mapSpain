#' National geographic grids from BDN (Nature Data Bank)
#'
#' @description
#' Load an [`sf`][sf::st_sf] `POLYGON` object with the geographic grids of
#' Spain as provided by the Banco de Datos de la Naturaleza (Nature Data Bank),
#' under the Ministry of Environment (MITECO).
#'
#' This dataset provides two accessors. [esp_get_grid_BDN()] extracts
#' country-wide regular grids with resolutions of 5 x 5 or 10 x 10 kilometers
#' for mainland Spain or the Canary Islands. [esp_get_grid_BDN_ccaa()] extracts
#' 1 x 1 kilometer resolution grids for individual Autonomous Communities and
#' Cities.
#'
#' These grids are useful for biodiversity analysis, environmental monitoring,
#' and spatial statistical applications.
#'
#' @details
#' The BDN provides standardized geographic grids for Spain that follow the
#' Nature Data Bank's specifications. The data are downloaded from the
#' `sianedata/MITECO/dist` data branch and is regularly updated.
#'
#' @inheritSection esp_set_cache_dir Caching
#' @param resolution Numeric. Resolution of the grid in kilometers. Must be one
#'   of:
#'   - `5`: 5 x 5 kilometer cells.
#'   - `10`: 10 x 10 kilometer cells (default).
#' @param type Character. The geographic scope of the grid:
#'   - `"main"`: Mainland Spain (default).
#'   - `"canary"`: Canary Islands.
#'
#' @inheritParams esp_get_nuts
#' @inherit esp_get_nuts return
#' @source
#' Data sourced from the Banco de Datos de la Naturaleza (BDN). See the
#' repository structure:
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MITECO/dist>
#'
#' For more information about BDN grids and other resources, visit:
#'
#' ```{r, echo=FALSE, results='asis'}
#' cat(paste0(" <https://www.miteco.gob.es/es/biodiversidad/servicios/",
#'       "banco-datos-naturaleza/informacion-disponible/",
#'       "bdn-cart-aux-descargas-ccaa.html>."))
#' ```
#'
#' @family grids
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # Load a 10 x 10 km grid for mainland Spain.
#' grid <- esp_get_grid_BDN(resolution = 10, type = "main")
#'
#' # Visualize the grid.
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
  # Validate grid options.
  res <- match_arg_pretty(resolution)
  type <- match_arg_pretty(type)

  # Build the download URL.
  api_entry <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/",
    "sianedata/MITECO/dist/"
  )

  # Select the source file.
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

  data_sf <- download_and_read_geo_file(
    url,
    name = filename,
    subdir = "grid",
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )

  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf
}

#' @description
#' `esp_get_grid_BDN_ccaa()` provides higher-resolution 1 x 1 kilometer grids
#' for specific Autonomous Communities and Cities, useful for regional analysis
#' with finer spatial detail.
#'
#' @param ccaa Character string. A vector of names, codes or both for
#'   Autonomous Communities and Cities. See **Details** on [esp_get_ccaa()]
#'   for accepted formats.
#'
#' @seealso
#' [esp_get_ccaa()]
#'
#' @rdname esp_get_grid_BDN
#' @export
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

  # Build IDs from the NUTS code without the "ES" prefix.
  id <- gsub("ES", "", nuts_id, fixed = TRUE)

  api_entry <- paste0(
    "https://github.com/rOpenSpain/mapSpain/",
    "raw/sianedata/MITECO/dist/"
  )
  filename <- paste0("malla1x1_", id, ".gpkg")

  url <- paste0(api_entry, filename)

  data_sf <- download_and_read_geo_file(
    url,
    name = filename,
    subdir = "grid",
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )

  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf
}
