#' City where the municipal public authorities are based - SIANE
#'
#' @description
#' Get a [`sf`][sf::st_sf] `POINT` with the location of the political powers for
#' each municipality.
#'
#' Note that this differs from the centroid of the boundaries of the
#' municipality, returned by [esp_get_munic_siane()].
#'
#' @details
#' When using `region` you can use and mix names and NUTS codes (levels 1, 2 or
#' 3), ISO codes (corresponding to level 2 or 3) or `"cpro"`
#' (see [esp_codelist]).
#'
#' When calling a higher level (province, Autonomous Community or NUTS1), all
#' the municipalities of that level will be added.
#'
#' @inheritParams esp_get_munic_siane
#' @inherit esp_get_munic_siane
#'
#' @family political
#' @family siane
#' @family municipalities
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # This code compares centroids of municipalities against esp_get_capimun
#'
#' # Get shape
#' area <- esp_get_munic_siane(munic = "Valladolid", epsg = 3857)
#'
#' # Area in km2
#' print(paste0(round(as.double(sf::st_area(area)) / 1000000, 2), " km2"))
#'
#' # Extract centroid
#' centroid <- sf::st_centroid(area)
#' centroid$type <- "Centroid"
#'
#' # Compare with capimun
#' capimun <- esp_get_capimun(munic = "Valladolid", epsg = 3857)
#' capimun$type <- "Capimun"
#'
#' # Join both point geometries
#' points <- dplyr::bind_rows(centroid, capimun)
#'
#' # Check on plot
#' library(ggplot2)
#'
#' ggplot(points) +
#'   geom_sf(data = area, fill = NA, color = "blue") +
#'   geom_sf(data = points, aes(fill = type), size = 5, shape = 21) +
#'   scale_fill_manual(values = c("green", "red")) +
#'   labs(title = "Centroid vs. capimun")
#' }
esp_get_capimun <- function(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  region = NULL,
  munic = NULL,
  moveCAN = TRUE,
  rawcols = FALSE
) {
  init_epsg <- validate_epsg(epsg)

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_urban_capimuni_p_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_urban_capimuni_p_y.gpkg"
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
