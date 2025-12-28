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
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/",
    "dist/se89_3_vias_ffcc_p_x.gpkg"
  )

  # Not cached are read from url
  if (!cache) {
    msg <- paste0("{.url ", url, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf <- read_geo_file_sf(url)
  } else {
    file_local <- download_url(
      url,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    # Download
    data_sf <- lapply(file_local, read_geo_file_sf)

    data_sf <- rbind_fill(data_sf)
    if (is.null(data_sf)) {
      return(NULL)
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  data_sf
}
