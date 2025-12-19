#' Generates a master table with all the combinations of codes
#'
#' @noRd
get_master_codes <- function() {
  # First level - NUTS1
  df <- mapSpain::esp_codelist
  nt1 <- unique(df$nuts1.code)

  # Second level - NUTS2 - CCAA
  nt2 <- unique(df[, c("nuts2.code", "iso2.ccaa.code", "codauto")])

  # Third level - Prov and NUTS

  l3 <- unique(df[, c("iso2.prov.code", "cpro", "nuts.prov.code")])
  l3[l3$iso2.prov.code == "ES-PM", ]$nuts.prov.code <- NA

  # Additional level - NUTS3
  nt3 <- unique(df$nuts3.code)

  # Compose a full data frame
  base_df <- tibble::tibble(nuts = nt1)

  colnames(nt2) <- c("nuts", "iso2", "codauto")

  base_df <- unique(merge(base_df, nt2, all.x = TRUE, all.y = TRUE))

  colnames(l3) <- c("iso2", "cpro", "nuts")
  base_df <- unique(merge(base_df, l3, all.x = TRUE, all.y = TRUE))

  # Add missing NUTS3
  missnuts <- tibble::tibble(
    nuts = nt3[!nt3 %in% base_df$nuts],
    iso2 = NA,
    codauto = NA,
    cpro = NA
  )

  dict_codes_df <- rbind(base_df, missnuts)

  dict_codes_df$iso2 == "ES-GC"

  # Fake NUTS for Canary Islands
  dict_codes_df[
    dict_codes_df$iso2 == "ES-GC" &
      !is.na(dict_codes_df$iso2),
  ]$nuts <- "XXXXX"

  dict_codes_df[
    dict_codes_df$iso2 == "ES-TF" &
      !is.na(dict_codes_df$iso2),
  ]$nuts <- "YYYYY"

  # Remove dups on Ceuta y Melilla
  dict_codes_df[
    dict_codes_df$nuts == "ES64" & !is.na(dict_codes_df$nuts),
    "iso2"
  ] <- NA

  dict_codes_df[
    dict_codes_df$nuts == "ES63" & !is.na(dict_codes_df$nuts),
    "iso2"
  ] <- NA

  dict_codes_df <- dict_codes_df[
    order(dict_codes_df$codauto, dict_codes_df$cpro),
  ]
  dict_codes_df
}

#' Generates a dictionary for NUTS with all names
#' @noRd
get_master_nuts_nm <- function() {
  # Create base codes
  names_full_tb <- get_master_names()
  basecod <- tibble::tibble(
    key = unique(names_full_tb$key)
  )

  df_all <- mapSpain::esp_codelist
  # Create code dict nuts
  dict_nuts1mod <- unique(df_all[, c("nuts1.shortname.es", "nuts1.code")])
  names(dict_nuts1mod) <- c("key", "nuts")

  dict_nuts2mod <- unique(df_all[, c("ccaa.shortname.es", "nuts2.code")])
  names(dict_nuts2mod) <- c("key", "nuts")

  dict_nuts3mod <- unique(df_all[, c("nuts3.shortname.es", "nuts3.code")])
  names(dict_nuts3mod) <- c("key", "nuts")

  dict_nuts <- dict_nuts1mod
  dict_nuts <- rbind(
    dict_nuts,
    dict_nuts2mod[!(dict_nuts2mod$key %in% dict_nuts$key), ]
  )
  dict_nuts <- rbind(
    dict_nuts,
    dict_nuts3mod[!(dict_nuts3mod$key %in% dict_nuts$key), ]
  )
  dict_nuts <- unique(dict_nuts)

  basecod <- merge(basecod, dict_nuts, all.x = TRUE)

  # Fake NUTS for Canary Islands
  basecod[basecod$key == "Las Palmas", ]$nuts <- "XXXXX"
  basecod[basecod$key == "Santa Cruz de Tenerife", ]$nuts <- "YYYYY"
  tibble::as_tibble(basecod)
}

get_master_names <- function() {
  df_all <- mapSpain::esp_codelist

  dict_nuts1 <- df_all[, grepl("^nuts1", names(df_all))]
  dict_nuts1$key <- dict_nuts1$nuts1.shortname.es
  dict_nuts1 <- unique(dict_nuts1)

  dict_ccaa <- df_all[, grepl("ccaa|nuts2|codauto", names(df_all))]
  dict_ccaa$key <- dict_ccaa$ccaa.shortname.es
  dict_ccaa <- unique(dict_ccaa)

  dict_prov <- df_all[, grepl("prov|cpro", names(df_all))]
  dict_prov$key <- dict_prov$prov.shortname.es
  dict_prov <- unique(dict_prov)

  dict_nuts3 <- df_all[, grepl("nuts3|cpro", names(df_all))]
  dict_nuts3$key <- dict_nuts3$nuts3.shortname.es
  dict_nuts3 <- unique(dict_nuts3)

  melt_df <- function(df) {
    df <- as.data.frame(df)

    df$id <- df$key
    pp <- reshape(
      df,
      direction = "long",
      varying = setdiff(names(df), "id"),
      idvar = "id",
      v.names = "value",
      timevar = "variable"
    )
    rownames(pp) <- NULL
    get_names <- setdiff(names(df), "id")
    pp$variable <- get_names[pp$variable]
    pp <- tibble::as_tibble(as.matrix(pp))
    names(pp) <- c("key", "variable", "value")
    pp <- pp[stats::complete.cases(pp), ]
    unique(pp)
  }

  # Create full translator

  dict_nuts1_all <- melt_df(dict_nuts1)
  dict_ccaa_all <- melt_df(dict_ccaa)
  dict_prov_all <- melt_df(dict_prov)
  dict_nuts3_all <- melt_df(dict_nuts3)

  names_all <- unique(rbind(
    dict_ccaa_all,
    dict_nuts1_all,
    dict_prov_all,
    dict_nuts3_all
  ))

  # Add extra used names
  # Ciudad de Ceuta
  ceuta <- names_all[grepl("^ceuta", names_all$value, ignore.case = TRUE), ]
  ceuta$variable <- paste0("alt.", ceuta$variable)
  ceuta$value <- paste0("Ciudad de ", ceuta$value)

  # Ciudad de Melilla
  melilla <- names_all[grepl("^melilla", names_all$value, ignore.case = TRUE), ]
  melilla$variable <- paste0("alt.", melilla$variable)
  melilla$value <- paste0("Ciudad de ", melilla$value)

  # Santa Cruz de Tenerife
  tfe <- names_all[grepl("^santa cruz", names_all$value, ignore.case = TRUE), ]
  tfe$variable <- paste0("alt.", tfe$variable)
  tfe$value <- gsub("Santa", "Sta.", tfe$value)

  names_all <- unique(rbind(names_all, ceuta, melilla, tfe))

  # Add versions without accents, etc.
  names_alt <- names_all
  names_alt$value <- iconv(
    names_alt$value,
    from = "UTF-8",
    to = "ASCII//TRANSLIT"
  )
  names_alt$variable <- paste0("clean.", names_alt$variable)
  names_alt <- unique(names_alt)
  names_all <- unique(rbind(names_all, names_alt))

  # Version UPCASE and lowercase
  names_up <- names_all
  names_up$value <- toupper(names_up$value)
  names_up$variable <- paste0("upcase.", names_up$variable)

  names_lo <- names_all
  names_lo$value <- tolower(names_lo$value)
  names_lo$variable <- paste0("locase.", names_lo$variable)
  names_all <- unique(rbind(names_all, names_up, names_lo))
  names_all
}
