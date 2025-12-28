## code to prepare `esp_nuts_2024` dataset goes here

library(giscoR)
library(dplyr)
esp_nuts_2024 <-
  gisco_get_nuts(
    resolution = 1,
    verbose = TRUE,
    year = 2024,
    country = "ES",
    update_cache = TRUE
  ) |>
  arrange(LEVL_CODE, NUTS_ID)

# Convert to ETRS89
esp_nuts_2024 <- st_transform(esp_nuts_2024, 4258)

usethis::use_data(esp_nuts_2024, overwrite = TRUE)
tools::checkRdaFiles("./data")
