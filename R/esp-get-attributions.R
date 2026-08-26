#' Get the attribution for a tile provider
#'
#' `esp_get_attributions()` returns the attribution for a tile provider defined
#' by the `type` argument.
#'
#' @inheritParams esp_get_tiles
#' @return A character string with the provider attribution, or `NULL` if no
#'   attribution is available.
#'
#' @seealso
#' - [esp_get_tiles()] downloads static map tiles.
#' - [giscoR::gisco_attributions()] provides GISCO attribution text.
#'
#' @family images
#' @encoding UTF-8
#' @export
#'
#' @examples
#' esp_get_attributions("IGNBase.Todo")
esp_get_attributions <- function(type, options = NULL) {
  # Validate provider.
  prov_list <- validate_provider(type)
  # Add options.
  prov_list <- modify_provider_list(prov_list, options)
  att <- ensure_null(prov_list$attribution)
  if (is.null(att)) {
    cli::cli_warn("No attribution found for provider {.str {prov_list$id}}.")
  }
  att
}
