#' Transform region to NUTS code
#'
#' @param region A name or code of a Spanish region
#'
#' @noRd
esp_hlp_all2nuts <- function(region) {
  region <- unique(region[!is.na(region)])

  iso <- grep("^ES-", region)
  nuts <- grep("^ES[[:digit:]]", region)
  collectcode <- c(iso, nuts)
  key <- seq_len(length(region))

  if (length(collectcode) > 0) {
    key <- key[-collectcode]
  }
  nuts_id <- region
  if (length(iso) > 0) {
    isoname <- esp_dict_region_code(region[iso], "iso2", "nuts")
    nuts_id[iso] <- isoname
  }

  if (length(nuts) > 0) {
    # # Validate
    nutstoval <- nuts_id[nuts]
    out <- nutstoval

    # Validate nuts
    dfnuts <- sf::st_drop_geometry(esp_get_nuts())
    validnuts <- dfnuts$NUTS_ID
    check <- nutstoval %in% validnuts

    out[check == FALSE] <- NA

    nuts_id[nuts] <- out

    if (any(is.na(out))) {
      warning(
        paste0(nutstoval[is.na(out)], collapse = ", "),
        " are not valid nuts codes"
      )
    }
  }

  if (length(key) > 0) {
    keyname <- esp_dict_region_code(region[key], "text", "nuts")
    nuts_id[key] <- keyname
  }


  return(nuts_id)
}


#' Transform region to CCAA
#'
#' @inheritParams esp_hlp_all2nuts
#'
#' @noRd
esp_hlp_all2ccaa <- function(region) {
  dfall <- mapSpain::esp_codelist

  region <- unique(region)

  nuts_init <- region

  codauto <- grep("^[[:digit:]]", region)

  key <- seq_len(length(region))

  if (length(codauto) > 0) {
    key <- key[-codauto]
  }

  if (length(codauto > 0)) {
    codautoname <-
      esp_dict_region_code(region[codauto], "codauto", "nuts")
    nuts_init[codauto] <- codautoname
  }

  if (length(key) > 0) {
    keyname <-
      esp_hlp_all2nuts(region[key])
    nuts_init[key] <- keyname
  }

  # Fix Ceuta and Melilla
  nuts_init[grep("ES640", nuts_init)] <- "ES64"
  nuts_init[grep("ES630", nuts_init)] <- "ES63"

  novalid <- nchar(nuts_init) > 4

  if (any(novalid)) {
    warning(
      paste0(region[novalid], collapse = ", "),
      " does not return a Autonomous Community"
    )
  }

  # Get NUTS2 from NUTS1
  lev1 <- nchar(nuts_init) == 3


  if (any(lev1)) {
    nutslev1 <-
      dfall[dfall$nuts1.code %in% nuts_init[lev1], ]$nuts2.code
    nuts_init <- nuts_init[lev1 == FALSE]
    nuts_init <- unique(c(nuts_init, nutslev1))
  }

  return(nuts_init)
}

#' Transform region to province
#'
#' @inheritParams esp_hlp_all2nuts
#'
#' @noRd
esp_hlp_all2prov <- function(region) {
  cod2cod <- code2code
  cod2cod <- cod2cod[!is.na(cod2cod$cpro), ]

  region <- unique(region)
  # Replace

  region[region == "ES-GC"] <- "35"
  region[region == "ES-TF"] <- "38"
  region[region == "ES-PM"] <- "07"

  # Separate between types of codes
  cpro <- grep("^[[:digit:]]", region)
  nuts <- grep("^ES[[:digit:]]", region)
  iso <- grep("^ES-", region)
  collectcode <- c(cpro, nuts, iso)
  key <- seq_len(length(region))

  if (length(collectcode) > 0) {
    key <- key[-collectcode]
  }
  if (length(key) > 0) {
    # Get names
    key2names <- esp_dict_translate(region[key], "es")

    # See if Canary Islands are here
    ngc <- key[key2names == "Las Palmas"]
    ntf <- key[key2names == "Santa Cruz de Tenerife"]

    if (length(ngc) > 0) {
      region[ngc] <- "35"
    }

    if (length(ntf) > 0) {
      region[ntf] <- "38"
    }
  }

  # Reassess after modification
  cpro <- grep("^[[:digit:]]", region)
  nuts <- grep("^ES[[:digit:]]", region)
  iso <- grep("^ES-", region)
  collectcode <- c(cpro, nuts, iso)
  key <- seq_len(length(region))

  if (length(collectcode) > 0) {
    key <- key[-collectcode]
  }

  nuts_init <- region

  # Get iso
  if (length(cpro > 0)) {
    cproname <- countrycode::countrycode(
      region[cpro],
      origin = "cpro",
      destination = "cpro",
      custom_dict = cod2cod,
      nomatch = "NOMATCH"
    )
    nuts_init[cpro] <- cproname
  }


  if (length(iso) > 0) {
    isoname <- esp_dict_region_code(region[iso], "iso2", "nuts")
    nuts_init[iso] <- isoname
  }

  # Join
  newkey <- c(nuts, key)

  if (length(newkey) > 0) {
    newkeyname <- esp_hlp_all2nuts(region[newkey])
    nuts_init[newkey] <- newkeyname
  }


  # So far all are cpro or NUTS
  arenuts <- grep("^ES[[:digit:]]", nuts_init)

  dfall <- mapSpain::esp_codelist


  if (length(arenuts) > 0) {
    nutsend <- nuts_init[grep("^ES[[:digit:]]", nuts_init)]
    cproend <- nuts_init[-grep("^ES[[:digit:]]", nuts_init)]

    originalnames <- region[grep("^ES[[:digit:]]", nuts_init)]

    # Modify NUTS

    noprovs <-
      dfall[c(
        grep("ES53", dfall$nuts3.code),
        grep("ES7", dfall$nuts3.code)
      ), ]$nuts3.code

    novalid <- nutsend %in% noprovs


    if (any(novalid)) {
      warning(
        paste0(originalnames[novalid], collapse = ", "),
        " does not return a province"
      )
    }

    nutsend <- nutsend[!novalid]

    # Get NUTS3 from NUTS1
    lev1 <- nchar(nutsend) == 3


    if (any(lev1)) {
      nutslev1 <-
        dfall[dfall$nuts1.code %in% nutsend[lev1], ]$nuts3.code
      nutsend <- nutsend[lev1 == FALSE]
      nutsend <- unique(c(nutsend, nutslev1))
    }

    # Get NUTS3 from NUTS2
    lev2 <- nchar(nutsend) == 4


    if (any(lev2)) {
      nutslev2 <-
        dfall[dfall$nuts2.code %in% nutsend[lev2], ]$nuts3.code
      nutsend <- nutsend[lev2 == FALSE]
      nutsend <- unique(c(nutsend, nutslev2))
    }

    final <- unique(c(nutsend, cproend))
  } else {
    final <- nuts_init
  }

  # Pass now cpro to NUTS
  arecpro <- grep("^[[:digit:]]", final)

  if (length(arecpro) > 0) {
    cpro <- final[arecpro]

    nutscpro <- dfall[dfall$cpro %in% cpro, ]$nuts3.code

    final <- unique(c(final[-arecpro], nutscpro))
  }
  return(final)
}
