#' @title Get complementary lines when plotting Canary Islands.
#' @name esp_get_can_box
#' @description When plotting Spain, it is usual to represent the Canary
#' Islands as an inset (see \code{moveCAN} on \link{esp_get_nuts}). These
#' functions provides complementary borders when Canary Islands are displaces.
#'
#' \code{esp_get_can_box} is used to draw lines around the displaced
#' Canary Islands.
#' @return A \code{LINESTRING} or \code{POLYGON} object if
#' \code{style = 'poly'}.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @seealso \link{esp_get_nuts}, \link{esp_get_ccaa}.
#' @export
#'
#' @param style Style of line around Canary Islands. Four options available:
#' \code{'left', 'right', 'box'} or \code{'poly'}.
#' @param moveCAN,epsg See \link{esp_get_nuts}
#' @examples
#' library(sf)
#'
#' Provs <-  esp_get_prov()
#' Box <- esp_get_can_box()
#' Line <- esp_get_can_provinces()
#'
#'
#' plot(st_geometry(Provs), col = hcl.colors(4, palette = "Grays"))
#' plot(Box, add = TRUE)
#' plot(Line, add = TRUE)
#'
#'
#' # Displacing Canary
#'
#' Provs_D <-  esp_get_prov(moveCAN = c(15, 0))
#' Box_D <- esp_get_can_box(style = "left", moveCAN = c(15, 0))
#' Line_D <- esp_get_can_provinces(moveCAN = c(15, 0))
#'
#'
#'
#' plot(st_geometry(Provs_D), col = hcl.colors(4, palette = "Grays"))
#' plot(Box_D, add = TRUE)
#' plot(Line_D, add = TRUE)
#'
#' # Example with poly option
#'
#' library(giscoR)
#'
#' Countries <-
#'   gisco_get_countries(res = "20",
#'                       epsg = "4326",
#'                       region = c("Europe", "Africa"))
#' CANbox <-
#'   esp_get_can_box(style = "poly",
#'                   epsg = "4326",
#'                   moveCAN = c(12.5, 0))
#' CCAA <- esp_get_ccaa(res = "20",
#'                      epsg = "4326",
#'                      moveCAN = c(12.5, 0))
#'
#'
#' plot_sf(CCAA, axes = TRUE, bgc = "skyblue1")
#' plot(st_geometry(Countries), col = "grey80", add = TRUE)
#' plot(st_geometry(CANbox),
#'      border = "black",
#'      col = "skyblue",
#'      add = TRUE)
#' plot(st_geometry(CCAA), add = TRUE, col = "beige")
#' box()
esp_get_can_box <- function(style = "right",
                            moveCAN = TRUE,
                            epsg = "4258") {
  # checks
  if (!style %in% c("left", "right", "box", "poly")) {
    stop("style should be one of 'right','left','box'")
  }


  epsg <- as.character(epsg)

  if (!epsg %in% c("4258", "4326", "3035", "3857")) {
    stop("epsg should be one of '4258','4326','3035', '3857'")
  }


  CAN <- esp_get_ccaa("Canarias", epsg = "4326", moveCAN = FALSE)

  bbox <- sf::st_bbox(CAN)


  if (style == "box" | style == "poly") {
    bbox <- bbox + c(-0.5,-0.3, 0.5, 0.3)

    lall <- sf::st_as_sfc(bbox, crs = sf::st_crs(CAN))
    if (style == "box") {
      lall <- sf::st_cast(lall, "LINESTRING")
    }

  } else if (style == "right") {
    bbox <- bbox + c(0, 0, 0.5, 0.3)

    # Create points
    p1 <- sf::st_point(c(bbox[3], bbox[2]))
    p2 <- sf::st_point(c(bbox[3], bbox[4] - 0.5))
    p3 <- sf::st_point(c(bbox[3] - 0.5, bbox[4]))
    p4 <- sf::st_point(c(bbox[1], bbox[4]))

    pall <- c(p1, p2, p3, p4)
    lall <- sf::st_linestring(sf::st_coordinates(pall))
    lall <- sf::st_sfc(lall, crs = sf::st_crs(CAN))
  } else if (style == "left") {
    bbox <- bbox + c(-0.5, 0, 0, 0.3)

    p1 <- sf::st_point(c(bbox[1], bbox[2]))
    p2 <- sf::st_point(c(bbox[1], bbox[4] - 0.5))
    p3 <- sf::st_point(c(bbox[1] + 0.5, bbox[4]))
    p4 <- sf::st_point(c(bbox[3], bbox[4]))

    pall <- c(p1, p2, p3, p4)
    lall <- sf::st_linestring(sf::st_coordinates(pall))
    lall <- sf::st_sfc(lall, crs = sf::st_crs(CAN))

  }

  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    offset <- c(550000, 920000)

    if (length(moveCAN) > 1) {
      coords <- sf::st_point(moveCAN)
      coords <- sf::st_sfc(coords, crs = sf::st_crs(4326))
      coords <- sf::st_transform(coords, 3857)
      coords <- sf::st_coordinates(coords)
      offset <- offset + as.double(coords)
    }

    CAN <- sf::st_transform(lall, 3857) + offset
    CAN <- sf::st_sfc(CAN, crs = 3857)
    CAN <- sf::st_transform(CAN, sf::st_crs(lall))
    lall <- CAN
  }

  # Transform

  lall <- sf::st_transform(lall, as.numeric(epsg))

  return(lall)

}

#' @rdname esp_get_can_box
#' @description \code{esp_get_can_provinces} is used to draw a separator
#' line between the two provinces of the Canary Islands.
#' @return \code{esp_get_can_provinces} returns a \code{LINESTRING} object.
#' @export
esp_get_can_provinces <- function(moveCAN = TRUE,
                                  epsg = "4258") {
  epsg <- as.character(epsg)

  if (!epsg %in% c("4258", "4326", "3035", "3857")) {
    stop("epsg should be one of '4258','4326','3035', '3857'")
  }


  m <- c(sf::st_point(c(-15.25274, 29.20)),
         sf::st_point(c(-16.4, 27.639)))

  lall <- sf::st_linestring(sf::st_coordinates(m))
  lall <- sf::st_sfc(lall, crs = sf::st_crs(4326))

  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    offset <- c(550000, 920000)

    if (length(moveCAN) > 1) {
      coords <- sf::st_point(moveCAN)
      coords <- sf::st_sfc(coords, crs = sf::st_crs(4326))
      coords <- sf::st_transform(coords, 3857)
      coords <- sf::st_coordinates(coords)
      offset <- offset + as.double(coords)
    }

    CAN <- sf::st_transform(lall, 3857) + offset
    CAN <- sf::st_sfc(CAN, crs = 3857)
    CAN <- sf::st_transform(CAN, sf::st_crs(lall))
    lall <- CAN
  }

  # Transform

  lall <- sf::st_transform(lall, as.numeric(epsg))

  return(lall)

}
