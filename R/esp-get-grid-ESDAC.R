#' National geographic grids from the European Soil Data Centre (ESDAC)
#'
#' @description
#' Loads a [`sf`][sf::st_sf] `POLYGON` with the geographic grids of Spain as
#' provided by the European Soil Data Centre (ESDAC).
#'
#' @source
#' [EEA reference
#' grid](https://esdac.jrc.ec.europa.eu/content/european-reference-grids).
#'
#' @references
#' - Panagos P., Van Liedekerke M., Jones A., Montanarella L., "European Soil
#'   Data Centre: Response to European policy support and public data
#'   requirements"; (2012) _Land Use Policy_, 29 (2), pp. 329-338.
#'   \doi{10.1016/j.landusepol.2011.07.003}
#' - European Soil Data Centre (ESDAC), esdac.jrc.ec.europa.eu, European
#'   Commission, Joint Research Centre.
#'
#' @encoding UTF-8
#' @family grids
#' @inheritParams esp_get_grid_EEA
#' @inherit esp_get_grid_EEA return
#' @export
#'
#' @param resolution numeric. Resolution of the grid in kilometres. It could be
#'   `1` or `10`.
#'
#' @examplesIf esp_check_access()
#' \dontrun{
#' grid <- esp_get_grid_ESDAC()
#' esp <- esp_get_spain(moveCAN = FALSE)
#'
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf() +
#'   geom_sf(data = esp, color = "grey50", fill = NA) +
#'   theme_light() +
#'   labs(title = "ESDAC Grid for Spain")
#' }
#'
esp_get_grid_ESDAC <- function(
  resolution = c(10, 1),
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  # Check grid
  res <- match_arg_pretty(resolution)

  # Url
  if (res == 10) {
    url <- paste0(
      "https://esdac.jrc.ec.europa.eu/Library/Reference_Grids/",
      "Grids/grids_for_single_eu25_countries_etrs_laea_10k.zip"
    )
    shp_hint <- "spain"
  } else {
    # nocov start
    # Tests are slow due to this file size
    url <- paste0(
      "https://esdac.jrc.ec.europa.eu/Library/Reference_Grids/",
      "Grids/grid_spain_etrs_laea_1k.zip"
    )
    shp_hint <- NULL
  }
  # nocov end

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

  read_geo_file_sf(file_local, shp_hint = shp_hint)
}
