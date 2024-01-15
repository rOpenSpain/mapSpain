#' Get NUTS of Spain as \CRANpkg{sf} polygons and points
#'
#' @description
#' Returns [NUTS regions of
#' Spain](https://en.wikipedia.org/wiki/NUTS_statistical_regions_of_Spain)
#' as polygons and points at a specified scale, as provided by
#' [GISCO](https://ec.europa.eu/eurostat/web/gisco)
#' (Geographic Information System of the Commission, depending of Eurostat).
#'
#' NUTS are provided at three different levels:
#' * **"0"**: Country level
#' * **"1"**: Groups of autonomous communities
#' * **"2"**: Autonomous communities
#' * **"3"**: Roughly matches the provinces, but providing specific individual
#'   objects for each major island
#'
#' @export
#'
#' @family political
#' @family nuts
#' @seealso [giscoR::gisco_get_nuts()], [esp_dict_region_code()].
#'
#' @return A \CRANpkg{sf} object specified by `spatialtype`.
#'
#' @note
#' Please check the download and usage provisions on
#' [giscoR::gisco_attributions()]
#'
#' @source [GISCO API](https://gisco-services.ec.europa.eu/distribution/v2/)
#'
#'
#' @param year Release year of the file. One of `"2003"`, `"2006"`,
#'   `"2010"`, `"2013"`, `"2016"`  or `"2021"`.
#'
#' @param epsg projection of the map: 4-digit [EPSG code](https://epsg.io/).
#'  One of:
#'  * `"4258"`: ETRS89
#'  * `"4326"`: WGS84
#'  * `"3035"`: ETRS89 / ETRS-LAEA
#'  * `"3857"`: Pseudo-Mercator
#'
#' @param cache A logical whether to do caching. Default is `TRUE`. See
#'   **About caching**.
#'
#' @param update_cache A logical whether to update cache. Default is `FALSE`.
#'  When set to `TRUE` it would force a fresh download of the source file.
#'
#' @param cache_dir A path to a cache directory. See **About caching**.
#'
#' @param verbose Logical, displays information. Useful for debugging,
#'   default is `FALSE`.
#'
#' @param resolution Resolution of the geospatial data. One of
#'  * "60": 1:60million
#'  * "20": 1:20million
#'  * "10": 1:10million
#'  * "03": 1:3million
#'  * "01": 1:1million
#'
#' @param spatialtype Type of geometry to be returned:
#'  * `"LB"`: Labels - point object.
#'  * `"RG"`: Regions - polygon object.
#'
#' @param region Optional. A vector of region names, NUTS or ISO codes
#'   (see [esp_dict_region_code()]).
#'
#' @param nuts_level NUTS level. One of "0" (Country-level), "1", "2" or "3".
#'   See **Description**.
#'
#' @param moveCAN A logical `TRUE/FALSE` or a vector of coordinates
#'   `c(lat, lon)`. It places the Canary Islands close to Spain's mainland.
#'   Initial position can be adjusted using the vector of coordinates. See
#'   **Displacing the Canary Islands**.
#'
#' @details
#' # About caching
#'
#' You can set your `cache_dir` with [esp_set_cache_dir()].
#'
#' Sometimes cached files may be corrupt. On that case, try re-downloading
#' the data setting `update_cache = TRUE`.
#'
#' If you experience any problem on download, try to download the
#' corresponding .geojson file by any other method and save it on your
#' `cache_dir`. Use the option `verbose = TRUE` for debugging the API query.
#'
#'
#' # Displacing the Canary Islands
#'
#' While `moveCAN` is useful for visualization, it would alter the actual
#' geographic position of the Canary Islands. When using the output for
#' spatial analysis or using tiles (e.g. with [esp_getTiles()] or
#' [addProviderEspTiles()])  this option should be set to `FALSE` in order to
#' get the actual coordinates, instead of the modified ones. See also
#' [esp_move_can()] for displacing stand-alone \CRANpkg{sf} objects.
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
#' AndOriental <-
#'   esp_get_nuts(region = c("Almeria", "Granada", "Jaen", "Malaga"))
#'
#'
#' ggplot(AndOriental) +
#'   geom_sf()
#'
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
esp_get_nuts <- function(year = "2016",
                         epsg = "4258",
                         cache = TRUE,
                         update_cache = FALSE,
                         cache_dir = NULL,
                         verbose = FALSE,
                         resolution = "01",
                         spatialtype = "RG",
                         region = NULL,
                         nuts_level = "all",
                         moveCAN = TRUE) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)
  resolution <- as.character(resolution)
  nuts_level <- as.character(nuts_level)

  cache_dir <- esp_hlp_cachedir(cache_dir)

  if (nchar(resolution) == 1) {
    resolution <- paste0("0", resolution)
  }

  if (!(resolution %in% c("01", "03", "10", "20", "60"))) {
    stop("spatial type should be '01', '03','10','20','60'")
  }

  cache_dir <- esp_hlp_cachedir(cache_dir)

  if (init_epsg == "4258") {
    epsg <- "4326"
  }

  if (!(spatialtype %in% c("RG", "LB"))) {
    stop("spatial type should be 'RG' or 'LB'")
  }

  if (!(nuts_level %in% c("all", "0", "1", "2", "3"))) {
    stop("nuts_level should be 'all', '0','1','2' or '3'")
  }

  # Get region id
  if (is.null(region)) {
    # Get codes from cached data
    # This overcome the issue on giscoR
    # https://github.com/rOpenGov/giscoR/issues/57
    getids <- sf::st_drop_geometry(mapSpain::esp_nuts.sf)

    if (nuts_level != "all") {
      getids <- getids[getids$LEVL_CODE == nuts_level, ]
    }
    nuts_id <- as.character(getids$NUTS_ID)
  } else {
    nuts_id <- esp_hlp_all2nuts(region)

    nuts_id <- nuts_id[!is.na(nuts_id)]
    nuts_id <- unique(nuts_id)

    if (length(nuts_id) == 0) {
      stop(
        "region ",
        paste0("'", region, "'", collapse = ", "),
        " is not a valid name"
      )
    }
  }


  dwnload <- TRUE

  if (all(
    year == "2016", resolution == "01", epsg == "4326", spatialtype == "RG",
    isFALSE(update_cache)
  )) {
    if (verbose) {
      message("Reading from esp_nuts.sf")
    }
    data_sf <- mapSpain::esp_nuts.sf
    if (nuts_level != "all") {
      data_sf <- data_sf[data_sf$LEVL_CODE == nuts_level, ]
    }
    dwnload <- FALSE
  }

  if (isFALSE(dwnload)) {
    # Filter
    if (!is.null(nuts_id)) {
      data_sf <- data_sf[data_sf$NUTS_ID %in% nuts_id, ]
    }
  }

  if (dwnload) {
    data_sf <- giscoR::gisco_get_nuts(
      resolution = resolution,
      year = year,
      epsg = epsg,
      nuts_level = nuts_level,
      cache = cache,
      update_cache = update_cache,
      cache_dir = cache_dir,
      spatialtype = spatialtype,
      nuts_id = nuts_id,
      country = "ES",
      verbose = verbose
    )
  }

  # Checks

  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1
  moving <- isTRUE(moving) & "NUTS_ID" %in% colnames(data_sf)

  if (moving) {
    if (length(grep("ES7", data_sf$NUTS_ID)) > 0) {
      offset <- c(550000, 920000)

      if (length(moveCAN) > 1) {
        coords <- sf::st_point(moveCAN)
        coords <- sf::st_sfc(coords, crs = sf::st_crs(4326))
        coords <- sf::st_transform(coords, 3857)
        coords <- sf::st_coordinates(coords)
        offset <- offset + as.double(coords)
      }

      data_sf <- sf::st_transform(data_sf, 3857)
      penin <- data_sf[-grep("ES7", data_sf$NUTS_ID), ]
      can <- data_sf[grep("ES7", data_sf$NUTS_ID), ]

      # Move can
      can <- sf::st_sf(
        sf::st_drop_geometry(can),
        geometry = sf::st_geometry(can) + offset,
        crs = sf::st_crs(can)
      )

      # Regenerate
      if (nrow(penin) > 0) {
        data_sf <- rbind(penin, can)
      } else {
        data_sf <- can
      }
    }
  }
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  return(data_sf)
}
