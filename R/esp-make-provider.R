#' Create a custom tile provider
#'
#' @description
#' Helper function for [esp_get_tiles()] that helps to create a custom provider.
#'
#' @details
#' This function is meant to work with services provided under the
#' [OGC Standard](https://www.ogc.org/standards/wms/).
#'
#' Note that:
#' - \CRANpkg{mapSpain} does not provide advice on the value of `q`.
#' - Currently, for **WMTS** requests only services with
#'   `tilematrixset=GoogleMapsCompatible` are supported.
#'
#' @param id An identifier for the user. Used for identifying cached tiles.
#' @param q The base URL of the service.
#' @param service The type of tile service, either `"WMS"` or `"WMTS"`.
#' @param layers The name of the layer to retrieve.
#' @param ... Additional arguments to the query, such as `version`, `format`,
#'   `crs/srs` and `style`, depending on the capabilities of the service.
#'
#' @return
#' A named list with two elements `id` and `q`.
#'
#' For a list of potential providers from Spain, check the
#' [IDEE Directory](https://www.idee.es/segun-tipo-de-servicio).
#'
#' @family images
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' \dontrun{
#' custom_wmts <- esp_make_provider(
#'   id = "example",
#'   q = "https://www.ign.es/wmts/ign-base?",
#'   service = "WMTS",
#'   layer = "IGNBaseTodo"
#' )
#'
#' x <- esp_get_ccaa("Castilla y León", epsg = 3857)
#'
#' mytile <- esp_get_tiles(x, type = custom_wmts)
#'
#' tidyterra::autoplot(mytile) +
#'   ggplot2::geom_sf(data = x, fill = NA)
#' }
esp_make_provider <- function(id, q, service, layers, ...) {
  id <- validate_non_empty_arg(id)
  q <- validate_non_empty_arg(q)
  service <- validate_non_empty_arg(service)
  layers <- validate_non_empty_arg(layers)

  dots <- list(...)
  names(dots) <- tolower(names(dots))

  # Ignore `tilematrixset`.
  dots <- dots[names(dots) != "tilematrixset"]

  # Set minimal WMS parameters.

  if (toupper(service) == "WMS") {
    def_params <- list(
      q = q,
      request = "GetMap",
      service = "WMS",
      format = "image/png",
      layers = layers,
      styles = ""
    )
  } else {
    def_params <- list(
      q = q,
      request = "GetTile",
      service = "WMTS",
      version = "1.0.0",
      format = "image/png",
      layer = layers,
      style = "",
      tilematrixset = "GoogleMapsCompatible"
    )
  }

  # Merge custom query parameters.
  end <- modifyList(def_params, dots)

  # Adjust CRS/SRS parameter names.

  if (end$service == "WMS") {
    if (all(!is.null(end$version), end$version < "1.3.0")) {
      names(end) <- gsub("crs", "srs", names(end), fixed = TRUE)
      end$srs <- ifelse(is.null(end$srs), "EPSG:3857", end$srs)
    } else {
      names(end) <- gsub("srs", "crs", names(end), fixed = TRUE)
      end$crs <- ifelse(is.null(end$crs), "EPSG:3857", end$crs)
    }
  }

  # Create the final provider list.
  final <- list(id = id)

  # Create the query URL.
  q <- gsub("\\?\\?$", "?", paste0(end$q, "?"))
  rest <- end[names(end) != "q"]
  q_end <- paste0(q, paste0(names(rest), "=", rest, collapse = "&"))

  final$q <- q_end

  final
}
