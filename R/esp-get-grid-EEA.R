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
#'
#' grid <- esp_get_grid_EEA(type = "main", resolution = 100)
#' grid_can <- esp_get_grid_EEA(type = "canary", resolution = 100)
#' esp <- esp_get_country(moveCAN = FALSE)
#'
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf() +
#'   geom_sf(data = grid_can) +
#'   geom_sf(data = esp, fill = NA) +
#'   theme_light() +
#'   labs(title = "EEA Grid for Spain")
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
