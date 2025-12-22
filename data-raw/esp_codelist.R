## code to prepare `esp_codelist` dataset goes here

library(tidyverse)

# Load ----

nuts1 <- read_csv("./data-raw/dict/esp_nuts1.csv", trim_ws = TRUE)
ccaa <- read_csv("./data-raw/dict/esp_ccaa.csv", trim_ws = TRUE)
prov <- read_csv("./data-raw/dict/esp_prov.csv", trim_ws = TRUE)
nuts3 <- read_csv("./data-raw/dict/esp_nuts3.csv", trim_ws = TRUE)

# Create full table
esp_codelist <- nuts1 |>
  left_join(ccaa) |>
  left_join(prov) |>
  left_join(nuts3) |>
  as_tibble()

glimpse(esp_codelist)

# Everything should be UTF-8
f <- esp_codelist
ncol <- length(colnames(f))

for (i in seq_len(ncol)) {
  if (is.character(f[[i]])) {
    f[[i]] <- enc2utf8(f[[i]])
    # Check results
    cli::cli_alert_info(
      paste0(
        "In {.str {names(f)[i]}} UTF encodings are ",
        "{unique(stringi::stri_enc_isutf8(f[[i]]))}"
      )
    )
  }
}

esp_codelist <- f


usethis::use_data(esp_codelist, overwrite = TRUE, compress = "xz")
tools::checkRdaFiles("./data")

# Resave just in case
write_csv(nuts1, "./data-raw/dict/esp_nuts1.csv", na = "")
write_csv(ccaa, "./data-raw/dict/esp_ccaa.csv", na = "")
write_csv(prov, "./data-raw/dict/esp_prov.csv", na = "")
write_csv(nuts3, "./data-raw/dict/esp_nuts3.csv", na = "")

source("./data-raw/sysdata.R")
tools::resaveRdaFiles("data")
rm(list = ls())
