#' Roads of Spain from SIANE
#'
#' @description
#' Object representing the main roads of Spain.
#'
#' @inheritSection esp_set_cache_dir Caching
#' @inheritParams esp_get_railway
#' @inheritParams esp_get_ccaa_siane
#' @inherit esp_get_ccaa_siane return source
#' @family infrastructure
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#'
#' country <- esp_get_spain()
#' roads <- esp_get_roads()
#'
#' library(ggplot2)
#'
#' ggplot(country) +
#'   geom_sf(fill = "grey90") +
#'   geom_sf(data = roads, aes(color = t_ctra_desc), show.legend = "line") +
#'   scale_color_manual(
#'     values = c("#003399", "#003399", "#ff0000", "#ffff00")
#'   ) +
#'   guides(color = guide_legend(direction = "vertical")) +
#'   theme_minimal() +
#'   labs(color = "Road type") +
#'   theme(legend.position = "bottom")
#' }
esp_get_roads <- function(
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  moveCAN = TRUE
) {
  init_epsg <- validate_epsg(epsg)

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_vias_ctra_l_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_vias_ctra_l_y.gpkg"
  )

  data_sf <- read_siane_files(
    c(url_penin, url_can),
    cache = cache,
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose,
    codauto = c("XX", "05")
  )
  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf <- merge_db_value_desc(
    data_sf,
    "tipocarretera",
    c(
      "t_ctra",
      "t_ctra_desc"
    )
  )
  data_sf <- merge_db_value_desc(
    data_sf,
    "estadofisico",
    c(
      "estado_fis",
      "estado_fis_desc"
    )
  )
  data_sf <- merge_db_value_desc(data_sf, "orden", c("orden", "orden_desc"))
  data_sf <- merge_db_value_desc(
    data_sf,
    "acceso",
    c(
      "acceso",
      "acceso_desc"
    )
  )

  # Move the Canary Islands.
  data_sf <- move_can(data_sf, moveCAN)
  data_sf <- data_sf[, setdiff(names(data_sf), "codauto")]

  data_sf <- data_sf[order(data_sf$t_ctra, data_sf$orden, data_sf$rotulo), ]

  data_sf <- sanitize_transform_sf(data_sf, init_epsg)
  data_sf
}
