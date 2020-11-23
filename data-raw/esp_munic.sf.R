## code to prepare `esp_munic.sf` dataset goes here

options(mapSpain_cache_dir = "~/R/mapslib/GISCO")

library(mapSpain)


data.sf <- esp_get_munic(verbose = TRUE,
                         moveCAN = FALSE)


esp_munic.sf <- st_transform(data.sf, 4258)

usethis::use_data(esp_munic.sf, overwrite = TRUE, compress = "xz")
