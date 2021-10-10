#' Get `sf` points of the municipalities of Spain
#'
#' @description
#' Get a `sf` point with the location of the political powers for
#' each municipality (possibly the center of the municipality).
#'
#' Note that this differs of the centroid of the boundaries of the
#' municipality, returned by [esp_get_munic()].
#'
#' @family political
#' @family municipalities
#'
#' @return A `sf` point object.
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
#' `year` could be passed as a single year ("YYYY" format, as end of year) or
#' as a specific date ("YYYY-MM-DD" format). Historical information starts as
#' of 2005.
#'
#' When using `region` you can use and mix names and NUTS codes (levels 1,
#' 2 or 3), ISO codes (corresponding to level 2 or 3) or "cpro". See
#' [esp_codelist]
#'
#' When calling a superior level (Province, Autonomous Community or NUTS1) ,
#' all the municipalities of that level would be added.
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
#' tile <- esp_getTiles(area, zoommin = 2)
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
#'
#' ggplot(points) +
#'   layer_spatraster(tile) +
#'   geom_sf(data = area, fill = NA, color = "blue") +
#'   geom_sf(data = points, aes(fill = type), size = 5, shape = 21) +
#'   scale_fill_manual(values = c("green", "red")) +
#'   theme_void() +
#'   labs(title = "Centroid vs. capimun")
#' }
esp_get_capimun <- function(year = Sys.Date(),
                            epsg = "4258",
                            cache = TRUE,
                            update_cache = FALSE,
                            cache_dir = NULL,
                            verbose = FALSE,
                            region = NULL,
                            munic = NULL,
                            moveCAN = TRUE,
                            rawcols = FALSE) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Get Data from SIANE
  data_sf <- esp_hlp_get_siane(
    "capimun",
    3,
    cache,
    cache_dir,
    update_cache,
    verbose,
    year
  )

  colnames_init <- colnames(sf::st_drop_geometry(data_sf))
  df <- data_sf

  # Name management
  df$LAU_CODE <- df$id_ine
  df$name <- df$rotulo
  df$cpro <- substr(df$id_ine, 1, 2)

  idprov <- sort(unique(mapSpain::esp_codelist$cpro))
  df$cmun <- ifelse(substr(df$LAU_CODE, 1, 2) %in% idprov,
    substr(df$LAU_CODE, 3, 8),
    NA
  )

  cod <-
    unique(mapSpain::esp_codelist[, c(
      "codauto",
      "ine.ccaa.name",
      "cpro", "ine.prov.name"
    )])

  df2 <- merge(df,
    cod,
    by = "cpro",
    all.x = TRUE,
    no.dups = TRUE
  )

  data_sf <- df2

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data_sf <- data_sf[grep(munic, data_sf$name), ]
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
    stop(
      "The combination of region and/or munic does ",
      "not return any result"
    )
  }
  # Move CAN

  # Checks
  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    if (length(grep("05", data_sf$codauto)) > 0) {
      offset <- c(550000, 920000)

      if (length(moveCAN) > 1) {
        coords <- sf::st_point(moveCAN)
        coords <- sf::st_sfc(coords, crs = sf::st_crs(4326))
        coords <- sf::st_transform(coords, 3857)
        coords <- sf::st_coordinates(coords)
        offset <- offset + as.double(coords)
      }

      data_sf <- sf::st_transform(data_sf, 3857)
      penin <- data_sf[-grep("05", data_sf$codauto), ]
      can <- data_sf[grep("05", data_sf$codauto), ]

      # Move CAN
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
  data_sf <-
    data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$cmun), ]

  namesend <- unique(c(
    colnames_init,
    c(
      "codauto",
      "ine.ccaa.name",
      "cpro",
      "ine.prov.name",
      "cmun",
      "name",
      "LAU_CODE"
    ),
    colnames(data_sf)
  ))

  data_sf <- data_sf[, namesend]

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
  return(data_sf)
}
