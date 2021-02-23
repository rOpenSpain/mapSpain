#' @title Get rivers, channels, reservoirs and other wetlands of Spain
#' @concept mapnatural
#' @name esp_get_rivers
#' @description Loads a simple feature (\code{sf}) object containing lines or
#' areas with the required hydrograpic elements of Spain.
#' @return A \code{POLYGON} of \code{LINESTRING} object.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @source IGN data via a custom CDN (see
#' \url{https://github.com/rOpenSpain/mapSpain/tree/sianedata}).
#' @export
#'
#' @param epsg,cache,update_cache,cache_dir,verbose See
#' \code{\link{esp_get_nuts}}.
#' @param resolution Resolution of the polygon. Values available are
#' \code{"3", "6.5"} or  \code{"10"}.
#' @param spatialtype Spatial type of the output. Use \code{"area"} for
#' \code{POLYGONS} or \code{"line"} for \code{LINESTRING}.
#' @param name Optional. A character or regex expresion with the name of the
#' element to be extracted. See Details
#' @details Metadata available on \url{https://github.com/rOpenSpain/mapSpain/tree/sianedata/data-raw/documentacion_cartosiane}.
#'
#' \code{name} admits regex expresions. See \code{\link[base]{regex}} for more
#' information.
#' @examples
#' \donttest{
#' # This code would produce a nice plot - It will take a few seconds to run
#' library(sf)
#'
#' # Use of regex
#'
#' regex1 <- esp_get_rivers(name = "Tajo|Segura")
#' unique(regex1$rotulo)
#'
#' regex2 <- esp_get_rivers(name = "Tajo$| Segura")
#' unique(regex2$rotulo)
#'
#' # Rivers in Spain
#' shapeEsp <- esp_get_country(moveCAN = FALSE)
#'
#' MainRivers <-
#'   esp_get_rivers(name = "Tajo$|Ebro$|Ebre$|Duero|Guadiana$|Guadalquivir")
#'
#' opar <- par(no.readonly = TRUE)
#' par(mar = c(0, 0, 0, 0))
#'
#' plot(st_geometry(MainRivers), col = "skyblue", lwd = 1.5)
#' plot(st_geometry(shapeEsp), col = NA, add = TRUE)
#'
#' # All wetlands
#'
#' Wetlands <- esp_get_rivers(spatialtype = "area")
#' plot(st_geometry(Wetlands), col = "skyblue", border = NA)
#' plot(st_geometry(shapeEsp), col = NA, add = TRUE)
#'
#' par(opar)
#' }
esp_get_rivers <- function(epsg = "4258",
                           cache = TRUE,
                           update_cache = FALSE,
                           cache_dir = NULL,
                           verbose = FALSE,
                           resolution = 3,
                           spatialtype = "line",
                           name = NULL) {
  # Check epsg
  init_epsg <- as.character(epsg)
  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Valid spatialtype
  validspatialtype <- c("area", "line")

  if (!spatialtype %in% validspatialtype) {
    stop(
      "spatialtype should be one of '",
      paste0(validspatialtype, collapse = "', "),
      "'"
    )
  }

  type <- paste0("river", spatialtype)

  # Get shape
  rivers_sf <-
    esp_hlp_get_siane(
      type,
      resolution,
      cache,
      cache_dir,
      update_cache,
      verbose,
      Sys.Date()
    )

  # Get river names
  rivernames <-
    esp_hlp_get_siane(
      "rivernames",
      resolution,
      cache,
      cache_dir,
      update_cache,
      verbose,
      Sys.Date()
    )



  # Merge names
  rivernames$id_rio <- rivernames$PFAFRIO
  rivernames <- rivernames[, c("id_rio", "NOM_RIO")]

  rivers_sf_merge <- merge(rivers_sf,
    rivernames,
    all.x = TRUE
  )

  if (!is.null(name)) {
    getrows1 <- grep(name, rivers_sf_merge$rotulo)
    getrows2 <- grep(name, rivers_sf_merge$NOM_RIO)
    getrows <- unique(c(getrows1, getrows2))
    rivers_sf_merge <- rivers_sf_merge[getrows, ]

    if (nrow(rivers_sf_merge) == 0) {
      stop(
        "Your value '",
        name,
        "' for name does not produce any result ",
        "for spatialtype = '",
        spatialtype,
        "'"
      )
    }
  }

  if (spatialtype == "area") {
    rivers_sf_merge <-
      rivers_sf_merge[, -match("NOM_RIO", colnames(rivers_sf_merge))]
  }

  rivers_sf_merge <-
    sf::st_transform(rivers_sf_merge, as.double(init_epsg))
  return(rivers_sf_merge)
}
