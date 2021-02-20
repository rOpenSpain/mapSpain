#' @title Get NUTS boundaries of Spain
#' @concept mappolitical
#' @name esp_get_nuts
#' @description Loads a simple feature (\code{sf}) object containing the
#' NUTS boundaries of Spain.
#' @return A \code{POLYGON/POINT} object.
#' @note Please check the download and usage provisions on
#' \code{\link[giscoR]{gisco_attributions}}.
#' @source \href{https://gisco-services.ec.europa.eu/distribution/v2/}{GISCO API}
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @seealso \link{esp_nuts.sf}, \link{esp_dict_region_code},
#' \link{esp_codelist}, \link[giscoR]{gisco_get}.
#' @export
#'
#'
#' @param year Release year. One of \code{"2003", "2006",}
#' \code{"2010", "2013", "2016"} or \code{"2021"}
#' @param resolution Resolution of the geospatial data. One of
#' \itemize{
#'    \item \code{"60"} (1:60million),
#'    \item \code{"20"} (1:20million)
#'    \item \code{"10"} (1:10million)
#'    \item \code{"03"} (1:3million) or
#'    \item \code{"01"} (1:1million).
#'    }
#' @param epsg projection of the map: 4-digit
#' \href{https://epsg.io/}{EPSG code}. One of:
#' \itemize{
#' \item \code{"4258"} - \href{https://epsg.io/4258}{ETRS89}
#' \item \code{"4326"} - \href{https://epsg.io/4326}{WGS84}
#' \item \code{"3035"} - \href{https://epsg.io/3035}{ETRS89 / ETRS-LAEA}
#' \item \code{"3857"} - \href{https://epsg.io/3857}{Pseudo-Mercator}
#' }
#' @param cache A logical whether to do caching. Default is \code{TRUE}.
#' @param update_cache A logical whether to update cache.
#' Default is \code{FALSE}. When set to \code{TRUE} it would force a fresh
#' download of the source \code{.geojson} file.
#' @param cache_dir A path to a cache directory. See Details.
#' @param verbose Display information. Useful for debugging,
#' default is \code{FALSE}.
#' @param resolution Resolution of the geospatial data. One of
#' \itemize{
#'    \item \code{"60"} (1:60million),
#'    \item \code{"20"} (1:20million)
#'    \item \code{"10"} (1:10million)
#'    \item \code{"03"} (1:3million) or
#'    \item \code{"01"} (1:1million).
#'    }
#' @param spatialtype Type of geometry to be returned:
#' \itemize{
#'  \item \code{"RG"}: Regions - \code{MULTIPOLYGON/POLYGON} object.
#'  \item \code{"LB"}: Labels - \code{POINT} object.
#' }
#' @param region Optional. A vector of region names, NUTS or ISO codes
#' (see \link{esp_dict_region_code}).
#' @param nuts_level NUTS level. One of \code{"0"} (Country-level),
#' \code{"1", "2"} or \code{"3"}.
#' See \url{https://ec.europa.eu/eurostat/web/nuts/background}.
#' @param moveCAN A logical \code{TRUE,FALSE} or a vector of coordinates
#' \code{c(lat, lon)}. It places the Canary Island close to Spain's mainland.
#' Initial position can be adjusted using the vector of coordinates.
#' See Note.
#'
#' @details  \code{cache_dir = NULL} (default) uses and creates
#' \code{/mapSpain} directory in the temporary directory from
#' \code{\link{tempdir}}. The directory can also be set with
#' \code{options(mapSpain = "path/to/dir")} or
#' \code{options(gisco_cache_dir = "path/to/dir")}
#' (see \code{\link[giscoR]{gisco_get}})
#'
#' Sometimes cached files may be corrupt. On that case, try redownloading
#' the data setting \code{update_cache = TRUE}.
#'
#' @note While \code{moveCAN} is useful for visualization, it would alter the
#' actual geographical position of the Canary Islands. When using the output
#' for spatial analysis or using tiles (\link{esp_getTiles},
#' \link{addProviderEspTiles}) this option should be set to \code{FALSE} in
#' order to get the actual coordinates.
#'
#' @examples
#'
#' library(sf)
#'
#' pal <- hcl.colors(5, palette = "Lisbon")
#'
#' NUTS1 <- esp_get_nuts(nuts_level = 1, moveCAN = TRUE)
#' plot(st_geometry(NUTS1), col = pal)
#'
#' NUTS1_alt <- esp_get_nuts(nuts_level = 1, moveCAN = c(15, 0))
#' plot(st_geometry(NUTS1_alt), col = pal)
#'
#' NUTS1_orig <- esp_get_nuts(nuts_level = 1, moveCAN = FALSE)
#' plot(st_geometry(NUTS1_orig), col = pal)
#'
#' AndOriental <-
#'   esp_get_nuts(region = c("Almeria", "Granada", "Jaen", "Malaga"))
#' plot(st_geometry(AndOriental), col = pal)
#'
#' RandomRegions <- esp_get_nuts(region = c("ES1", "ES300", "ES51"))
#' plot(st_geometry(RandomRegions), col = pal)
#'
#' MixingCodes <- esp_get_nuts(region = c("ES4", "ES-PV", "Valencia"))
#' plot(st_geometry(MixingCodes), col = pal)
#'
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
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2nuts(region)

    nuts_id <- nuts_id[!is.na(nuts_id)]
    nuts_id <- unique(nuts_id)

    if (length(nuts_id) == 0) {
      stop("region ",
           paste0("'", region, "'", collapse = ", "),
           " is not a valid name")
    }



  }


  dwnload <- TRUE

  if (year == "2016" &
      resolution == "01" &
      epsg == "4326" &
      spatialtype == "RG" & isFALSE(update_cache)) {
    if (verbose)
      message("Reading from esp_nuts.sf")
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
      PENIN <- data_sf[-grep("ES7", data_sf$NUTS_ID), ]
      CAN <- data_sf[grep("ES7", data_sf$NUTS_ID), ]

      # Move CAN
      CAN <- sf::st_sf(
        sf::st_drop_geometry(CAN),
        geometry = sf::st_geometry(CAN) + offset,
        crs = sf::st_crs(CAN)
      )

      #Regenerate
      if (nrow(PENIN) > 0) {
        data_sf <- rbind(PENIN, CAN)
      } else {
        data_sf <- CAN
      }

    }
  }
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  return(data_sf)
}
