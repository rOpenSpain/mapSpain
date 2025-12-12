#' Displace a [`sf`][sf::st_sf] object located in the Canary Islands
#'
#' @description
#' Helper function to displace an external [`sf`][sf::st_sf] object (potentially
#' representing a location in the Canary Islands) to align it with the objects
#' provided by [`sf`][sf::st_sf] with the option `moveCAN = TRUE`.
#'
#'
#' @param x An [`sf`][sf::st_sf] object. It may be `sf` or `sfc` object.
#' @param moveCAN A logical `TRUE/FALSE` or a vector of coordinates
#'   `c(lat, lon)`.
#'
#' @return A [`sf`][sf::st_sf] object of the same class and same CRS than `x`
#' but displaced accordingly.
#'
#' @details
#' This is a helper function that intends to ease the representation of objects
#' located in the Canary Islands that have been obtained from other sources
#' rather than the package \CRANpkg{mapSpain}.
#'
#' @family helper
#' @family Canary Islands
#'
#'
#' @export
#'
#' @examples
#' library(sf)
#' teide <- data.frame(
#'   name = "Teide Peak",
#'   lon = -16.6437593,
#'   lat = 28.2722883
#' )
#'
#' teide_sf <- st_as_sf(teide, coords = c("lon", "lat"), crs = 4326)
#'
#' # If we use any mapSpain produced object with moveCAN = TRUE...
#'
#' esp <- esp_get_country(moveCAN = c(13, 0))
#'
#' library(ggplot2)
#'
#'
#' ggplot(esp) +
#'   geom_sf() +
#'   geom_sf(data = teide_sf, color = "red") +
#'   labs(
#'     title = "Canary Islands displaced",
#'     subtitle = "But not the external Teide object"
#'   )
#'
#'
#' # But we can
#'
#' teide_sf_disp <- esp_move_can(teide_sf, moveCAN = c(13, 0))
#'
#' ggplot(esp) +
#'   geom_sf() +
#'   geom_sf(data = teide_sf_disp, color = "red") +
#'   labs(
#'     title = "Canary Islands displaced",
#'     subtitle = "And also the external Teide object"
#'   )
#'
esp_move_can <- function(x, moveCAN = TRUE) {
  if (!any(inherits(x, "sf"), inherits(x, "sfc"))) {
    cli::cli_abort(
      paste0(
        "{.arg x} should be an {.cls sf} ",
        "or {.cls sfc} object, not {.obj_type_friendly {x}}."
      )
    )
  }

  is_sfc <- inherits(x, "sfc")

  # If no object then return the same
  g <- sf::st_geometry(x)

  if (length(g) == 0) {
    return(x)
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

    data_3857 <- sf::st_transform(x, 3857)
    if (is_sfc) {
      data_3857 <- sf::st_sf(x = 1, geometry = data_3857)
    }

    # Move can
    geom_mov <- sf::st_geometry(data_3857) + offset
    df <- sf::st_drop_geometry(data_3857)
    can <- sf::st_sf(df, geometry = geom_mov, crs = 3857)

    # Regenerate CRS
    x_out <- sf::st_transform(can, sf::st_crs(x))

    if (is_sfc) {
      x_out <- sf::st_geometry(x_out)
    } else {
      # Rename sf col
      sf::st_geometry(x_out) <- attr(x, "sf_column")
    }
  } else {
    x_out <- x
  }
  x_out
}
