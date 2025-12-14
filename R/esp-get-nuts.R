#' Territorial spanish units for statistics (NUTS) dataset
#'
#' @description
#' The GISCO statistical unit dataset represents the NUTS (nomenclature of
#' territorial units for statistics) and statistical regions by means of
#' multipart polygon, polyline and point topology. The NUTS geographical
#' information is completed by attribute tables and a set of cartographic
#' help lines to better visualise multipart polygonal regions.
#'
#' The NUTS are a hierarchical system divided into 3 levels:
#'  - NUTS 1: major socio-economic regions
#'  - NUTS 2: basic regions for the application of regional policies
#'  - NUTS 3: small regions for specific diagnoses.
#'
#' Also, there is a NUTS 0 level, which usually corresponds to the national
#' boundaries.
#'
#' @encoding UTF-8
#' @family political
#' @family nuts
#' @inheritParams giscoR::gisco_get_nuts
#' @inherit giscoR::gisco_get_nuts
#' @export
#'
#' @seealso [giscoR::gisco_get_nuts()], [esp_dict_region_code()].
#'
#'
#' @param year year character string or number. Release year of the file. See
#'   [giscoR::gisco_get_nuts()] for valid values.
#' @param epsg character string or number. Projection of the map: 4-digit
#'   [EPSG code](https://epsg.io/). One of:
#'   * `"4258"`: [ETRS89](https://epsg.io/4258)
#'   * `"4326"`: [WGS84](https://epsg.io/4326).
#'   * `"3035"`: [ETRS89 / ETRS-LAEA](https://epsg.io/3035).
#'   * `"3857"`: [Pseudo-Mercator](https://epsg.io/3857).
#' @param cache logical. Whether to do caching. Default is `TRUE`. See
#'   **Caching strategies** section in [esp_set_cache_dir()].
#' @param update_cache logical. Should the cached file be refreshed?. Default
#'   is `FALSE`. When set to `TRUE` it would force a new download.
#' @param cache_dir character string. A path to a cache directory. See
#'   **Caching strategies** section in [esp_set_cache_dir()].
#' @param region Optional. A vector of region names, NUTS or ISO codes
#'   (see [esp_dict_region_code()]).
#'
#' @param spatialtype character string. Type of geometry to be returned.
#'   Options available are:
#'   * "RG": Regions - `MULTIPOLYGON/POLYGON` object.
#'   * "LB": Labels - `POINT` object.
#' @param moveCAN A logical `TRUE/FALSE` or a vector of coordinates
#'   `c(lat, lon)`. It places the Canary Islands close to Spain's mainland.
#'   Initial position can be adjusted using the vector of coordinates. See
#'   **Displacing the Canary Islands** in [esp_move_can()].
#' @param ext character. Extension of the file (default `"gpkg"`). See
#'   [giscoR::gisco_get_nuts()].
#'
#' @examples
#'
#' NUTS1 <- esp_get_nuts(nuts_level = 1, moveCAN = TRUE)
#'
#' library(ggplot2)
#'
#' ggplot(NUTS1) +
#'   geom_sf() +
#'   labs(
#'     title = "NUTS1: Displacing Canary Islands",
#'     caption = giscoR::gisco_attributions()
#'   )
#'
#'
#' NUTS1_alt <- esp_get_nuts(nuts_level = 1, moveCAN = c(15, 0))
#'
#'
#' ggplot(NUTS1_alt) +
#'   geom_sf() +
#'   labs(
#'     title = "NUTS1: Displacing Canary Islands",
#'     subtitle = "to the right",
#'     caption = giscoR::gisco_attributions()
#'   )
#'
#'
#' NUTS1_orig <- esp_get_nuts(nuts_level = 1, moveCAN = FALSE)
#'
#' ggplot(NUTS1_orig) +
#'   geom_sf() +
#'   labs(
#'     title = "NUTS1",
#'     subtitle = "Canary Islands on the true location",
#'     caption = giscoR::gisco_attributions()
#'   )
#'
#'
#' AndOriental <- esp_get_nuts(region = c(
#'   "Almeria", "Granada",
#'   "Jaen", "Malaga"
#' ))
#'
#'
#' ggplot(AndOriental) +
#'   geom_sf()
#'
#'
#' RandomRegions <- esp_get_nuts(region = c("ES1", "ES300", "ES51"))
#'
#' ggplot(RandomRegions) +
#'   geom_sf() +
#'   labs(title = "Random Regions")
#'
#'
#' MixingCodes <- esp_get_nuts(region = c("ES4", "ES-PV", "Valencia"))
#'
#'
#' ggplot(MixingCodes) +
#'   geom_sf() +
#'   labs(title = "Mixing Codes")
esp_get_nuts <- function(
  year = 2024,
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = 1,
  spatialtype = c("RG", "LB"),
  region = NULL,
  nuts_level = c("all", "0", "1", "2", "3"),
  moveCAN = TRUE,
  ext = "gpkg"
) {
  # Dispatch everything to gisco_get_nuts except EPSG, that is specific
  epsg <- match_arg_pretty(epsg, c("4258", "4326", "3035", "3857"))
  gisco_epsg <- ifelse(epsg == "4258", "4326", epsg)
  cache_dir <- create_cache_dir(cache_dir)
  spatialtype <- match_arg_pretty(spatialtype)

  nuts_level <- match_arg_pretty(nuts_level)

  # See if the call uses the default params

  if (
    all(
      year == 2024,
      epsg == "4258",
      resolution == 1,
      spatialtype == "RG",
      ext == "gpkg",
      isFALSE(update_cache)
    )
  ) {
    data_sf <- mapSpain::esp_nuts_2024

    make_msg(
      "info",
      verbose,
      "Loaded from {.help mapSpain::esp_nuts_2024} dataset.",
      "Use {.arg update_cache = TRUE} to re-load from file"
    )
  } else {
    data_sf <- giscoR::gisco_get_nuts(
      year = year,
      epsg = gisco_epsg,
      cache = cache,
      update_cache = update_cache,
      cache_dir = cache_dir,
      verbose = verbose,
      resolution = resolution,
      spatialtype = spatialtype,
      country = "ES",
      nuts_level = nuts_level,
      ext = ext
    )
    if (is.null(data_sf)) {
      return(NULL)
    }
    if (gisco_epsg != epsg) {
      data_sf <- sf::st_transform(data_sf, as.numeric(epsg))
    }
  }

  data_sf <- data_sf[order(data_sf$LEVL_CODE, data_sf$NUTS_ID), ]

  if (nuts_level %in% c("0", "1", "2", "3")) {
    data_sf <- data_sf[data_sf$LEVL_CODE == nuts_level, ]
  }

  # Get region id
  if (all(!is.null(region), "NUTS_ID" %in% names(data_sf))) {
    nuts_id <- esp_hlp_all2nuts(region)

    nuts_id <- nuts_id[!is.na(nuts_id)]
    nuts_id <- unique(nuts_id)

    data_sf <- data_sf[data_sf$NUTS_ID %in% nuts_id, ]

    if (nrow(data_sf) == 0) {
      cli::cli_alert_info(region)
      cli::cli_alert_warning(
        paste0(
          "No matches for {.arg region = {region}}."
        )
      )
      cli::cli_alert_info("Returning empty {.cls sf} object.")
      return(data_sf)
    }
  }

  # Checks
  moving <- FALSE
  prepare_can <- data_sf
  prepare_can$is_can <- FALSE
  if ("NUTS_ID" %in% colnames(data_sf)) {
    prepare_can$is_can <- grepl("^ES7", data_sf$NUTS_ID)
  }
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

  data_sf <- sanitize_sf(data_sf)
  data_sf
}
