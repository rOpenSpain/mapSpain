#' Convert and translate Spanish subdivision names and codes
#'
#' @description
#' Convert Spanish subdivision names or identifiers between different coding
#' schemes such as NUTS, ISO2 and province codes, or obtain human-readable
#' names.
#'
#' @details
#' The function uses internal dictionaries together with \CRANpkg{countrycode}
#' to map between schemes. When `origin == destination == "text"` the input is
#' returned unchanged. Mixing names from different administrative levels
#' (for example Autonomous Community and province) may produce
#' `NA` values for some entries.
#'
#' @param sourcevar Character string. Vector which contains the codes or names
#'   to be converted.
#' @param origin,destination Character string. Coding scheme of origin and
#'   destination. One of `"text"`, `"nuts"`, `"iso2"`, `"codauto"` or `"cpro"`.
#'
#' @return
#'
#' `esp_dict_region_code()` returns a character vector with converted
#' subdivision identifiers or names. If a value cannot be matched, the
#' corresponding element will be `NA` and a warning is emitted via
#' [cli::cli_alert_warning()].
#'
#' @family dictionary
#' @encoding UTF-8
#' @rdname esp_dict
#' @name esp_dict_region_code
#' @export
#'
#' @examples
#' vals <- c("Errioxa", "Coruna", "Gerona", "Madrid")
#'
#' esp_dict_region_code(vals)
#' esp_dict_region_code(vals, destination = "nuts")
#' esp_dict_region_code(vals, destination = "cpro")
#' esp_dict_region_code(vals, destination = "iso2")
#'
#' # From ISO2 to other codes
#'
#' iso2vals <- c("ES-M", "ES-S", "ES-SG")
#' esp_dict_region_code(iso2vals, origin = "iso2")
#' esp_dict_region_code(iso2vals,
#'   origin = "iso2",
#'   destination = "nuts"
#' )
#' esp_dict_region_code(iso2vals,
#'   origin = "iso2",
#'   destination = "cpro"
#' )
#'
#' # Mixing levels
#' valsmix <- c("Centro", "Andalucia", "Seville", "Menorca")
#' esp_dict_region_code(valsmix, destination = "nuts")
#'
#' esp_dict_region_code(valsmix, destination = "codauto")
#' esp_dict_region_code(valsmix, destination = "iso2")
#'
esp_dict_region_code <- function(
  sourcevar,
  origin = "text",
  destination = "text"
) {
  validvars <- c("text", "nuts", "iso2", "codauto", "cpro")
  origin <- match_arg_pretty(origin, validvars)
  destination <- match_arg_pretty(destination, validvars)

  sourcevar <- normalize_region_sourcevar(sourcevar)
  initsourcevar <- sourcevar

  if (origin == destination && origin == "text") {
    make_msg(
      "info",
      TRUE,
      "No conversion. {.arg origin}",
      "equal to {.arg destination}",
      paste0("({.str ", origin, "})")
    )
    return(initsourcevar)
  }

  if (origin == "text") {
    sourcevar <- text_to_nuts_sourcevar(sourcevar, initsourcevar, destination)
    origin <- "nuts"
  }

  if (destination == "text") {
    out <- region_code_to_text(sourcevar, origin)
  } else {
    out <- region_code_to_code(sourcevar, origin, destination)
  }

  sanitize_region_code_output(out, sourcevar, initsourcevar, destination)
}

normalize_region_sourcevar <- function(sourcevar) {
  sourcevar <- gsub(
    "Ciudad de ceuta",
    "Ceuta",
    sourcevar,
    ignore.case = TRUE
  )
  sourcevar <- gsub(
    "Ciudad de melilla",
    "Melilla",
    sourcevar,
    ignore.case = TRUE
  )
  sourcevar <- gsub("sta. cruz", "Santa Cruz", sourcevar, ignore.case = TRUE)
  gsub("sta cruz", "Santa Cruz", sourcevar, ignore.case = TRUE)
}

get_region_names_dict <- function() {
  dict <- names_full
  unique(dict[
    grep("name", dict$variable, fixed = TRUE),
    c("key", "value")
  ])
}

text_to_nuts_sourcevar <- function(sourcevar, initsourcevar, destination) {
  sourcevar <- countrycode::countrycode(
    tolower(sourcevar),
    origin = "value",
    destination = "key",
    custom_dict = get_region_names_dict(),
    nomatch = "NOMATCH"
  )

  sourcevar <- countrycode::countrycode(
    sourcevar,
    origin = "key",
    destination = "nuts",
    custom_dict = get_master_nuts_nm(),
    nomatch = "NOMATCH"
  )

  sourcevar[sourcevar == "NOMATCH"] <- initsourcevar[sourcevar == "NOMATCH"]

  sourcevar[sourcevar == "ES3"] <- "ES30"
  sourcevar[sourcevar == "ES7"] <- "ES70"

  if (destination == "iso2") {
    sourcevar[sourcevar == "ES64"] <- "ES640"
    sourcevar[sourcevar == "ES63"] <- "ES630"
  }

  if (destination == "cpro") {
    nchar <- nchar(sourcevar)
    sourcevar[nchar == 4] <- paste0(sourcevar[nchar == 4], "0")
  }

  sourcevar
}

