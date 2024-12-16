#' Get [`sf`][sf::st_sf] `POLYGON` or `LINESTRING` of rivers, channels and other
#' wetlands of Spain
#'
#' @description
#' Loads a [`sf`][sf::st_sf] `POLYGON` or `LINESTRING` object representing
#' rivers, channels, reservoirs and other wetlands of Spain.
#'
#' @family natural
#'
#' @return A [`sf`][sf::st_sf] `POLYGON` or `LINESTRING` object.
#'
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#' @export
#'
#' @param resolution Resolution of the `POLYGON`. Values available are
#'   `"3"`, `"6.5"` or `"10"`.
#'
#' @inheritParams esp_get_hypsobath
#'
#' @param name Optional. A character or  [`regex`][base::grep()] expression
#' with the name of the element(s) to be extracted.
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # Use of regex
#'
#' regex1 <- esp_get_rivers(name = "Tajo|Segura")
#' unique(regex1$rotulo)
#'
#'
#' regex2 <- esp_get_rivers(name = "Tajo$| Segura")
#' unique(regex2$rotulo)
#'
#' # See the diference
#'
#' # Rivers in Spain
#' shapeEsp <- esp_get_country(moveCAN = FALSE)
#'
#' MainRivers <-
#'   esp_get_rivers(name = "Tajo$|Ebro$|Ebre$|Duero|Guadiana$|Guadalquivir")
#'
#' sf::st_bbox(MainRivers)
#' library(ggplot2)
#'
#' ggplot(shapeEsp) +
#'   geom_sf() +
#'   geom_sf(data = MainRivers, color = "skyblue", linewidth = 2) +
#'   coord_sf(
#'     xlim = c(-7.5, 1),
#'     ylim = c(36.8, 43)
#'   ) +
#'   theme_void()
#'
#'
#' # Wetlands in South-West Andalucia
#' and <- esp_get_prov(c("Huelva", "Sevilla", "Cadiz"))
#' Wetlands <- esp_get_rivers(spatialtype = "area")
#'
#' ggplot(and) +
#'   geom_sf() +
#'   geom_sf(
#'     data = Wetlands, fill = "skyblue",
#'     color = "skyblue", alpha = 0.5
#'   ) +
#'   coord_sf(
#'     xlim = c(-7.5, -4.5),
#'     ylim = c(36, 38.5)
#'   ) +
#'   theme_void()
#' }
esp_get_rivers <- function(epsg = "4258", cache = TRUE, update_cache = FALSE,
                           cache_dir = NULL, verbose = FALSE, resolution = "3",
                           spatialtype = "line", name = NULL) {
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
  rivers_sf <- esp_hlp_get_siane(
    type, resolution, cache, cache_dir,
    update_cache, verbose, Sys.Date()
  )

  # Get river names
  rivernames <- esp_hlp_get_siane(
    "rivernames", resolution, cache, cache_dir,
    update_cache, verbose, Sys.Date()
  )

  # Merge names
  rivernames$id_rio <- rivernames$PFAFRIO
  rivernames <- rivernames[, c("id_rio", "NOM_RIO")]

  rivers_sf_merge <- merge(rivers_sf, rivernames, all.x = TRUE)

  if (!is.null(name)) {
    getrows1 <- grep(name, rivers_sf_merge$rotulo)
    getrows2 <- grep(name, rivers_sf_merge$NOM_RIO)
    getrows <- unique(c(getrows1, getrows2))
    rivers_sf_merge <- rivers_sf_merge[getrows, ]

    if (nrow(rivers_sf_merge) == 0) {
      stop(
        "Your value '", name, "' for name does not produce any result ",
        "for spatialtype = '", spatialtype, "'"
      )
    }
  }

  if (spatialtype == "area") {
    rivers_sf_merge <- rivers_sf_merge[, -match(
      "NOM_RIO",
      colnames(rivers_sf_merge)
    )]
  }

  rivers_sf_merge <- sf::st_transform(rivers_sf_merge, as.double(init_epsg))
  return(rivers_sf_merge)
}
