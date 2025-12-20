#' Get [`sf`][sf::st_sf] `POLYGON` of the national geographic grids from EEA
#'
#' @description
#' `r lifecycle::badge('defunct')`
#'
#' This function is defunct as the source file is not available any more.
#'
#' @family deprecated functions
#' @encoding UTF-8
#' @export
#'
#' @return A [`sf`][sf::st_sf] `POLYGON`.
#'
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
#' @param resolution Resolution of the grid in kms. Could be `1`, `10` or `100`.
#'
#' @inheritParams esp_get_grid_BDN
#'
#' @examplesIf esp_check_access()
#' \dontrun{
#' try(esp_get_grid_EEA())
#' }
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
      "The source file is not available for download",
      " any more"
    )
  )
}
