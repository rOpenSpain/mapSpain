#' Get the roads of Spain
#'
#' @description
#' Get roads of Spain
#'
#' @concept infrastructure
#'
#' @return A `LINESTRING\MULTILINESTRING` object.
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
#' @export
#' @details
#' `year` could be passed as a single year ("YYYY" format, as end of year) or
#' as a specific date ("YYYY-MM-DD" format).
#'
#' Details on caching can be found on [esp_get_nuts()]
#'
#' @note While `moveCAN` is useful for visualization, it would alter the
#' actual geographical position of the Canary Islands.
#'
#' @examples
#' \donttest{
#' library(sf)
#' library(cartography)
#'
#' CyL <- esp_get_prov("Castilla y Leon")
#' Roads <- esp_get_roads()
#'
#' # Intersect roads
#' CyL_Roads <- st_intersection(CyL, Roads)
#'
#' plot(st_geometry(CyL), col = "grey80", border = "grey50", lwd = 0.4)
#' typoLayer(CyL_Roads,
#'   var = "tipo",
#'   col = c("#003399", "#003399", "#ff0000", "#ffff00"),
#'   lwd = 2,
#'   add = TRUE,
#'   legend.pos = "n"
#' )
#' }
esp_get_roads <- function(year = Sys.Date(),
                          epsg = "4258",
                          cache = TRUE,
                          update_cache = FALSE,
                          cache_dir = NULL,
                          verbose = FALSE,
                          moveCAN = TRUE) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Get Data from SIANE
  data_sf <- esp_hlp_get_siane(
    "roads",
    3,
    cache,
    cache_dir,
    update_cache,
    verbose,
    year
  )


  colnames_init <- colnames(sf::st_drop_geometry(data_sf))

  # Buffer around Canary Island to identify roads
  data_sf2 <- sf::st_transform(data_sf, 3857)
  CanBuff <- sf::st_transform(esp_get_ccaa("Canarias", moveCAN = FALSE), 3857)
  CanBuff <- sf::st_buffer(sf::st_union(CanBuff), 20000)

  can_logic <- sf::st_intersects(data_sf2, CanBuff, sparse = FALSE)
  data_sf$codauto <- "XX"
  data_sf[can_logic, ]$codauto <- "05"




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

      # Change geometry name on PENIN
      PENIN <- sf::st_sf(
        sf::st_drop_geometry(PENIN),
        geometry = sf::st_geometry(PENIN),
        crs = sf::st_crs(PENIN)
      )

      # Move CAN
      CAN <- sf::st_sf(
        sf::st_drop_geometry(CAN),
        geometry = sf::st_geometry(CAN) + offset,
        crs = sf::st_crs(CAN)
      )

      # Regenerate
      data_sf <- rbind(PENIN, CAN)
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf <- data_sf[, colnames_init]

  return(data_sf)
}
