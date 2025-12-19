## code to prepare `sysdata` dataset goes here

rm(list = ls())

# Add grid files

library(sf)
esp_hexbin_prov <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_hexbin_prov.gpkg"
) |>
  mapSpain:::sanitize_sf()

esp_hexbin_ccaa <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_hexbin_ccaa.gpkg"
) |>
  mapSpain:::sanitize_sf()


esp_grid_prov <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_grid_prov.gpkg"
) |>
  mapSpain:::sanitize_sf()

esp_grid_ccaa <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_grid_ccaa.gpkg"
) |>
  mapSpain:::sanitize_sf()


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