region_code_to_text <- function(sourcevar, origin) {
  sourcevar <- countrycode::countrycode(
    sourcevar,
    origin,
    "nuts",
    custom_dict = get_master_codes(),
    nomatch = "NOMATCH"
  )

  dict_nutsall <- sf::st_drop_geometry(mapSpain::esp_nuts_2024)

  countrycode::countrycode(
    sourcevar,
    "NUTS_ID",
    "NUTS_NAME",
    custom_dict = dict_nutsall,
    nomatch = "NOMATCH"
  )
}

region_code_to_code <- function(sourcevar, origin, destination) {
  if (origin == "nuts") {
    sourcevar[sourcevar == "ES64"] <- "ES640"
    sourcevar[sourcevar == "ES63"] <- "ES630"
  }

  if (destination == "codauto") {
    sourcevar[sourcevar == "ES640"] <- "ES64"
    sourcevar[sourcevar == "ES630"] <- "ES63"
  }

  out <- countrycode::countrycode(
    sourcevar,
    origin,
    destination,
    custom_dict = get_master_codes(),
    nomatch = "NOMATCH"
  )

  if (destination == "cpro") {
    out[sourcevar == "ES530"] <- "07"
  }
  if (origin == "iso2" && destination == "codauto") {
    out[sourcevar == "ES-CE"] <- "18"
    out[sourcevar == "ES-ML"] <- "19"
  }

  out
}

sanitize_region_code_output <- function(
  out,
  sourcevar,
  initsourcevar,
  destination
) {
  out[out %in% c("XXXXX", "YYYYY")] <- "NOMATCH"

  if (length(out[out != "NOMATCH"]) != length(sourcevar)) {
    warn_no_match(initsourcevar[out == "NOMATCH"], destination)
  }
  out[out == "NOMATCH"] <- NA

  out
}

#'
#' @param lang Character string. Target language code, available values:
#'   - `"es"`: Spanish.
#'   - `"en"`: English.
#'   - `"ca"`: Catalan.
#'   - `"ga"`: Galician.
#'   - `"eu"`: Basque.
#'
#' @param all Logical. If `TRUE` the function returns all possible translations
#'   for each input as a named list. When `FALSE` (default) a single preferred
#'   translation per input is returned as a character vector.
#'
#' @return
#'
#' `esp_dict_translate()` translates a vector of names from one language to
#' another.
#'   - If `all = FALSE`, a character vector with the translated name for each
#'     element of `sourcevar`.
#'   - If `all = TRUE`, a named `list` is returned where each element contains
#'     all available translations for the corresponding input value.
#'
#' @rdname esp_dict
#' @name esp_dict_translate
#'
#' @export
#'
#' @examples
#' vals <- c("La Rioja", "Sevilla", "Madrid", "Jaen", "Orense", "Baleares")
#'
#' esp_dict_translate(vals)
#' esp_dict_translate(vals, lang = "es")
#' esp_dict_translate(vals, lang = "ca")
#' esp_dict_translate(vals, lang = "eu")
#' esp_dict_translate(vals, lang = "ga")
#'
#' esp_dict_translate(vals, lang = "ga", all = TRUE)
esp_dict_translate <- function(sourcevar, lang = "en", all = FALSE) {
  avlang <- c("es", "en", "ca", "ga", "eu")
  lang <- match_arg_pretty(lang, avlang)

  dict <- prepare_translation_dict()
  tokeys <- translate_source_to_keys(sourcevar, dict)

  if (any(tokeys == "NOMATCH")) {
    warn_no_match(sourcevar[tokeys == "NOMATCH"])
  }

  dict_tolang <- translation_lang_dict(dict, lang)
  namestrans <- translate_keys_to_lang(tokeys, dict_tolang, all)

  format_translation_output(namestrans, sourcevar, all)
}

prepare_translation_dict <- function() {
  dict <- names_full
  dict$variable <- gsub("prov", "a_prov", dict$variable, fixed = TRUE)
  dict$variable <- gsub("ccaa", "b_ccaa", dict$variable, fixed = TRUE)
  dict$variable <- gsub("nuts", "c_nuts", dict$variable, fixed = TRUE)
  dict
}

translate_source_to_keys <- function(sourcevar, dict) {
  names_dict <- unique(dict[
    grep("name", dict$variable, fixed = TRUE),
    c("key", "value")
  ])

  countrycode::countrycode(
    tolower(sourcevar),
    origin = "value",
    destination = "key",
    custom_dict = names_dict,
    nomatch = "NOMATCH"
  )
}

translation_lang_dict <- function(dict, lang) {
  dict_tolang <- unique(dict[grep(paste0("name.", lang), dict$variable), ])
  shrt <- grep("short", dict_tolang$variable, fixed = TRUE)
  dict_tolang[shrt, ]$variable <- paste0("aa", dict_tolang[shrt, ]$variable)

  unique(dict_tolang[
    order(dict_tolang$variable),
    c("key", "value")
  ])
}

translate_keys_to_lang <- function(tokeys, dict_tolang, all) {
  lapply(seq_along(tokeys), function(x) {
    if (tokeys[x] == "NOMATCH") {
      return(NA)
    }

    all_trans <- dict_tolang[dict_tolang$key == tokeys[x], "value"]
    all_trans <- unlist(all_trans)
    if (isFALSE(all)) {
      all_trans <- all_trans[1]
    }
    unname(all_trans)
  })
}

format_translation_output <- function(namestrans, sourcevar, all) {
  if (all) {
    names(namestrans) <- sourcevar
    return(namestrans)
  }

  unlist(namestrans)
}
