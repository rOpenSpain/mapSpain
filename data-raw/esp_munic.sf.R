## code to prepare `esp_munic.sf` dataset goes here
options(gisco_cache_dir = "~/R/mapslib/GISCO")

library(mapSpain)
library(sf)
library(giscoR)

df <- esp_get_munic(
  verbose = TRUE, moveCAN = FALSE, epsg = 4258,
  update_cache = TRUE
)


unique(st_geometry_type(df))
df <- st_cast(df, "MULTIPOLYGON")
unique(st_geometry_type(df))

esp_munic.sf <- df



usethis::use_data(esp_munic.sf, overwrite = TRUE, compress = "xz")
