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

usethis::use_data(esp_codelist, overwrite = TRUE, compress = "xz")
tools::checkRdaFiles("./data")


# Resave just in case
write_csv(nuts1, "./data-raw/dict/esp_nuts1.csv", na = "")
write_csv(ccaa, "./data-raw/dict/esp_ccaa.csv", na = "")
write_csv(prov, "./data-raw/dict/esp_prov.csv", na = "")
write_csv(nuts3, "./data-raw/dict/esp_nuts3.csv", na = "")

rm(list = ls())
