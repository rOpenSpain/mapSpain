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
  is_text <- !grepl("^ES-|^ES[[:digit:]]", clean_region)

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

    suppressMessages(
      nuts_id[i] <- esp_dict_region_code(code, type, "nuts"),
      "cliMessage"
    )
  }
  if (all(is.na(nuts_id))) {
    cli::cli_alert_warning(
      "No Spanish NUTS codes found for {.str {clean_region}}."
    )
    return(NULL)
  }

  if (any(is.na(nuts_id))) {
    cli::cli_alert_warning(
      "No Spanish NUTS codes found for {.str {clean_region[is.na(nuts_id)]}}."
    )
  }

  sort(nuts_id[!is.na(nuts_id)])
}

#' Transform region to NUTS code for CCAA (NUTS 2)
#' @param region A vector of region names or codes (NUTS, ISO2, INE codauto).
#' @return A vector of NUTS codes for CCAA (level 2) or an error if no valid
#'   code found.
#'
#' @noRd
convert_to_nuts_ccaa <- function(region) {
  # Clean up
  clean_region <- unique(region)
  if (any(is.null(region), all(is.na(clean_region)))) {
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
      suppressMessages(
        code <- esp_dict_region_code(code, "codauto", "nuts"),
        "cliMessage"
      )
    }

    suppressMessages(res <- convert_to_nuts(code), "cliMessage")
    if (is.null(res)) {
      res <- NA
    }
    ccaa_id[i] <- res
  }

  if (all(is.na(ccaa_id))) {
    cli::cli_abort(
      "No Spanish CCAA codes found for {.str {clean_region}}."
    )
  }

  # Fix Ceuta and Melilla
  ccaa_id[grep("ES640", ccaa_id)] <- "ES64"
  ccaa_id[grep("ES630", ccaa_id)] <- "ES63"

  novalid <- is.na(ccaa_id) | nchar(ccaa_id) > 4

  if (all(novalid)) {
    cli::cli_abort(
      "No Spanish CCAA codes found for {.str {clean_region}}."
    )
  }

  if (any(novalid)) {
    cli::cli_alert_warning(
      paste0(
        "No Spanish CCAA codes found for ",
        "{.str {clean_region[novalid]}}."
      )
    )
  }

  ccaa_id <- ccaa_id[!novalid]

  lev1 <- nchar(ccaa_id) == 3

  if (any(lev1)) {
    dfall <- mapSpain::esp_codelist

    nutslev1 <- dfall[dfall$nuts1.code %in% ccaa_id[lev1], ]$nuts2.code
    ccaa_id <- ccaa_id[lev1 == FALSE]
    ccaa_id <- unique(c(ccaa_id, nutslev1))
  }

  end <- sort(ccaa_id[!is.na(ccaa_id)])
  end
}


