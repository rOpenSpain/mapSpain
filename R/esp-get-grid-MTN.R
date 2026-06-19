#' National geographic grids from IGN MTN (Mapa Topografico Nacional)
#'
#' @description
#' Loads a [`sf`][sf::st_sf] `POLYGON` with the geographic grids of Spain.
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>.
#'
#' Possible values of `grid` are:
#'
#' ```{r, echo=FALSE}
#'
#' df <- data.frame(grid_name = c(
#'   "MTN25_ED50_Peninsula_Baleares",
#'   "MTN25_ETRS89_ceuta_melilla_alboran",
#'   "MTN25_ETRS89_Peninsula_Baleares_Canarias",
#'   "MTN25_RegCan95_Canarias",
#'   "MTN50_ED50_Peninsula_Baleares",
#'   "MTN50_ETRS89_Peninsula_Baleares_Canarias",
#'   "MTN50_RegCan95_Canarias"
#' ))
#'
#' knitr::kable(df, col.names = "**grid_name**")
#' ```
#'
#' ## MTN grids
#'
#' A description of the MTN (Mapa Topografico Nacional) grids available:
#'
#' **MTN25_ED50_Peninsula_Baleares**
#'
#' MTN25 grid corresponding to the Peninsula and Balearic Islands, in ED50 and
#' geographical coordinates (longitude, latitude). This is the real MTN25 grid,
#' that is, the one that divides the current printed series of the map, taking
#' into account special sheets and irregularities.
#'
#' **MTN50_ED50_Peninsula_Baleares**
#'
#' MTN50 grid corresponding to the Peninsula and Balearic Islands, in ED50 and
#' geographical coordinates (longitude, latitude). This is the real MTN50 grid,
#' that is, the one that divides the current printed series of the map, taking
#' into account special sheets and irregularities.
#'
#' **MTN25_ETRS89_ceuta_melilla_alboran**
#'
#' MTN25 grid corresponding to Ceuta, Melilla, Alboran and Spanish territories
#' in North Africa, adjusted to the new official geodetic reference system
#' ETRS89, in geographical coordinates (longitude, latitude).
#'
#' **MTN25_ETRS89_Peninsula_Baleares_Canarias**
#'
#' MTN25 real grid corresponding to the Peninsula, the Balearic Islands and the
#' Canary Islands, adjusted to the new ETRS89 official reference geodetic
#' system, in geographical coordinates (longitude, latitude).
#'
#' **MTN50_ETRS89_Peninsula_Baleares_Canarias**
#'
#' MTN50 real grid corresponding to the Peninsula, the Balearic Islands and the
#' Canary Islands, adjusted to the new ETRS89 official reference geodetic
#' system, in geographical coordinates (longitude, latitude).
#'
#' **MTN25_RegCan95_Canarias**
#'
#' MTN25 grid corresponding to the Canary Islands, in REGCAN95 (WGS84
#' compatible) and geographic coordinates (longitude, latitude). It is the real
#' MTN25 grid, that is, the one that divides the current printed series of the
#' map, taking into account the special distribution of the Canary Islands
#' sheets.
#'
#' **MTN50_RegCan95_Canarias**
#'
#' MTN50 grid corresponding to the Canary Islands, in REGCAN95 (WGS84
#' compatible) and geographic coordinates (longitude, latitude). This is the
#' real grid of the MTN50, that is, the one that divides the current printed
#' series of the map, taking into account the special distribution of the
#' Canary Islands sheets.
#'
#' @inheritSection esp_set_cache_dir Caching
#' @param grid Name of the grid to be loaded. See **Details**.
#'
#' @inheritParams esp_get_nuts
#' @inherit esp_get_grid_EEA return
#' @source IGN data distributed through the `sianedata/MTN` data branch (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>).
#'
#' @family grids
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' grid <- esp_get_grid_MTN(grid = "MTN50_ETRS89_Peninsula_Baleares_Canarias")
#'
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf() +
#'   theme_light() +
#'   labs(title = "MTN50 Grid for Spain")
#' }
esp_get_grid_MTN <- function(
  grid = "MTN25_ETRS89_Peninsula_Baleares_Canarias",
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  # Check grid.
  valid_grid <- c(
    "MTN25_ED50_Peninsula_Baleares",
    "MTN25_ETRS89_ceuta_melilla_alboran",
    "MTN25_ETRS89_Peninsula_Baleares_Canarias",
    "MTN25_RegCan95_Canarias",
    "MTN50_ED50_Peninsula_Baleares",
    "MTN50_ETRS89_Peninsula_Baleares_Canarias",
    "MTN50_RegCan95_Canarias"
  )
  init_grid <- match_arg_pretty(grid, valid_grid)

  # Build the download URL.
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/",
    "MTN/dist/MTN_grids.zip"
  )

  download_unzip_read_geo_file(
    url,
    subdir = "grid",
    member = paste0(init_grid, ".gpkg"),
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )
}
