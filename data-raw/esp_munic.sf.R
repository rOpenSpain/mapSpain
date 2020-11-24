## code to prepare `esp_munic.sf` dataset goes here

options(gisco_cache_dir = "~/R/mapslib/GISCO")

library(mapSpain)
library(sf)
library(giscoR)

df <- esp_get_munic(verbose = TRUE)


esp_munic.sf <- st_transform(df, 4258)

usethis::use_data(esp_munic.sf, overwrite = TRUE, compress = "xz")
