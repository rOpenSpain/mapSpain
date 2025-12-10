## code to prepare `esp_nuts.sf` dataset goes here

library(giscoR)

esp_nuts.sf |> sf::st_crs()

esp_nuts <-
  gisco_get_nuts(
    resolution = 1,
    verbose = TRUE,
    year = "2016",
    country = "ES",
    update_cache = TRUE
  )

# Convert to ETRS89
esp_nuts.sf <- st_transform(esp_nuts, 4258)

usethis::use_data(esp_nuts.sf, overwrite = TRUE, compress = "xz")

tools::checkRdaFiles("./data")
