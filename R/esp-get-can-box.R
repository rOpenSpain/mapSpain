#' Canary Islands inset box and outline
#'
#' @description
#' Create an `sf` `POLYGON` or `LINESTRING` that can be used to mark or
#' frame the Canary Islands when they are displayed as an inset on maps of
#' Spain. This object is useful together with [esp_move_can()] and the
#' `moveCAN` arguments available in other `mapSpain` getters.
#'
#' @details
#' The `style` parameter controls the geometry returned:
#' - `"box"`: a rectangular boundary returned as a `LINESTRING`.
#' - `"poly"`: a slightly expanded rectangle returned as a filled `POLYGON`.
#' - `"left"` / `"right"`: decorative `LINESTRING` variants that follow
#'   the western or eastern side of the islands respectively.
#'
#' @family can_helpers
#' @rdname esp_get_can_box
#' @name esp_get_can_box
#' @inheritParams esp_get_nuts
#' @export
#'
#' @param style character string. One of `"right"`, `"left"`, `"box"` or
#'   `"poly"`. Default is `"right"`, see **Details**.
#'
#' @return
#' An [`sf`][sf::st_sf] object: a `POLYGON` (when `style = "poly"`) or a
#' `LINESTRING` (other styles).
#'
#'
#' @examples
#' provs <- esp_get_prov()
#' box <- esp_get_can_box()
#' line <- esp_get_can_provinces()
#'
#' library(ggplot2)
#' ggplot(provs) +
#'   geom_sf() +
#'   geom_sf(data = box, linewidth = 0.15) +
#'   geom_sf(data = line, linewidth = 0.15) +
#'   theme_linedraw()
#'
#' \donttest{
#' # Displacing the Canary Islands by a custom offset
#' displace <- c(15, 0)
#' provs_disp <- esp_get_prov(moveCAN = displace)
#' box_disp <- esp_get_can_box(style = "left", moveCAN = displace)
#' line_disp <- esp_get_can_provinces(moveCAN = displace)
#' ggplot(provs_disp) +
#'   geom_sf() +
#'   geom_sf(data = box_disp, linewidth = 0.15) +
#'   geom_sf(data = line_disp, linewidth = 0.15) +
#'   theme_linedraw()
#'
#' # Example using the polygon style together with other layers
#' library(giscoR)
#' res <- "20"
#' countries <- gisco_get_countries(
#'   res = res, epsg = "4326",
#'   country = c("France", "Portugal", "Andorra", "Morocco", "Argelia")
#' )
#' can_box <- esp_get_can_box(
#'   style = "poly", epsg = "4326",
#'   moveCAN = c(12.5, 0)
#' )
#' ccaa <- esp_get_ccaa(res = res, epsg = "4326", moveCAN = c(12.5, 0))
#' ggplot(countries) +
#'   geom_sf(fill = "#DFDFDF") +
#'   geom_sf(data = can_box, fill = "#C7E7FB", linewidth = 1) +
#'   geom_sf(data = ccaa, fill = "#FDFBEA") +
#'   coord_sf(xlim = c(-10, 4.3), ylim = c(34.6, 44)) +
#'   theme(
#'     panel.background = element_rect(fill = "#C7E7FB"),
#'     panel.grid = element_blank()
#'   )
#' }
esp_get_can_box <- function(
  style = c("right", "left", "box", "poly"),
  moveCAN = TRUE,
  epsg = 4258
) {
  # checks

  style <- match_arg_pretty(style)

  epsg <- as.character(epsg)

  epsg <- match_arg_pretty(epsg, c("4258", "4326", "3035", "3857"))

  df <- mapSpain::esp_nuts_2024
  can <- df[df$NUTS_ID == "ES7", ]
  can <- sf::st_transform(can, 4326)
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
  lall <- sf::st_zm(lall)

  lall
}

#' Canary Islands province separator line
#'
#' @rdname esp_get_can_box
#'
#' @description
#' `esp_get_can_provinces()` returns a small `LINESTRING` used to mark the
#' separator between the two provinces of the Canary Islands. This helper is
#' intended for cartographic use when composing inset maps of Spain.
#'
#' @source
#' Coordinates of `esp_get_can_provinces()` derived from CartoBase ANE
#' (`se89_mult_admin_provcan_l.shp`).
#'
#' @export
esp_get_can_provinces <- function(moveCAN = TRUE, epsg = "4258") {
  epsg <- as.character(epsg)

  epsg <- match_arg_pretty(epsg, c("4258", "4326", "3035", "3857"))

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
  lall <- sf::st_zm(lall)

  lall
}
