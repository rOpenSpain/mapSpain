#' @title Get the drainage basin demarcations of Spain
#' @concept mapnatural
#' @name esp_get_hydrobasin
#' @description Loads a simple feature (\code{sf}) object containing areas
#' with the required hydrograpic elements of Spain.
#' @return A \code{POLYGON} object.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @source IGN data via a custom CDN (see
#' \url{https://github.com/rOpenSpain/mapSpain/tree/sianedata}).
#' @export
#'
#' @param epsg,cache,update_cache,cache_dir,verbose See
#' \code{\link{esp_get_nuts}}.
#' @param resolution Resolution of the polygon. Values available are
#' \code{"3", "6.5"} or  \code{"10"}.
#' @param domain Possible values are \code{"land"} or \code{"landsea"}, that
#' includes only the ground part or the ground and the related sea waters
#' related with the basin
#' @details Metadata available on \url{https://github.com/rOpenSpain/mapSpain/tree/sianedata/data-raw/documentacion_cartosiane}.
#'
#' @examples
#' library(sf)
#' all <- esp_get_prov()
#' mainland <-
#'   all[all$codauto != esp_dict_region_code("Canarias", destination = "codauto"), ]
#' hydroland <- esp_get_hydrobasin(domain = "land")
#' hydrolandsea <- esp_get_hydrobasin(domain = "landsea")
#'
#' # Plot
#' opar <- par(no.readonly = TRUE)
#'
#' par(mar = c(0, 0, 0, 0))
#'
#' # Background
#' plot(st_as_sfc(st_bbox(mainland)), col = "grey90", border = NA)
#'
#' plot(
#'   st_geometry(hydrolandsea),
#'   col = "skyblue3",
#'   border = NA,
#'   add = TRUE
#' )
#' plot(
#'   st_geometry(mainland),
#'   col = "grey70",
#'   border = "grey50",
#'   add = TRUE
#' )
#' plot(
#'   st_geometry(hydroland),
#'   col = adjustcolor("skyblue", alpha.f = 0.5),
#'   add = TRUE,
#'   border = "lightblue"
#' )
#'
#' par(opar)
esp_get_hydrobasin <- function(epsg = "4258",
                               cache = TRUE,
                               update_cache = FALSE,
                               cache_dir = NULL,
                               verbose = FALSE,
                               resolution = 3,
                               domain = "land") {
  # Check epsg
  init_epsg <- as.character(epsg)
  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Valid spatialtype
  validdomain <- c("land", "landsea")

  if (!domain %in% validdomain) {
    stop(
      "domain should be one of '",
      paste0(validdomain, collapse = "', "),
      "'"
    )
  }

  type <- paste0("basin", domain)
  basin_sf <-
    esp_hlp_get_siane(
      type,
      resolution,
      cache,
      cache_dir,
      update_cache,
      verbose,
      Sys.Date()
    )

  basin_sf <-
    sf::st_transform(basin_sf, as.double(init_epsg))

  return(basin_sf)
}
