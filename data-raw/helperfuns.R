esp_hlp_rm_accent <- function(str, pattern = "all") {
  if (!is.character(str)) {
    str <- as.character(str)
  }

  pattern <- unique(pattern)

  if (any(pattern == "Ç")) {
    pattern[pattern == "Ç"] <- "ç"
  }

  symbols <- c(
    acute = "áéíóúÁÉÍÓÚýÝ",
    grave = "àèìòùÀÈÌÒÙ",
    circunflex = "âêîôûÂÊÎÔÛ",
    tilde = "ãõÃÕñÑ",
    umlaut = "äëïöüÄËÏÖÜÿ",
    cedil = "çÇ"
  )

  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )

  accentTypes <- c("´", "`", "^", "~", "¨", "ç")

  if (any(c("all", "al", "a", "todos", "t", "to", "tod", "todo") %in% pattern)) {
    # opcao retirar todos
    return(chartr(
      paste(symbols, collapse = ""),
      paste(nudeSymbols, collapse = ""),
      str
    ))
  }

  for (i in which(accentTypes %in% pattern)) {
    str <- chartr(symbols[i], nudeSymbols[i], str)
  }

  return(str)
}


esp_hlp_utf8 <- function(data.sf) {
  f <- data.sf
  ncol <- length(colnames(f))

  for (i in seq(1, ncol)) {
    if (is.character(f[, i])) {
      f[, i] <- enc2utf8(f[, i])
    }
  }
  return(f)
}


esp_hlp_names2nuts <- function() {
  # Create base codes
  basecod <- names_full
  basecod <-
    data.frame(key = unique(basecod[, "key"]), stringsAsFactors = FALSE)

  # Create code dict nuts
  dict_nuts1mod <- dict_nuts1
  dict_nuts1mod <- dict_nuts1mod[, c("key", "nuts1.code")]
  names(dict_nuts1mod) <- c("key", "nuts")

  dict_nuts2mod <- dict_ccaa
  dict_nuts2mod <- dict_nuts2mod[, c("key", "nuts2.code")]
  names(dict_nuts2mod) <- c("key", "nuts")

  dict_nuts3mod <- dict_nuts3
  dict_nuts3mod <- dict_nuts3mod[, c("key", "nuts3.code")]
  names(dict_nuts3mod) <- c("key", "nuts")

  dict_nuts <- dict_nuts1mod
  dict_nuts <-
    rbind(dict_nuts, dict_nuts2mod[!(dict_nuts2mod$key %in% dict_nuts$key), ])
  dict_nuts <-
    rbind(dict_nuts, dict_nuts3mod[!(dict_nuts3mod$key %in% dict_nuts$key), ])
  dict_nuts <- unique(dict_nuts)

  rm(dict_nuts1mod, dict_nuts2mod, dict_nuts3mod)
  basecod <- merge(basecod, dict_nuts, all.x = TRUE)

  # Fake NUTS for Canary Islands
  basecod[basecod$key == "Las Palmas", ]$nuts <- "XXXXX"
  basecod[basecod$key == "Santa Cruz de Tenerife", ]$nuts <- "YYYYY"
  return(basecod)
}

esp_hlp_code2code <- function() {
  rm(list = ls())

  # First level - NUTS1

  df <- mapSpain::esp_codelist

  nt1 <- unique(df$nuts1.code)


  # Second level - NUTS2 - CCAA
  nt2 <- unique(df[, c("nuts2.code", "iso2.ccaa.code", "codauto")])

  # Third level - Prov and NUTS

  l3 <- unique(df[, c("iso2.prov.code", "cpro", "nuts.prov.code")])
  l3[l3$iso2.prov.code == "ES-PM", ]$nuts.prov.code <- NA

  # Additional level - NUTS3

  nt3 <- unique(df[, c("nuts3.code")])

  # Compose a full data frame

  base.df <- data.frame(nuts = nt1, stringsAsFactors = FALSE)

  colnames(nt2) <- c("nuts", "iso2", "codauto")

  base.df <- unique(merge(base.df, nt2, all.x = TRUE, all.y = TRUE))

  colnames(l3) <- c("iso2", "cpro", "nuts")
  base.df <- unique(merge(base.df, l3, all.x = TRUE, all.y = TRUE))


  # Add missing NUTS3
  missnuts <- data.frame(
    nuts = nt3[!nt3 %in% base.df$nuts],
    iso2 = NA,
    codauto = NA,
    cpro = NA,
    stringsAsFactors = FALSE
  )

  dict_codes.df <- rbind(base.df, missnuts)

  dict_codes.df$iso2 == "ES-GC"

  # Fake NUTS for Canary Islands
  dict_codes.df[dict_codes.df$iso2 == "ES-GC" &
    !is.na(dict_codes.df$iso2), ]$nuts <- "XXXXX"


  dict_codes.df[dict_codes.df$iso2 == "ES-TF" &
    !is.na(dict_codes.df$iso2), ]$nuts <- "YYYYY"

  # Remove dups on Ceuta y Melilla
  dict_codes.df[dict_codes.df$nuts == "ES64" & !is.na(dict_codes.df$nuts), "iso2"] <- NA

  dict_codes.df[dict_codes.df$nuts == "ES63" & !is.na(dict_codes.df$nuts), "iso2"] <- NA

  return(dict_codes.df)
}
