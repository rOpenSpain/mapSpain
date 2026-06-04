#' Provinces of Spain from SIANE
#'
#' @inheritParams esp_get_ccaa_siane
#' @inheritParams esp_get_prov
#' @inherit esp_get_prov description details
#' @inherit esp_get_ccaa_siane source return
#' @family political
#' @family siane
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' library(ggplot2)
#'
#' esp_get_ccaa_siane() |>
#'   dplyr::glimpse() |>
#'   ggplot() +
#'   geom_sf()
esp_get_prov_siane <- function(
  prov = NULL,
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = c(3, 6.5, 10),
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
    "_admin_prov_a_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_",
    res,
    "_admin_prov_a_y.gpkg"
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

  data_sf <- siane_filter_year(data_sf = data_sf, year = year)

  initcols <- colnames(sf::st_drop_geometry(data_sf))
  data_sf$cpro <- data_sf$id_prov

  data_sf <- filter_by_cpro_region(data_sf, prov)

  # Get province metadata.
  df <- get_prov_codes_df()
  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Add NUTS2 metadata.
  data_sf <- merge(data_sf, get_prov_nuts_codes_df(), all.x = TRUE)

  # Move the Canary Islands.
  data_sf <- move_can(data_sf, moveCAN)

  # Transform to the requested CRS.
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  # Order by Autonomous Community and province.
  data_sf <- data_sf[order(data_sf$codauto), ]

  namesend <- unique(c(initcols, colnames(esp_get_prov())))

  # Review this error, which is not fully reproducible.

  namesend <- namesend[namesend %in% names(data_sf)]

  data_sf <- data_sf[, namesend]

  if (isFALSE(rawcols)) {
    nm <- colnames(esp_get_prov())
    nm <- nm[nm %in% colnames(data_sf)]

    data_sf <- data_sf[, nm]
  }

  data_sf <- sanitize_sf(data_sf)
  data_sf
}
