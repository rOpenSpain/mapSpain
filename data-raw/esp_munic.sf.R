## code to prepare `esp_munic.sf` dataset goes here

options(gisco_cache_dir = "~/R/mapslib/GISCO")

library(mapSpain)
library(sf)
library(giscoR)

df <- esp_get_munic(verbose = TRUE, moveCAN = FALSE, epsg = 4258)
plot(df$geometry)



sf::st_g


e <- st_crs(esp_get_ccaa())
esp_munic.sf <- st_transform(df, st_crs(df))
esp_munic.sf <- sf::st_make_valid(esp_munic.sf)



usethis::use_data(esp_munic.sf, overwrite = TRUE, compress = "xz")
