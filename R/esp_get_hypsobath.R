#' @title Get hypsometry and bathymetry of Spain
#' @name esp_get_hypsobath
#' @description Loads a simple feature (\code{sf}) object containing lines or
#' areas with the hypsometry and bathymetry of Spain.
#' @return A \code{POLYGON} of \code{LINESTRING} object.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @source IGN data via a custom CDN (see
#' \url{https://github.com/rOpenSpain/mapSpain/tree/sianedata}).
#' @export
#'
#' @param epsg,cache,update_cache,cache_dir,verbose See
#' \code{\link{esp_get_nuts}}.
#' @param resolution Resolution of the shape. Values available are
#' \code{"3"} or \code{"6.5"}.
#' @param spatialtype Spatial type of the output. Use \code{"area"} for
#' \code{POLYGONS} or \code{"line"} for \code{LINESTRING}.
#' @details Metadata available on \url{https://github.com/rOpenSpain/mapSpain/tree/sianedata/data-raw/documentacion_cartosiane}.
#' @examples
#' library(sf)
#' library(cartography)
#'
#' hypsobath <- esp_get_hypsobath()
#'
#' # Tints from Wikipedia
#' # https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Maps/Conventions
#'
#' bath_tints <- colorRampPalette(
#'   rev(
#'     c("#D8F2FE", "#C6ECFF", "#B9E3FF",
#'       "#ACDBFB", "#A1D2F7", "#96C9F0",
#'       "#8DC1EA", "#84B9E3", "#79B2DE",
#'       "#71ABD8")
#'   )
#' )
#'
#' hyps_tints <- colorRampPalette(
#'   rev(
#'     c("#F5F4F2", "#E0DED8", "#CAC3B8", "#BAAE9A",
#'       "#AC9A7C", "#AA8753", "#B9985A", "#C3A76B",
#'       "#CAB982", "#D3CA9D", "#DED6A3", "#E8E1B6",
#'       "#EFEBC0", "#E1E4B5", "#D1D7AB", "#BDCC96",
#'       "#A8C68F", "#94BF8B", "#ACD0A5")
#'   )
#' )
#'
#'
#' # Create palette
#' br_bath <- seq(-6250, -250, 250)
#' br_terrain <- seq(0, 3100, 100)
#'
#'
#' finalbreaks <- sort(unique(c(br_bath, br_terrain)))
#' pal <- c(bath_tints(length(br_bath)), hyps_tints(length(br_terrain)))
#'
#' opar <- par(no.readonly = TRUE)
#'
#'
#' # Plot Canarias
#' opar <- par(no.readonly = TRUE)
#' par(mar = c(0, 0, 0, 0))
#' plot_sf(hypsobath,
#'         xlim = c(-18.6, -13.5),
#'         ylim = c(27.6, 29.5))
#' choroLayer(
#'   hypsobath,
#'   var = "val_inf",
#'   breaks = finalbreaks,
#'   col = pal,
#'   legend.pos = "n",
#'   border = NA,
#'   add = TRUE
#' )
#'
#' # Plot Mainland
#' opar <- par(no.readonly = TRUE)
#' par(mar = c(0, 0, 0, 0))
#' plot_sf(hypsobath,
#'         xlim = c(-9, 4.4),
#'         ylim = c(35.8, 44))
#' choroLayer(
#'   hypsobath,
#'   var = "val_inf",
#'   breaks = finalbreaks,
#'   col = pal,
#'   legend.pos = "n",
#'   border = NA,
#'   add = TRUE
#' )
#'
#' par(opar)


esp_get_hypsobath <- function(epsg = "4258",
                              cache = TRUE,
                              update_cache = FALSE,
                              cache_dir = NULL,
                              verbose = FALSE,
                              resolution = 3,
                              spatialtype = "area") {
  init_epsg <- as.character(epsg)
  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Valid res
  validres <- c("3", "6.5")

  if (!resolution %in% validres) {
    stop("resolution should be one of '",
         paste0(validres, collapse = "', "),
         "'")
  }

  # Valid spatialtype
  validspatialtype <- c("area", "line")

  if (!spatialtype %in% validspatialtype) {
    stop("spatialtype should be one of '",
         paste0(validspatialtype, collapse = "', "),
         "'")
  }

  type <- paste0("orog", spatialtype)

  data_sf <- esp_hlp_get_siane(type,
                               resolution,
                               cache,
                               cache_dir,
                               update_cache,
                               verbose,
                               year = Sys.Date())
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
}
