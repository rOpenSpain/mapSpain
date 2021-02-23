#' Convert and translate Subdivision Names
#'
#' Converts long subdivision names into different coding schemes and languages.
#'
#' @family esp_dict
#'
#' @rdname esp_dict
#'
#' @return `esp_dict_region_code` returns a vector of characters.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @export
#'
#'
#' @param sourcevar Vector which contains the subdivision names to be converted.
#'
#' @param origin,destination One of "text", "nuts", "iso2",
#'   "codauto" and "cpro".
#'
#' @details
#' If no match is found for any value, the function displays a warning and
#' returns `NA` for those values.
#'
#' Note that mixing names of different administrative levels (e.g. "Catalonia"
#' and "Barcelona") may return empty values, depending on the `destination`
#' values.
#'
#' @examples
#' vals <- c("Errioxa", "Coruna", "Gerona", "Madrid")
#'
#' esp_dict_region_code(vals)
#' esp_dict_region_code(vals, destination = "nuts")
#' esp_dict_region_code(vals, destination = "cpro")
#' esp_dict_region_code(vals, destination = "iso2")
#'
#' # From ISO2 to another codes
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
#' \dontrun{
#'
#' # Warning
#'
#' esp_dict_region_code(valsmix, destination = "codauto")
#' esp_dict_region_code(valsmix, destination = "iso2")
#' }
#'
esp_dict_region_code <- function(sourcevar,
                                 origin = "text",
                                 destination = "text") {
  initsourcevar <- sourcevar

  validvars <- c("text", "nuts", "iso2", "codauto", "cpro")

  if (!(origin %in% validvars)) {
    stop(
      "origin should be ",
      paste0("'", validvars, "'", collapse = ", ")
    )
  }

  if (!(destination %in% validvars)) {
    stop(
      "destination should be ",
      paste0("'", validvars, "'", collapse = ", ")
    )
  }

  if (origin == destination & origin == "text") {
    message("No conversion - origin equal to destination")
    return(initsourcevar)
  }

  # Create dict
  dict <- names_full

  names_dict <-
    unique(names_full[
      grep("name", dict$variable),
      c("key", "value")
    ])

  # If text convert to nuts

  if (origin == "text") {
    sourcevar <- countrycode::countrycode(
      sourcevar,
      origin = "value",
      destination = "key",
      custom_dict = names_dict,
      nomatch = "NOMATCH"
    )

    # Translate to nuts
    sourcevar <- countrycode::countrycode(
      sourcevar,
      origin = "key",
      destination = "nuts",
      custom_dict = names2nuts,
      nomatch = "NOMATCH"
    )

    # Replace NOMATCH
    sourcevar[sourcevar == "NOMATCH"] <-
      initsourcevar[sourcevar == "NOMATCH"]
    origin <- "nuts"

    # By name, perform some replacements
    # Madrid - CCAA
    sourcevar[sourcevar == "ES3"] <- "ES30"

    # Canarias - CCAA
    sourcevar[sourcevar == "ES7"] <- "ES70"

    if (destination == "iso2") {
      # Melilla - Prov
      sourcevar[sourcevar == "ES64"] <- "ES640"

      # Ceuta - Prov
      sourcevar[sourcevar == "ES63"] <- "ES630"
    }

    if (destination == "cpro") {
      nchar <- nchar(sourcevar)
      sourcevar[nchar == 4] <- paste0(sourcevar[nchar == 4], "0")
    }
  }



  # Destination
  if (destination == "text") {
    sourcevar <-
      countrycode::countrycode(sourcevar,
        origin,
        "nuts",
        custom_dict = code2code,
        nomatch = "NOMATCH"
      )

    dict_nutsall <- sf::st_drop_geometry(mapSpain::esp_nuts.sf)

    out <-
      countrycode::countrycode(sourcevar,
        "NUTS_ID",
        "NUTS_NAME",
        custom_dict = dict_nutsall,
        nomatch = "NOMATCH"
      )
  } else {
    # Solve problems
    if (origin == "nuts") {
      # Melilla - Prov
      sourcevar[sourcevar == "ES64"] <- "ES640"

      # Ceuta - Prov
      sourcevar[sourcevar == "ES63"] <- "ES630"
    }

    if (destination == "codauto") {
      # Melilla - Prov
      sourcevar[sourcevar == "ES640"] <- "ES64"

      # Ceuta - Prov
      sourcevar[sourcevar == "ES630"] <- "ES63"
    }



    out <-
      countrycode::countrycode(sourcevar,
        origin,
        destination,
        custom_dict = code2code,
        nomatch = "NOMATCH"
      )

    # Baleares
    if (destination == "cpro") {
      out[sourcevar == "ES530"] <- "07"
    }
    # Ceuta
    if (origin == "iso2" & destination == "codauto") {
      out[sourcevar == "ES-CE"] <- "18"
      out[sourcevar == "ES-ML"] <- "19"
    }
  }
  out[out %in% c("XXXXX", "YYYYY")] <- "NOMATCH"

  # Sanitize
  if (length(out[!(out == "NOMATCH")]) != length(sourcevar)) {
    warning(
      "No match on ",
      destination,
      " found for ",
      paste0(initsourcevar[out == "NOMATCH"], collapse = ", ")
    )
  }
  out[out == "NOMATCH"] <- NA


  return(out)
}

