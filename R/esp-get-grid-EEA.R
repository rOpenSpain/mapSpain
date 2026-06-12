#' Get [`sf`][sf::st_sf] `POLYGON` of the national geographic grids from EEA
#'
#' @description
#' `r lifecycle::badge('defunct')`
#'
#' This function is defunct because the source file is no longer available.
#'
#' @param resolution Resolution of the grid in kilometers. Can be `1`, `10`
#'   or `100`.
#'
#' @inheritParams esp_get_grid_BDN
#' @return A [`sf`][sf::st_sf] `POLYGON`.
#'
#' @source
#'
#' ```{r, echo=FALSE, results='asis'}
#'
#' cat(paste0("[EEA reference grid]",
#'       "(https://www.eea.europa.eu/en/datahub/datahubitem-view/",
#'       "3c362237-daa4-45e2-8c16-aaadfb1a003b)."))
#'
#' ```
#'
#' @family deprecated functions
#' @keywords internal
#' @encoding UTF-8
#' @export
#'
esp_get_grid_EEA <- function(
  resolution = 100,
  type = "main",
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  lifecycle::deprecate_stop(
    "1.0.0",
    what = "mapSpain::esp_get_grid_EEA()",
    details = paste0(
      "The source file is no longer available for download."
    )
  )
}
