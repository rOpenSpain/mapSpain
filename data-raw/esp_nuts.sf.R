## code to prepare `esp_nuts.sf` dataset goes here


library(giscoR)
options(gisco_cache_dir = "~/R/mapslib/GISCO")

esp_nuts <-
  gisco_get_nuts(
    resolution = 1,
    verbose = TRUE,
    update_cache = TRUE,
    year = "2016",
    country = "ES"
  )

# Fix tmap_labels
library(sf)
unique(st_geometry_type(esp_nuts))

library(tmap)

tm_shape(esp_nuts[10:13, ]) +
  tm_text("NUTS_ID")

esp_nuts <- st_cast(esp_nuts, "MULTIPOLYGON")

tm_shape(esp_nuts[10:13, ]) +
  tm_text("NUTS_ID")

# Convert to ETRS89
esp_nuts.sf <- st_transform(esp_nuts, 4258)

usethis::use_data(esp_nuts.sf, overwrite = TRUE, compress = "xz")

tools::checkRdaFiles("./data")