#' @family esp_dict
#'
#' @rdname esp_dict
#' @return `
#' esp_dict_translate` returns a character vector or a named list with each
#' of the possible names of each `sourcevar` on the required language `lang`.
#'
#' @export
#'
#' @param lang Language of translation. Available languages are:
#'   * "es": Spanish
#'   * "en": English
#'   * "ca": Catalan
#'   * "ga": Galician
#'   * "eu": Basque
#'
#' @param all Logical. Should the function return all names or not?
#'   On `FALSE` it returns a character vector. See Value
#'
#' @examples
#'
#' vals <- c(
#'   "La Rioja", "Sevilla", "Madrid",
#'   "Jaen", "Orense", "Baleares"
#' )
#' esp_dict_translate(vals)
#' esp_dict_translate(vals, lang = "es")
#' esp_dict_translate(vals, lang = "ca")
#' esp_dict_translate(vals, lang = "eu")
#' esp_dict_translate(vals, lang = "ga")
#'
#' esp_dict_translate(vals, lang = "ga", all = TRUE)
esp_dict_translate <-
  function(sourcevar,
           lang = "en",
           all = FALSE) {
    avlang <- c("es", "en", "ca", "ga", "eu")
    if (!(lang %in% avlang)) {
      stop("lang sould be one of ", paste0("'", avlang,
        "'",
        collapse = ", "
      ))
    }

    # Create dict
    dict <- names_full

    names_dict <-
      unique(names_full[grep("name", dict$variable), c("key", "value")])

    tokeys <- countrycode::countrycode(
      sourcevar,
      origin = "value",
      destination = "key",
      custom_dict = names_dict,
      nomatch = "NOMATCH"
    )

    # Create lang dict
    dict_tolang <-
      unique(dict[grep(
        paste0("name.", lang),
        dict$variable
      ), ])

    # Order using short

    shrt <- grep("short", dict_tolang$variable)

    dict_tolang[shrt, ]$variable <-
      paste0("aa", dict_tolang[shrt, ]$variable)

    dict_tolang <-
      unique(dict_tolang[order(dict_tolang$variable), c("key", "value")])


    namestrans <-
      lapply(seq(1, length(tokeys)), function(x) {
        dict_tolang[dict_tolang$key == tokeys[x], "value"]
      })

    namestrans[tokeys == "NOMATCH"] <- NA

    if (isTRUE(all)) {
      names(namestrans) <- sourcevar
    }

    if (isFALSE(all)) {
      namestrans <-
        unlist(lapply(namestrans, `[[`, 1))
    }

    if (any(tokeys == "NOMATCH")) {
      warning(
        "No match found for ",
        paste0(sourcevar[tokeys == "NOMATCH"], collapse = ", ")
      )
    }

    return(namestrans)
  }
