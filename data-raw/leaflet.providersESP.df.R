## code to prepare `leaflet.providersESP.df` dataset goes here
rm(list = ls())
source("./data-raw/helperfuns.R")

library(dplyr)
library(readxl)

leaflet.providersESP.df <-
  read_xlsx("./data-raw/input/leafletproviders-ESP.xlsx") %>%
  esp_hlp_utf8() %>%
  as.data.frame()

tb <- as_tibble(leaflet.providersESP.df)

usethis::use_data(leaflet.providersESP.df, overwrite = TRUE, compress = "xz")


rm(list = ls())
# Try

devtools::load_all()

# Try MDT
library(tidyterra)
ccaa <- esp_get_ccaa(c("Andalucia"), epsg = 3857)
tile <- esp_getTiles(ccaa, "IDErioja", crop = FALSE)

ggplot2::ggplot() +
  geom_spatraster_rgb(data = tile)
