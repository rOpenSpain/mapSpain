#' Get the location of municipalities of Spain
#'
#' @description
#' Get the location of the political powers for each municipality (possibly
#' the center of the municipality).
#'
#' Note that this differs of the centroid of the boundaries of the
#' municipallity, returned by [esp_get_munic()].
#'
#' @concept political
#'
#' @return A `POINT` object.
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @author dieghernan, <https://github.com/dieghernan/>.
#' @seealso [esp_get_munic()], [esp_munic.sf], [esp_codelist]
#'
#' @param year Release year. See Details for years available.
#' @inheritParams esp_get_nuts
#' @inheritParams esp_get_munic
#'
#' @details
#' `year` could be passed as a single year ("YYYY" format, as end of year) or
#' as a specific date ("YYYY-MM-DD" format).
#' Historical information starts as of 2005.
#'
#' When using `region` you can use and mix names and NUTS codes (levels 1,
#' 2 or 3), ISO codes (corresponding to level 2 or 3) or `cpro`.
#'
#' When calling a superior level (Province, Autonomous Community or NUTS1) ,
#' all the municipalities of that level would be added.
#' @export
#'
#' @note While `moveCAN` is useful for visualization, it would alter the
#' actual geographical position of the Canary Islands.
#'
#' @examples
#' \donttest{
#' # This code compares centroid of municipalities against esp_get_capimun
#' library(sf)
#'
#' # Get shape
#' area <- esp_get_munic_siane(munic = "Peguerinos", epsg = 3857)
#'
#' # Area in km2
#' print(paste0(round(as.double(st_area(area)) / 1000000, 2), " km2"))
#'
#' # Extract centroid
#' centroid <- st_centroid(st_geometry(area))
#'
#' # Compare with capimun
#' capimun <- esp_get_capimun(munic = "Peguerinos", epsg = 3857)
#'
#' # Buffer points
#' bbox <- st_union(st_buffer(
#'   c(centroid, st_geometry(capimun)),
#'   dist = 2000
#' ))
#'
#' # Get a tile to check
#' tile <- esp_getTiles(bbox, type = "IGNBase.Gris")
#'
#' # Check on plot
#' raster::plotRGB(tile)
#' plot(centroid, add = TRUE, pch = 19, col = "red") # Centroid
#' plot(st_geometry(capimun), add = TRUE, pch = 19, col = "blue") # Capimun
#'
#' # Blue dot is located onto the actual city while red dot is located
#' # in the centroid of the boundaries
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
      PENIN <- data_sf[-grep("05", data_sf$codauto), ]
      CAN <- data_sf[grep("05", data_sf$codauto), ]

      # Move CAN
      CAN <- sf::st_sf(
        sf::st_drop_geometry(CAN),
        geometry = sf::st_geometry(CAN) + offset,
        crs = sf::st_crs(CAN)
      )

      # Regenerate
      if (nrow(PENIN) > 0) {
        data_sf <- rbind(PENIN, CAN)
      } else {
        data_sf <- CAN
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
