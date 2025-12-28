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
  names_full_tb <- names_full
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