#' Transform region to NUTS code for Provinces (NUTS 3 but not exactly)
#' @param region A vector of region names or codes (NUTS, ISO2, INE cpro).
#' @return A vector of NUTS codes for Provinces (level 3) or an error if no
#'   valid code found.
#'
#' @noRd
convert_to_nuts_prov <- function(region) {
  # Clean up
  clean_region <- unique(region)
  if (any(is.null(region), all(is.na(clean_region)))) {
    return(NULL)
  }
  clean_region <- region[!is.na(clean_region)]

  # Replace islands, that is where NUTS3 and provinces do not match
  clean_region[clean_region == "ES-GC"] <- "35"
  clean_region[clean_region == "ES-TF"] <- "38"
  clean_region[clean_region == "ES-PM"] <- "ES53"
  clean_region[clean_region == "ES-IB"] <- "ES53"
  clean_region[clean_region == "07"] <- "ES53"
  # Guess type of code for convert: recognize cpro, nuts, isos and free text
  is_cpro <- grepl("^[[:digit:]]", clean_region)
  is_iso <- grepl("^ES-", clean_region)
  is_nuts <- grepl("^ES[[:digit:]]", clean_region)
  is_text <- !grepl("^ES-|^ES[[:digit:]]|^[[:digit:]]", clean_region)

  code_type <- clean_region
  code_type[is_cpro] <- "cpro"
  code_type[is_iso] <- "iso2"
  code_type[is_nuts] <- "nuts"
  code_type[is_text] <- "text"

  # Made conversions
  n_codes <- seq_along(clean_region)

  # Store names in vector
  nuts_cpros <- clean_region

  # Convert text to cpro to check Canary Islands and Baleric Islands
  for (i in n_codes) {
    code <- nuts_cpros[i]
    type <- code_type[i]

    # Need this to convert Canarias to Provinces
    if (type == "text") {
      suppressMessages(
        name_es <- esp_dict_translate(code, "es"),
        "cliMessage"
      )

      if (is.na(name_es)) {
        nuts_cpros[i] <- NA
        next
      }
      if (name_es == "Las Palmas") {
        nuts_cpros[i] <- "35"
        next
      }
      if (name_es == "Santa Cruz de Tenerife") {
        nuts_cpros[i] <- "38"
        next
      }
      if (name_es == "Baleares") {
        nuts_cpros[i] <- "ES53"
        next
      }
    }
  }

  # Re-assess
  is_cpro <- grepl("^[[:digit:]]", nuts_cpros)
  is_iso <- grepl("^ES-", nuts_cpros)
  is_nuts <- grepl("^ES[[:digit:]]", nuts_cpros)
  is_text <- !grepl("^ES-|^ES[[:digit:]]|^[[:digit:]]", nuts_cpros)

  code_type <- nuts_cpros
  code_type[is_cpro] <- "cpro"
  code_type[is_iso] <- "iso2"
  code_type[is_nuts] <- "nuts"
  code_type[is_text] <- "text"

  # Prepare dict
  cpro_to_nuts <- get_prov_to_nuts_df()

  for (i in n_codes) {
    code <- nuts_cpros[i]
    type <- code_type[i]

    if (type == "cpro") {
      cpro_nuts <- countrycode::countrycode(
        code,
        origin = "cpro",
        destination = "nuts",
        custom_dict = cpro_to_nuts,
        nomatch = "NOMATCH"
      )
      nuts_cpros[i] <- cpro_nuts
    } else {
      # To NUTS
      suppressMessages(
        res <- convert_to_nuts(code),
        "cliMessage"
      )
      if (is.null(res)) {
        res <- NA
      }
      nuts_cpros[i] <- res
    }
  }

  if (all(is.na(nuts_cpros))) {
    cli::cli_abort(
      "No Spanish province codes found for {.str {clean_region}}."
    )
  }

  # Case of Islands, are not a province, shouldn't be here yet

  esp_codes <- mapSpain::esp_codelist
  not_provs <- esp_codes[
    !is.na(esp_codes$nuts3.code) & is.na(esp_codes$nuts.prov.code),
  ]$nuts3.code

  nuts_cpros[nuts_cpros %in% not_provs] <- "NOMATCH"
  nuts_cpros[is.na(nuts_cpros)] <- "NOMATCH"

  nomatch <- nuts_cpros == "NOMATCH"
  if (all(nomatch)) {
    cli::cli_abort(
      "No Spanish province codes found for {.str {clean_region}}."
    )
  }

  if (any(nomatch)) {
    cli::cli_alert_warning(
      paste0(
        "No Spanish province codes found for {.str {clean_region[nomatch]}}."
      )
    )
  }

  nuts_cpros[nomatch] <- NA

  nuts_cpros <- nuts_cpros[!is.na(nuts_cpros)]

  # Fix GC and TF
  if ("ES-TF" %in% nuts_cpros) {
    nuts <- mapSpain::esp_codelist
    vec_codes <- nuts[nuts$iso2.prov.code == "ES-TF", ]$nuts3.code
    nuts_cpros <- c(nuts_cpros[!nuts_cpros == "ES-TF"], vec_codes)
  }
  if ("ES-GC" %in% nuts_cpros) {
    nuts <- mapSpain::esp_codelist
    vec_codes <- nuts[nuts$iso2.prov.code == "ES-GC", ]$nuts3.code
    nuts_cpros <- c(nuts_cpros[!nuts_cpros == "ES-GC"], vec_codes)
  }

  nuts_id <- sort(unique(nuts_cpros))

  lev1 <- nchar(nuts_id) == 3

  if (any(lev1)) {
    dfall <- mapSpain::esp_codelist

    nutslev1 <- dfall[dfall$nuts1.code %in% nuts_id[lev1], ]$nuts3.code
    nuts_id <- nuts_id[lev1 == FALSE]
    nuts_id <- sort(unique(c(nuts_id, nutslev1)))
  }

  lev2 <- nchar(nuts_id) == 4

  if (any(lev2)) {
    dfall <- mapSpain::esp_codelist

    nutslev2 <- dfall[dfall$nuts2.code %in% nuts_id[lev2], ]$nuts3.code
    nuts_id <- nuts_id[lev2 == FALSE]
    nuts_id <- sort(unique(c(nuts_id, nutslev2)))
  }

  nuts_id
}


#' Helper function to get the equivalence between cpro and NUTS (any level)
#'
#' @noRd
get_prov_to_nuts_df <- function() {
  df <- mapSpain::esp_codelist
  l3 <- unique(df[, c("iso2.prov.code", "cpro", "nuts.prov.code")])
  names(l3) <- c("iso2", "cpro", "nuts")
  rownames(l3) <- NULL
  l3 <- l3[order(l3$cpro, l3$nuts), c("cpro", "nuts", "iso2")]
  l3$nuts <- ifelse(is.na(l3$nuts), l3$iso2, l3$nuts)
  l3 <- l3[!is.na(l3$nuts), ]

  l3
}
