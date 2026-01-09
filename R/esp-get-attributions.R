#' @rdname esp_get_tiles
#'
#' @order 2
#' @description
#'
#' `esp_get_attributions` get the attribution of a tile provider defined as
#' as the `type` argument.
#'
#' @seealso [giscoR::gisco_attributions()]
#'
#' @export
esp_get_attributions <- function(type, options = NULL) {
  # Validate
  prov_list <- validate_provider(type)
  # Add options
  prov_list <- modify_provider_list(prov_list, options)
  att <- ensure_null(prov_list$attribution)
  if (is.null(att)) {
    cli::cli_alert_warning(
      "No attribution found for provider {.str {prov_list$id}}."
    )
  }
  att
}
