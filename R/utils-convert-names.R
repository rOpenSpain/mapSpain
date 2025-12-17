#' Transform region to NUTS code
#' @param region A vector of region names or codes (NUTS or ISO2).
#' @return A vector of NUTS codes or `NULL` if no valid code found.
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

  sort(nuts_id[!is.na(nuts_id)])
}

#' Transform region to NUTS code for CCAA (NUTS 2)
#' @param region A vector of region names or codes (NUTS or ISO2).
#' @return A vector of NUTS codes for CCAA (level 2) or `NULL` if no valid
#'   code found.
#'
#' @noRd
convert_to_nuts_ccaa <- function(region) {
  # Clean up
  clean_region <- unique(region)
  if (any(is.null(region), all(is.na(clean_region)))) {
    cli::cli_alert_warning(
      "Empty {.arg region}. No CCAA codes found, returning NULL."
    )
    return(NULL)
  }
  clean_region <- region[!is.na(clean_region)]

  # Guess type of code for convert: recognize nuts, isos and free text
  is_codauto <- grepl("^[[:digit:]]", region)

  code_type <- clean_region
  code_type[is_codauto] <- "codauto"
  code_type[!is_codauto] <- "text"

  # Made conversions
  n_codes <- seq_along(clean_region)

  # Store names in vector
  ccaa_id <- rep(NA, length(clean_region))

  for (i in n_codes) {
    code <- clean_region[i]
    type <- code_type[i]
    if (type == "codauto") {
      code <- esp_dict_region_code(code, "codauto", "nuts")
    }

    res <- convert_to_nuts(code)
    if (is.null(res)) {
      res <- NA
    }
    ccaa_id[i] <- res
  }

  if (all(is.na(ccaa_id))) {
    return(NULL)
  }

  clean_region <- clean_region[!is.na(ccaa_id)]
  ccaa_id <- ccaa_id[!is.na(ccaa_id)]

  # Fix Ceuta and Melilla
  ccaa_id[grep("ES640", ccaa_id)] <- "ES64"
  ccaa_id[grep("ES630", ccaa_id)] <- "ES63"

  novalid <- nchar(ccaa_id) > 4

  if (any(novalid)) {
    cli::cli_alert_warning(
      paste0(
        "{.str {clean_region[novalid]}} {?does/do} not return ",
        "a Autonomous Community."
      )
    )
  }

  ccaa_id[novalid] <- NA

  if (all(is.na(ccaa_id))) {
    cli::cli_alert_warning(
      "No Spanish CCAA codes found for {.str {clean_region}}. Return NULL."
    )
    return(NULL)
  }

  ccaa_id <- ccaa_id[!novalid]

  lev1 <- nchar(ccaa_id) == 3

  if (any(lev1)) {
    dfall <- mapSpain::esp_codelist

    nutslev1 <- dfall[dfall$nuts1.code %in% ccaa_id[lev1], ]$nuts2.code
    ccaa_id <- ccaa_id[lev1 == FALSE]
    ccaa_id <- unique(c(ccaa_id, nutslev1))
  }

  sort(ccaa_id[!is.na(ccaa_id)])
}
