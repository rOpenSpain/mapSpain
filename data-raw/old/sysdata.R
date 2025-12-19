## code to prepare `sysdata` dataset goes here

rm(list = ls())

# Add grid files

library(sf)
esp_hexbin_prov <- read_geo_file_sf("./data-raw/esp_hexbin_prov.gpkg") |>
  sanitize_sf()

esp_hexbin_ccaa <- read_geo_file_sf("./data-raw/esp_hexbin_ccaa.gpkg") |>
  sanitize_sf()


esp_grid_prov <- read_geo_file_sf("./data-raw/esp_grid_prov.gpkg")

esp_grid_ccaa <- read_geo_file_sf("./data-raw/esp_grid_ccaa.gpkg")


usethis::use_data(
  esp_hexbin_ccaa,
  esp_hexbin_prov,
  esp_grid_ccaa,
  esp_grid_prov,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

tools::checkRdaFiles("./R")
