#' Autonomous Communities of Spain - SIANE
#'
#' @source
#' CartoBase ANE provided by Instituto Geografico Nacional (IGN),
#' <http://www.ign.es/web/ign/portal>. Years available are 2005 up to today.
#'
#' @encoding UTF-8
#' @family political
#' @family siane
#' @inheritParams esp_get_nuts
#' @inheritParams esp_get_ccaa
#' @inherit esp_get_ccaa description return details
#' @export
#'
#'
#' @param year character string or number. Release year, it must presents
#'   formats `YYYY` (assuming end of year) or `YYYY-MM-DD`. Historical
#'   information starts as of 2005.
#' @param resolution character string or number. Resolution of the geospatial
#'   data. One of:
#'   * "10": 1:10 million.
#'   * "6.5": 1:6.5 million.
#'   * "3": 1:3 million.
#'
#' @param rawcols logical. Setting this to `TRUE` would add the raw columns of
#'   the resulting object as provided by IGN.
#'
#' @examplesIf esp_check_access()
#' ccaas1 <- esp_get_ccaa_siane()
#' dplyr::glimpse(ccaas1)
#'
#' # Low res
#' ccaas_low <- esp_get_ccaa_siane(
#'   rawcols = TRUE, moveCAN = FALSE,
#'   resolution = 10, epsg = 3035
#' )
#'
#'
#' library(ggplot2)
#'
#' ggplot(ccaas_low) +
#'   geom_sf(aes(fill = nuts1.name)) +
#'   scale_fill_viridis_d(option = "cividis")
#'
esp_get_ccaa_siane <- function(
  ccaa = NULL,
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
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))
  res <- match_arg_pretty(resolution)
  res <- gsub("6.5", "6m5", res)

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_",
    res,
    "_admin_ccaa_a_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_",
    res,
    "_admin_ccaa_a_y.gpkg"
  )

  # Not cached are read from url
  if (!cache) {
    msg <- paste0("{.url ", url_penin, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_penin <- read_geo_file_sf(url_penin)

    msg <- paste0("{.url ", url_can, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_can <- read_geo_file_sf(url_can)

    data_sf <- rbind_fill(list(data_sf_penin, data_sf_can))
  } else {
    file_local_penin <- download_url(
      url_penin,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    file_local_can <- download_url(
      url_can,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    # Download
    data_sf <- lapply(c(file_local_penin, file_local_can), read_geo_file_sf)

    data_sf <- rbind_fill(data_sf)
    if (is.null(data_sf)) {
      return(NULL)
    }
  }

  data_sf <- siane_filter_year(data_sf = data_sf, year = year)

  initcols <- colnames(sf::st_drop_geometry(data_sf))

  # Add codauto
  data_sf$lab <- data_sf$rotulo

  data_sf$lab <- gsub("Ciudad de ", "", data_sf$lab, fixed = TRUE)
  data_sf$lab <- gsub("/Catalunya", "", data_sf$lab)
  data_sf$lab <- gsub("/Euskadi", "", data_sf$lab)
  data_sf$codauto <- esp_dict_region_code(data_sf$lab, destination = "codauto")

  # Filter CCAA
  nuts_id <- ensure_null(ccaa)

  if (!is.null(nuts_id)) {
    nuts_id <- convert_to_nuts_ccaa(nuts_id)
    # Get df
    df <- mapSpain::esp_codelist
    dfl2 <- df[df$nuts2.code %in% nuts_id, ]$codauto
    dfl3 <- df[df$nuts3.code %in% nuts_id, ]$codauto

    finalcodauto <- as.vector(c(dfl2, dfl3))

    # Filter
    data_sf <- data_sf[data_sf$codauto %in% finalcodauto, ]
  }

  # Get df final with vars
  df <- get_ccaa_codes_df()

  # Merge
  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts1
  dfnuts <- mapSpain::esp_codelist
  dfnuts <- unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])
  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

  # Move CAN
  data_sf <- move_can(data_sf, moveCAN)

  # Back and finish
  # Transform
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  # Select columns
  if (rawcols) {
    data_sf <- data_sf[
      ,
      unique(c(
        initcols,
        colnames(df),
        "nuts1.code",
        "nuts1.name"
      ))
    ]
  } else {
    data_sf <- data_sf[, unique(c(colnames(df), "nuts1.code", "nuts1.name"))]
  }
  data_sf <- sanitize_sf(data_sf)

  data_sf
}
