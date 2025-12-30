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
