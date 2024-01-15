#' Get \CRANpkg{sf} lines and polygons for insetting the Canary Islands
#'
#' @description
#' When plotting Spain, it is usual to represent the Canary Islands as an inset
#' (see `moveCAN` on [esp_get_nuts()]). These functions provides complementary
#' lines and polygons to be used when the Canary Islands are displayed
#' as an inset.
#'
#' * [esp_get_can_box()] is used to draw lines around the displaced Canary
#'   Islands.
#'
#' @family political
#' @family Canary Islands
#'
#' @rdname esp_get_can_box
#'
#' @name esp_get_can_box
#'
#' @return A \CRANpkg{sf} polygon or line depending of `style` parameter.
#'
#'
#' @export
#'
#' @param style Style of line around Canary Islands. Four options available:
#'   `"left"`, `"right"`, `"box"` or `"poly"`.
#'
#' @inheritParams esp_get_nuts
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @examples
#'
#' Provs <- esp_get_prov()
#' Box <- esp_get_can_box()
#' Line <- esp_get_can_provinces()
#'
#' # Plot
#' library(ggplot2)
#'
#' ggplot(Provs) +
#'   geom_sf() +
#'   geom_sf(data = Box) +
#'   geom_sf(data = Line) +
#'   theme_linedraw()
#' \donttest{
#' # Displacing Canary
#'
#' # By same factor
#'
#' displace <- c(15, 0)
#'
#' Provs_D <- esp_get_prov(moveCAN = displace)
#'
#' Box_D <- esp_get_can_box(style = "left", moveCAN = displace)
#'
#' Line_D <- esp_get_can_provinces(moveCAN = displace)
#'
#' ggplot(Provs_D) +
#'   geom_sf() +
#'   geom_sf(data = Box_D) +
#'   geom_sf(data = Line_D) +
#'   theme_linedraw()
#'
#'
#' # Example with poly option
#'
#' # Get countries with giscoR
#'
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
#' ggplot(Countries) +
#'   geom_sf(fill = "#DFDFDF") +
#'   geom_sf(data = CANbox, fill = "#C7E7FB", linewidth = 1) +
#'   geom_sf(data = CCAA, fill = "#FDFBEA") +
#'   coord_sf(
#'     xlim = c(-10, 4.3),
#'     ylim = c(34.6, 44)
#'   ) +
#'   theme(
#'     panel.background = element_rect(fill = "#C7E7FB"),
#'     panel.grid = element_blank()
#'   )
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

  can <- esp_get_ccaa("Canarias", epsg = "4326", moveCAN = FALSE)
  bbox <- sf::st_bbox(can)


  if (style == "box" || style == "poly") {
    bbox <- bbox + c(-0.5, -0.3, 0.5, 0.3)

    lall <- sf::st_as_sfc(bbox, crs = sf::st_crs(can))
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
    lall <- sf::st_sfc(lall, crs = sf::st_crs(can))
  } else if (style == "left") {
    bbox <- bbox + c(-0.5, 0, 0, 0.3)

    p1 <- sf::st_point(c(bbox[1], bbox[2]))
    p2 <- sf::st_point(c(bbox[1], bbox[4] - 0.5))
    p3 <- sf::st_point(c(bbox[1] + 0.5, bbox[4]))
    p4 <- sf::st_point(c(bbox[3], bbox[4]))

    pall <- c(p1, p2, p3, p4)
    lall <- sf::st_linestring(sf::st_coordinates(pall))
    lall <- sf::st_sfc(lall, crs = sf::st_crs(can))
  }

  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    lall <- esp_move_can(lall, moveCAN = moveCAN)
  }

  # Transform

  lall <- sf::st_transform(lall, as.numeric(epsg))

  return(lall)
}

#' @rdname esp_get_can_box
#'
#'
#' @description
#' * [esp_get_can_provinces()] is used to draw a separator line between the two
#' provinces of the Canary Islands.
#'
#' See also [esp_move_can()] to displace stand-alone objects on the Canary
#' Islands.
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
    lall <- esp_move_can(lall, moveCAN = moveCAN)
  }

  # Transform

  lall <- sf::st_transform(lall, as.numeric(epsg))

  return(lall)
}
