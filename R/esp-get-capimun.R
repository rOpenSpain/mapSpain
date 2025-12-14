#' Get [`sf`][sf::st_sf] `POINT` of the municipalities of Spain
#'
#' @description
#' Get a [`sf`][sf::st_sf] `POINT` with the location of the political powers for
#' each municipality (possibly the center of the municipality).
#'
#' Note that this differs of the centroid of the boundaries of the
#' municipality, returned by [esp_get_munic()].
#'
#' @family political
#' @family municipalities
#'
#' @return A [`sf`][sf::st_sf] `POINT` object.
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#'
#' @param year Release year. See **Details** for years available.
#'
#' @inheritParams esp_get_munic
#'
#' @inheritParams esp_get_nuts
#'
#'
#' @inheritSection  esp_get_nuts  About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @details
#' `year` could be passed as a single year (`YYYY` format, as end of year) or
#' as a specific date (`YYYY-MM-DD` format). Historical information starts as
#' of 2005.
#'
#' When using `region` you can use and mix names and NUTS codes (levels 1,
#' 2 or 3), ISO codes (corresponding to level 2 or 3) or `cpro`. See
#' [esp_codelist]
#'
#' When calling a higher level (province, CCAA or NUTS1), all the municipalities
#' of that level would be added.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # This code compares centroids of municipalities against esp_get_capimun
#' # It also download tiles, make sure you are online
#'
#' library(sf)
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
#' # Get a tile to check
#' tile <- esp_get_tiles(area, "IGNBase.Todo", zoommin = 2)
#'
#' # Join both point geometries
#' points <- rbind(
#'   centroid[, "type"],
#'   capimun[, "type"]
#' )
#'
#'
#' # Check on plot
#' library(ggplot2)
#' library(tidyterra)
#'
#' ggplot(points) +
#'   geom_spatraster_rgb(data = tile, maxcell = Inf) +
#'   geom_sf(data = area, fill = NA, color = "blue") +
#'   geom_sf(data = points, aes(fill = type), size = 5, shape = 21) +
#'   scale_fill_manual(values = c("green", "red")) +
#'   theme_void() +
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
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_urban_capimuni_p_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_urban_capimuni_p_y.gpkg"
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
    if (is.null(data_sf)) return(NULL)
  }

  data_sf <- siane_filter_year(data_sf = data_sf, year = year)
  # Name management
  data_sf$LAU_CODE <- data_sf$id_ine
  data_sf$name <- data_sf$rotulo
  data_sf$cpro <- substr(data_sf$id_ine, 1, 2)

  idprov <- sort(unique(mapSpain::esp_codelist$cpro))
  data_sf$cmun <- ifelse(
    substr(data_sf$LAU_CODE, 1, 2) %in% idprov,
    substr(data_sf$LAU_CODE, 3, 8),
    NA
  )

  cod <- unique(
    mapSpain::esp_codelist[,
      c("codauto", "ine.ccaa.name", "cpro", "ine.prov.name")
    ]
  )

  data_sf <- merge(data_sf, cod, by = "cpro", all.x = TRUE, no.dups = TRUE)
  data_sf <- sanitize_sf(data_sf)

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data_sf <- data_sf[grep(munic, data_sf$name, ignore.case = TRUE), ]
  }

  if (!is.null(region)) {
    tonuts <- esp_hlp_all2prov(region)
    # toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)
    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  if (nrow(data_sf) == 0) {
    cli::cli_alert_warning(
      paste0(
        "The combination of {.arg region} and/or {.arg muni}c does not ",
        "return any result"
      )
    )
    cli::cli_alert_info("Returning empty {.cls sf} object.")
    return(data_sf)
  }
  # Move CAN

  # Checks
  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    if (length(grep("05", data_sf$codauto)) > 0) {
      penin <- data_sf[-grep("05", data_sf$codauto), ]
      can <- data_sf[grep("05", data_sf$codauto), ]

      can <- esp_move_can(can, moveCAN = moveCAN)

      # Regenerate
      if (nrow(penin) > 0) {
        data_sf <- rbind(penin, can)
      } else {
        data_sf <- can
      }
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
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

  data_sf
}
