#' Get railways of Spain
#'
#' Extract nodes and railways of mainland Spain and the Balearic Islands.
#'
#' @concept infrastructure
#'
#' @return A `MULTILINESTRING` or `POINT` object.
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @author dieghernan, <https://github.com/dieghernan/>.
#'
#' @seealso [esp_get_roads()]
#'
#' @export
#'
#' @details
#'
#' Details on caching can be found on [esp_get_nuts()]
#'
#' @param year Release year.
#'
#' @param spatialtype Spatial type of the output. Use "line" for extracting
#' the railway and "point" for the stations.
#'
#' @inheritParams esp_get_roads
#'
#' @examples
#' library(sf)
#'
#' provs <- esp_get_prov()
#' ccaa <- esp_get_ccaa()
#'
#' # Railways
#' rails <- esp_get_railway()
#'
#' # Stations
#' stations <- esp_get_railway(spatialtype = "point")
#'
#' # Map
#'
#' pal <- hcl.colors(length(unique(rails$tipo)))
#'
#'
#' plot(
#'   st_geometry(provs),
#'   col = "grey95",
#'   border = "grey70",
#'   xlim = c(-7.5, -2.5),
#'   ylim = c(38, 40)
#' )
#' plot(st_geometry(ccaa), add = TRUE)
#' plot(rails[, "tipo"],
#'   pal = pal,
#'   add = TRUE,
#'   lwd = 2
#' )
#' plot(st_geometry(stations),
#'   pch = 19,
#'   col = "grey30",
#'   add = TRUE
#' )
esp_get_railway <- function(year = Sys.Date(),
                            epsg = "4258",
                            cache = TRUE,
                            update_cache = FALSE,
                            cache_dir = NULL,
                            verbose = FALSE,
                            spatialtype = "line") {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }


  # Valid spatialtype
  validspatialtype <- c("line", "point")

  if (!spatialtype %in% validspatialtype) {
    stop(
      "spatialtype should be one of '",
      paste0(validspatialtype, collapse = "', "),
      "'"
    )
  }

  type <- paste0("ffcc", spatialtype)


  data_sf <- esp_hlp_get_siane(type,
    "3",
    cache,
    cache_dir,
    update_cache,
    verbose,
    year = Sys.Date()
  )

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
}
