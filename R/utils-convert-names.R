#' Transform region to NUTS code
#'
#' @param region A name or code of a Spanish region
#'
#' @return A vector of NUTS codes
#'
#' @noRd
convert_to_nuts <- function(region) {
  # Clean up
  clean_region <- unique(region)
  if (any(is.null(region), all(is.na(clean_region)))) {
    cli::cli_alert_warning(
      "Empty {.arg region}. No NUTS codes found, returning NULL."
    )
    return(NULL)
  }
  clean_region <- region[!is.na(clean_region)]

  # Guess type of code for convert: recognize nuts, isos and free text
  is_iso <- grepl("^ES-", clean_region)
  is_nuts <- grepl("^ES[[:digit:]]", clean_region)
  is_text <- !grepl("^ES", clean_region)

  code_type <- clean_region
  code_type[is_iso] <- "iso2"
  code_type[is_nuts] <- "nuts"
  code_type[is_text] <- "text"

  # Made conversions
  n_codes <- seq_along(clean_region)

  # Store names in vector
  nuts_id <- rep(NA, length(clean_region))

  for (i in n_codes) {
    code <- clean_region[i]
    type <- code_type[i]

    nuts_id[i] <- esp_dict_region_code(code, type, "nuts")
  }
  if (all(is.na(nuts_id))) {
    cli::cli_alert_warning(
      "No Spanish NUTS codes found for {.str {clean_region}}. Return NULL."
    )
    return(NULL)
  }

  nuts_id[!is.na(nuts_id)]
}
