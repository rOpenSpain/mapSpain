#' Provinces of Spain - SIANE
#'
#' @encoding UTF-8
#' @family political
#' @family siane
#' @inheritParams esp_get_ccaa_siane
#' @inheritParams esp_get_prov
#' @inherit esp_get_prov description details
#' @inherit esp_get_ccaa_siane source return
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
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))
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
  data_sf$cpro <- data_sf$id_prov

  if (!is.null(prov)) {
    tonuts <- convert_to_nuts_prov(prov)

    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)
    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  # Get df
  df <- get_prov_codes_df()
  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts2
  dfnuts <- mapSpain::esp_codelist
  dfnuts <- unique(dfnuts[, c(
    "cpro",
    "nuts2.code",
    "nuts2.name",
    "nuts1.code",
    "nuts1.name"
  )])
  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

  # Checks
  moving <- FALSE
  prepare_can <- data_sf
  prepare_can$is_can <- prepare_can$codauto == "05"

  moving <- (isTRUE(moveCAN) | length(moveCAN) > 1) & any(prepare_can$is_can)

  if (moving) {
    penin <- prepare_can[prepare_can$is_can == FALSE, ]
    can <- prepare_can[prepare_can$is_can == TRUE, ]

    can <- esp_move_can(can, moveCAN = moveCAN)

    # Regenerate
    keep_n <- names(data_sf)
    data_sf <- rbind_fill(list(penin, can))
    data_sf <- data_sf[, keep_n]
  }

  # Transform
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  namesend <- unique(c(
    initcols,
    colnames(esp_get_prov())
  ))

  # Review this error, can't fully reproduce

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


get_prov_codes_df <- function() {
  getnames <- c(
    "codauto",
    "cpro",
    "iso2.prov.code",
    "nuts.prov.code",
    "ine.prov.name",
    "iso2.prov.name.es",
    "iso2.prov.name.ca",
    "iso2.prov.name.ga",
    "iso2.prov.name.eu",
    "cldr.prov.name.en",
    "cldr.prov.name.es",
    "cldr.prov.name.ca",
    "cldr.prov.name.ga",
    "cldr.prov.name.eu",
    "prov.shortname.en",
    "prov.shortname.es",
    "prov.shortname.ca",
    "prov.shortname.ga",
    "prov.shortname.eu"
  )

  df_prov <- mapSpain::esp_codelist
  df_prov <- df_prov[, getnames]
  df_end <- unique(df_prov)
  df_end <- df_end[order(df_end$codauto), ]
  df_end
}
