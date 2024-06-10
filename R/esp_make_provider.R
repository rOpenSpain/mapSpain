#' Create a custom tile provider
#'
#' @description
#' Helper function for [esp_getTiles()] that helps to create a custom provider.
#'
#' @family imagery utilities
#' @seealso [esp_getTiles()].
#'
#' For a list of potential providers from Spain check
#' [IDEE Directory](https://www.idee.es/segun-tipo-de-servicio).
#'
#'
#' @return
#' A named list with two elements `id` and `q`.
#'
#' @export
#'
#' @param id An identifier for the user. Would be used also for identifying
#'   cached tiles.
#'
#' @param q The base url of the service.
#'
#' @param service The type of tile service, either `"WMS"` or `"WMTS"`.
#'
#' @param layers The name of the layer to retrieve.
#'
#' @param ... Additional parameters to the query, like `version`, `format`,
#'   `crs/srs`, `style`, ... depending on the capabilities of the service.
#'
#' @details
#' This function is meant to work with services provided as of the
#' [OGC
#' Standard](http://opengeospatial.github.io/e-learning/wms/text/operations.html#getmap).
#'
#' Note that:
#' - \CRANpkg{mapSpain} would not provide advice on the parameter `q` to be
#'   provided.
#' - Currently, on **WMTS** requests only services with
#'   `tilematrixset=GoogleMapsCompatible` are supported.
#'
#' @examples
#' \dontrun{
#' # This script downloads tiles to your local machine
#' # Run only if you are online
#'
#' custom_wms <- esp_make_provider(
#'   id = "an_id_for_caching",
#'   q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
#'   service = "WMS",
#'   version = "1.3.0",
#'   layers = "geolog_cyl_litologia"
#' )
#'
#' x <- esp_get_ccaa("Castilla y León", epsg = 3857)
#'
#' mytile <- esp_getTiles(x, type = custom_wms)
#'
#' tidyterra::autoplot(mytile) +
#'   ggplot2::geom_sf(data = x, fill = NA)
#' }
esp_make_provider <- function(id, q, service, layers, ...) {
  dots <- list(...)
  names(dots) <- tolower(names(dots))

  # Ignore tilematrixset
  dots <- dots[names(dots) != "tilematrixset"]

  # Minimal for WMS

  if (toupper(service) == "WMS") {
    def_params <- list(
      q = q, request = "GetMap", service = "WMS",
      format = "image/png", layers = layers, styles = ""
    )
  } else {
    def_params <- list(
      q = q, request = "GetTile", service = "WMTS",
      version = "1.0.0", format = "image/png", layer = layers,
      style = "", tilematrixset = "GoogleMapsCompatible"
    )
  }

  # Modify
  end <- modifyList(def_params, dots)


  # Here adjust crs values

  if (end$service == "WMS") {
    if (all(!is.null(end$version), end$version < "1.3.0")) {
      names(end) <- gsub("crs", "srs", names(end))
      end$srs <- ifelse(is.null(end$srs), "EPSG:3857", end$srs)
    } else {
      names(end) <- gsub("srs", "crs", names(end))
      end$crs <- ifelse(is.null(end$crs), "EPSG:3857", end$crs)
    }
  }


  # Create final list
  final <- list(id = id)

  # Create query
  q <- gsub("\\?\\?$", "?", paste0(end$q, "?"))
  rest <- end[names(end) != "q"]
  q_end <- paste0(q, paste0(names(rest), "=", rest, collapse = "&"))

  final$q <- q_end


  return(final)
}
