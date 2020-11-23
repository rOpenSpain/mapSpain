## code to prepare `esp_codelist` dataset goes here

library(dplyr)
source("./data-raw/helperfuns.R")


# Load ----


NUTS1 <-
  read.csv(
    "./data-raw/espNUTS1.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()

CCAA <-
  read.csv(
    "./data-raw/espCCAA.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()

PROV <-
  read.csv(
    "./data-raw/espPROV.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()

NUTS3 <-
  read.csv(
    "./data-raw/espNUTS3.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()


# Create full table
esp_codelist <-
  NUTS1 %>% left_join(CCAA) %>% left_join(PROV) %>% left_join(NUTS3) %>% as.data.frame()

usethis::use_data(esp_codelist, overwrite = TRUE, compress = "xz")
tools::checkRdaFiles("./data")

rm(list = ls())


