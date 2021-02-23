## code to prepare `leaflet.providersESP.df` dataset goes here
rm(list = ls())
source("./data-raw/helperfuns.R")

library(dplyr)
library(readxl)

leaflet.providersESP.df <-
  read_xlsx("./data-raw/input/leafletproviders-ESP.xlsx") %>%
  esp_hlp_utf8() %>%
  as.data.frame()


usethis::use_data(leaflet.providersESP.df, overwrite = TRUE, compress = "xz")
