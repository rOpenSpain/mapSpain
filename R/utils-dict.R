#' Generates a master table with all the combinations of codes
#'
#' @noRd
get_master_codes <- function() {
  # First level - NUTS1
  df <- mapSpain::esp_codelist
  nt1 <- unique(df$nuts1.code)

  # Second level: NUTS2 and Autonomous Communities.
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

  # Add synthetic NUTS codes for the Canary Islands.
  dict_codes_df[
    dict_codes_df$iso2 == "ES-GC" & !is.na(dict_codes_df$iso2),
  ]$nuts <- "XXXXX"

  dict_codes_df[
    dict_codes_df$iso2 == "ES-TF" & !is.na(dict_codes_df$iso2),
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
  basecod <- tibble::tibble(key = unique(names_full_tb$key))

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

  # Add synthetic NUTS codes for the Canary Islands.
  basecod[basecod$key == "Las Palmas", ]$nuts <- "XXXXX"
  basecod[basecod$key == "Santa Cruz de Tenerife", ]$nuts <- "YYYYY"
  tibble::as_tibble(basecod)
}

nuts_to_cpro <- function(nuts_id) {
  df <- mapSpain::esp_codelist
  df <- unique(df[, c("nuts3.code", "cpro")])
  unique(df[df$nuts3.code %in% nuts_id, ]$cpro)
}

nuts_to_codauto <- function(nuts_id) {
  df <- mapSpain::esp_codelist
  df <- unique(df[, c("nuts2.code", "codauto")])
  unique(df[df$nuts2.code %in% nuts_id, ]$codauto)
}

get_ccaa_codes_df <- function() {
  getnames <- c(
    "codauto",
    "iso2.ccaa.code",
    "nuts1.code",
    "nuts2.code",
    "ine.ccaa.name",
    "iso2.ccaa.name.es",
    "iso2.ccaa.name.ca",
    "iso2.ccaa.name.gl",
    "iso2.ccaa.name.eu",
    "nuts2.name",
    "cldr.ccaa.name.en",
    "cldr.ccaa.name.es",
    "cldr.ccaa.name.ca",
    "cldr.ccaa.name.ga",
    "cldr.ccaa.name.eu",
    "ccaa.shortname.en",
    "ccaa.shortname.es",
    "ccaa.shortname.ca",
    "ccaa.shortname.ga",
    "ccaa.shortname.eu"
  )
  df_ccaa <- mapSpain::esp_codelist
  df_ccaa <- df_ccaa[, getnames]
  df_end <- unique(df_ccaa)
  df_end <- df_end[order(df_end$codauto), ]
  df_end
}

get_prov_codes_df <- function() {
  getnames <- c(
    "codauto",
    "cpro",
    "iso2.prov.code",
    "nuts.prov.code",
    "ine.prov.name",
    "iso2.prov.name.es",
    "iso2.prov.name.ca",
    "iso2.prov.name.ga",
    "iso2.prov.name.eu",
    "cldr.prov.name.en",
    "cldr.prov.name.es",
    "cldr.prov.name.ca",
    "cldr.prov.name.ga",
    "cldr.prov.name.eu",
    "prov.shortname.en",
    "prov.shortname.es",
    "prov.shortname.ca",
    "prov.shortname.ga",
    "prov.shortname.eu"
  )

  df_prov <- mapSpain::esp_codelist
  df_prov <- df_prov[, getnames]
  df_end <- unique(df_prov)
  df_end <- df_end[order(df_end$codauto), ]
  df_end
}

get_nuts1_codes_df <- function() {
  unique(mapSpain::esp_codelist[, c(
    "nuts2.code",
    "nuts1.code",
    "nuts1.name"
  )])
}

get_prov_nuts_codes_df <- function() {
  unique(mapSpain::esp_codelist[, c(
    "cpro",
    "nuts2.code",
    "nuts2.name",
    "nuts1.code",
    "nuts1.name"
  )])
}

filter_by_cpro_region <- function(data_sf, region) {
  region <- ensure_null(region)
  if (is.null(region)) {
    return(data_sf)
  }

  tonuts <- convert_to_nuts_prov(region)
  data_sf[data_sf$cpro %in% nuts_to_cpro(tonuts), ]
}

filter_by_codauto_region <- function(data_sf, region) {
  region <- ensure_null(region)
  if (is.null(region)) {
    return(data_sf)
  }

  nuts_id <- convert_to_nuts_ccaa(region)
  data_sf[data_sf$codauto %in% nuts_to_codauto(nuts_id), ]
}

filter_by_name_pattern <- function(data_sf, pattern, column) {
  pattern <- ensure_null(pattern)
  if (is.null(pattern)) {
    return(data_sf)
  }

  pattern <- paste(pattern, collapse = "|")
  data_sf[grep(pattern, data_sf[[column]], ignore.case = TRUE), ]
}

add_municipal_metadata <- function(
  data_sf,
  id_col,
  name_col,
  clean_id = FALSE,
  validate_cpro = TRUE
) {
  lau_code <- data_sf[[id_col]]
  if (clean_id) {
    lau_code <- gsub("\\D+", "", lau_code)
  }

  data_sf$LAU_CODE <- lau_code
  data_sf$name <- data_sf[[name_col]]
  data_sf$cpro <- substr(data_sf$LAU_CODE, 1, 2)

  cmun <- substr(data_sf$LAU_CODE, 3, 8)
  if (validate_cpro) {
    idprov <- sort(unique(mapSpain::esp_codelist$cpro))
    cmun <- ifelse(data_sf$cpro %in% idprov, cmun, NA)
  }
  data_sf$cmun <- cmun

  merge(
    data_sf,
    get_municipal_admin_codes(),
    by = "cpro",
    all.x = TRUE,
    no.dups = TRUE
  )
}

get_municipal_admin_codes <- function() {
  unique(mapSpain::esp_codelist[, c(
    "codauto",
    "ine.ccaa.name",
    "cpro",
    "ine.prov.name"
  )])
}
