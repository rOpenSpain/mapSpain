#' @rdname esp_get_railway
#' @export
esp_get_stations <- function(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
) {
  init_epsg <- validate_epsg(epsg)

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/",
    "dist/se89_3_vias_ffcc_p_x.gpkg"
  )

  data_sf <- read_siane_files(
    url,
    cache = cache,
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )
  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf <- sanitize_transform_sf(data_sf, init_epsg)
  data_sf
}
