#' Get [`sf`][sf::st_sf] `POLYGON` of the national geographic grids from IGN
#'
#' @description
#' Loads a [`sf`][sf::st_sf] `POLYGON` with the geographic grids of Spain.
#'
#' @family grids
#'
#' @return A [`sf`][sf::st_sf] `POLYGON`.
#'
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>).
#'
#' @export
#'
#' @param grid Name of the grid to be loaded. See **Details**.
#'
#' @inheritParams esp_get_nuts
#'
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>.
#'
#' Possible values of `grid` are:
#'
#' ```{r, echo=FALSE}
#'
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
#'
#' knitr::kable(df,
#'              col.names = "**grid_name**")
#'
#'
#'
#' ```
#'
#' ## MTN Grids
#'
#' A description of the MTN (Mapa Topografico Nacional) grids available:
#'
#'
#' **MTN25_ED50_Peninsula_Baleares**
#'
#' MTN25 grid corresponding to the Peninsula and Balearic Islands, in ED50 and
#' geographical coordinates (longitude, latitude) This is the real MTN25 grid,
#' that is, the one that divides the current printed series of the map, taking
#' into account special sheets and irregularities.
#'
#' **MTN50_ED50_Peninsula_Baleares**
#'
#' MTN50 grid corresponding to the Peninsula and Balearic Islands, in ED50 and
#' geographical coordinates (longitude, latitude) This is the real MTN50 grid,
#' that is, the one that divides the current printed series of the map, taking
#' into account special sheets and irregularities.
#'
#' **MTN25_ETRS89_ceuta_melilla_alboran**
#'
#'  MTN25 grid corresponding to Ceuta, Melilla, Alboran and Spanish territories
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
  # Check grid
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

  # Url
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/",
    "MTN/dist/MTN_grids.zip"
  )
  file_local <- download_url(
    url,
    cache_dir = cache_dir,
    subdir = "grid",
    update_cache = update_cache,
    verbose = verbose
  )
  if (is.null(file_local)) {
    return(file_local)
  }
  path <- gsub(basename(file_local), "", file_local)
  unzip(file_local, exdir = path, junkpaths = TRUE)
  read_geo_file_sf(paste0(path, init_grid, ".gpkg"))
}
