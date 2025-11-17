## code to prepare `esp_munic.sf` dataset goes here

install.packages("giscoR")

library(mapSpain)
library(sf)
library(giscoR)

df <- esp_get_munic(
  verbose = TRUE, moveCAN = FALSE, epsg = 4258,
  update_cache = TRUE
)
plot(df$geometry)


esp_munic.sf <- df


usethis::use_data(esp_munic.sf, overwrite = TRUE, compress = "xz")
