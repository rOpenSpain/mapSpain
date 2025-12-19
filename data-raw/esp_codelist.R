## code to prepare `esp_codelist` dataset goes here

library(tidyverse)

# Load ----

nuts1 <- read_csv("./data-raw/dict/esp_nuts1.csv")
ccaa <- read_csv("./data-raw/dict/esp_ccaa.csv")
prov <- read_csv("./data-raw/dict/esp_prov.csv")
nuts3 <- read_csv("./data-raw/dict/esp_nuts3.csv")

# Create full table
esp_codelist <- nuts1 |>
  left_join(ccaa) |>
  left_join(prov) |>
  left_join(nuts3) |>
  as_tibble()

usethis::use_data(esp_codelist, overwrite = TRUE, compress = "xz")
tools::checkRdaFiles("./data")

rm(list = ls())
