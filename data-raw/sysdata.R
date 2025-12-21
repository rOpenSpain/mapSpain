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


# Databases
dbs <- list.files(
  "data-raw/listas_de_valores_enumerados/",
  pattern = "dbf",
  full.names = TRUE
)


db_valores <- lapply(dbs, function(x) {
  f <- tibble::as_tibble(foreign::read.dbf(x))
  clean_x <- gsub("lve_", "", basename(x))
  clean_x <- gsub(".dbf", "", clean_x)
  clean_x <- tolower(clean_x)
  f$campo <- clean_x
  f[, unique(c("campo", colnames(f)))]
}) |>
  dplyr::bind_rows() |>
  dplyr::as_tibble() |>
  dplyr::mutate(descrip = as.character(descrip))


usethis::use_data(
  db_valores,
  esp_hexbin_ccaa,
  esp_hexbin_prov,
  esp_grid_ccaa,
  esp_grid_prov,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

tools::checkRdaFiles("./R")
