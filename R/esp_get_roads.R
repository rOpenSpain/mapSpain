#' Get \CRANpkg{sf} lines of the roads of Spain
#'
#' @description
#' Loads a \CRANpkg{sf} line object representing the main roads of Spain.
#'
#' @family infrastructure
#'
#' @return A \CRANpkg{sf} line object.
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#'
#' @param year Release year. See **Details** for years available.
#' @inheritParams esp_get_nuts
#'
#' @inheritSection esp_get_nuts About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @export
#' @details
#' `year` could be passed as a single year ("YYYY" format, as end of year) or
#' as a specific date ("YYYY-MM-DD" format).
#'
#'
#' @examplesIf esp_check_access()
#' \donttest{
#'
#' country <- esp_get_country()
#' Roads <- esp_get_roads()
#'
#' library(ggplot2)
#'
#' ggplot(country) +
#'   geom_sf(fill = "grey90") +
#'   geom_sf(data = Roads, aes(color = tipo), show.legend = "line") +
#'   scale_color_manual(
#'     values = c("#003399", "#003399", "#ff0000", "#ffff00")
#'   ) +
#'   guides(color = guide_legend(direction = "vertical")) +
#'   theme_minimal() +
#'   labs(color = "Road type") +
#'   theme(legend.position = "bottom")
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
  canbuff <- sf::st_transform(esp_get_ccaa("Canarias", moveCAN = FALSE), 3857)
  canbuff <- sf::st_buffer(sf::st_union(canbuff), 20000)

  can_logic <- sf::st_intersects(data_sf2, canbuff, sparse = FALSE)
  data_sf$codauto <- "XX"
  data_sf[can_logic, ]$codauto <- "05"




  # Move can
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
      penin <- data_sf[-grep("05", data_sf$codauto), ]
      can <- data_sf[grep("05", data_sf$codauto), ]

      # Change geometry name on penin
      penin <- sf::st_sf(
        sf::st_drop_geometry(penin),
        geometry = sf::st_geometry(penin),
        crs = sf::st_crs(penin)
      )

      # Move can
      can <- sf::st_sf(
        sf::st_drop_geometry(can),
        geometry = sf::st_geometry(can) + offset,
        crs = sf::st_crs(can)
      )

      # Regenerate
      data_sf <- rbind(penin, can)
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf <- data_sf[, colnames_init]

  return(data_sf)
}
