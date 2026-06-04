#' Municipalities of Spain from SIANE
#'
#' @encoding UTF-8
#' @family political
#' @family siane
#' @family municipalities
#' @inheritParams esp_get_ccaa_siane
#' @inheritParams esp_get_munic
#' @inherit esp_get_munic description details return
#' @inherit esp_get_ccaa_siane source
#' @export
#'
#' @note
#'
#' Although \CRANpkg{mapSpain} supplies cartographically suitable datasets,
#' a historical database of Spanish municipal boundaries is also available,
#' offering higher‑resolution geometries that may be more appropriate for
#' GIS‑oriented workflows:
#'
#' - Goerlich, F. J., & Pérez Vázquez, P. (2025). *Base de datos histórica de
#'   contornos municipales de España –LAU2boundaries4Spain–* \[Data set\].
#'   Zenodo. \doi{10.5281/zenodo.15345101},
#'   <https://www.uv.es/goerlich/Ivie/LAU2boundaries4Spain.html>.
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # Municipalities that have changed in the past: three snapshots.
#' munis2005 <- esp_get_munic_siane(year = 2005, rawcols = TRUE)
#' munis2015 <- esp_get_munic_siane(year = 2015, rawcols = TRUE)
#' munis2024 <- esp_get_munic_siane(year = 2024, rawcols = TRUE)
#'
#' # Manipulate data.
#' library(dplyr)
#' allmunis_unique <- bind_rows(munis2005, munis2015, munis2024) |>
#'   distinct()
#'
#' id_all <- allmunis_unique |>
#'   sf::st_drop_geometry() |>
#'   group_by(id_ine, name) |>
#'   count() |>
#'   ungroup() |>
#'   arrange(desc(n)) |>
#'   slice_head(n = 1) |>
#'   glimpse()
#'
#' library(ggplot2)
#' allmunis_unique |>
#'   filter(id_ine == id_all$id_ine) |>
#'   ggplot() +
#'   geom_sf(aes(fill = as.factor(fecha_alta)),
#'     alpha = 0.7,
#'     show.legend = FALSE
#'   ) +
#'   scale_fill_viridis_d() +
#'   facet_wrap(~fecha_alta) +
#'   labs(
#'     title = id_all$name,
#'     subtitle = "Changes on boundaries over time",
#'     fill = ""
#'   )
#' }
esp_get_munic_siane <- function(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = c(3, 6.5, 10),
  region = NULL,
  munic = NULL,
  moveCAN = TRUE,
  rawcols = FALSE
) {
  init_epsg <- validate_epsg(epsg)
  res <- match_arg_pretty(resolution)
  res <- gsub("6.5", "6m5", res)

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_",
    res,
    "_admin_muni_a_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_",
    res,
    "_admin_muni_a_y.gpkg"
  )

  data_sf <- read_siane_files(
    c(url_penin, url_can),
    cache = cache,
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )
  if (is.null(data_sf)) {
    return(NULL)
  }
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf <- siane_filter_year(data_sf = data_sf, year = year)
  data_sf <- add_municipal_metadata(data_sf, "id_ine", "rotulo")

  data_sf <- filter_by_name_pattern(data_sf, munic, "name")
  data_sf <- filter_by_cpro_region(data_sf, region)

  if (nrow(data_sf) == 0) {
    return(return_empty_combination_sf(data_sf, "munic"))
  }

  # Move the Canary Islands.
  data_sf <- move_can(data_sf, moveCAN)

  # Restore and finish geometries.
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$cmun), ]
  if (isFALSE(rawcols)) {
    data_sf <- data_sf[, c(
      "codauto",
      "ine.ccaa.name",
      "cpro",
      "ine.prov.name",
      "cmun",
      "name",
      "LAU_CODE"
    )]
  }
  data_sf <- sanitize_sf(data_sf)

  data_sf
}
