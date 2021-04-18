#' Get complementary lines when plotting Canary Islands.
#'
#' @concept political
#'
#' @rdname esp_get_can_box
#'
#' @description
#' When plotting Spain, it is usual to represent the Canary Islands as an inset
#' (see `moveCAN` on [esp_get_nuts()]. These functions provides complementary
#' borders when Canary Islands are displaced.
#'
#' `esp_get_can_box` is used to draw lines around the displaced Canary Islands.
#'
#' @return A `LINESTRING` or `POLYGON` object if `style = "poly"`.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @seealso [esp_get_nuts()], [esp_get_ccaa()].
#'
#' @export
#'
#' @param style Style of line around Canary Islands. Four options available:
#'   "left", "right", "box" or "poly".
#'
#' @inheritParams esp_get_nuts
#'
#' @examples
#' Provs <- esp_get_prov()
#' Box <- esp_get_can_box()
#' Line <- esp_get_can_provinces()
#'
#' # Plot
#'
#' library(tmap)
#'
#'
#' tm_shape(Provs) +
#'   tm_polygons() +
#'   tm_shape(Box) +
#'   tm_lines() +
#'   tm_shape(Line) +
#'   tm_lines()
#'
#'
#'
#' # Displacing Canary
#'
#' Provs_D <- esp_get_prov(moveCAN = c(15, 0))
#' Box_D <- esp_get_can_box(style = "left", moveCAN = c(15, 0))
#' Line_D <- esp_get_can_provinces(moveCAN = c(15, 0))
#'
#' tm_shape(Provs_D) +
#'   tm_polygons() +
#'   tm_shape(Box_D) +
#'   tm_lines() +
#'   tm_shape(Line_D) +
#'   tm_lines()
#'
#'
#' # Example with poly option
#'
#' # Get countries with giscoR
#' \donttest{
#' library(giscoR)
#'
#' # Low resolution map
#' res <- "20"
#'
#' Countries <-
#'   gisco_get_countries(
#'     res = res,
#'     epsg = "4326",
#'     country = c("France", "Portugal", "Andorra", "Morocco", "Argelia")
#'   )
#' CANbox <-
#'   esp_get_can_box(
#'     style = "poly",
#'     epsg = "4326",
#'     moveCAN = c(12.5, 0)
#'   )
#'
#' CCAA <- esp_get_ccaa(
#'   res = res,
#'   epsg = "4326",
#'   moveCAN = c(12.5, 0) # Same displacement factor)
#' )
#'
#' # Plot
#'
#' tm_shape(Countries, bbox = c(-10, 34.6, 4.3, 44)) +
#'   tm_polygons(col = "#DFDFDF") +
#'   tm_shape(CANbox) +
#'   tm_polygons(col = "#C7E7FB") +
#'   tm_shape(CANbox) +
#'   tm_borders(lwd = 2) +
#'   tm_shape(CCAA) +
#'   tm_polygons("#FDFBEA") +
#'   tm_graticules(lines = FALSE) +
#'   tm_layout(bg.color = "#C7E7FB", frame.double.line = TRUE)
#' }
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
    bbox <- bbox + c(-0.5, -0.3, 0.5, 0.3)

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
#'
#' @concept political
#'
#' @description
#' `esp_get_can_provinces` is used to draw a separator line between the two
#' provinces of the Canary Islands.
#'
#' @return `esp_get_can_provinces` returns a `LINESTRING` object.
#'
#' @source
#' `esp_get_can_provinces` extracted from CartoBase ANE,
#' `se89_mult_admin_provcan_l.shp` file.
#'
#' @export
esp_get_can_provinces <- function(moveCAN = TRUE,
                                  epsg = "4258") {
  epsg <- as.character(epsg)

  if (!epsg %in% c("4258", "4326", "3035", "3857")) {
    stop("epsg should be one of '4258','4326','3035', '3857'")
  }

  # From CartoBase ANE: se89_mult_admin_provcan_l
  m <- c(
    sf::st_point(c(-16.29902, 27.71454)),
    sf::st_point(c(-15.69362, 28.78078))
  )

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
