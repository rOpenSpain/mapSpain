library(tinytest)

expect_silent(esp_get_nuts())
expect_silent(esp_get_nuts(resolution = 1))
expect_silent(esp_get_nuts(nuts_level = 2, moveCAN = FALSE))
expect_silent(esp_get_nuts(nuts_level = 2, moveCAN = c(2, 2)))

expect_silent(esp_get_nuts(region = c("ES-AN", "ES-PV", "ES-P")))

expect_silent(esp_get_nuts(region = "Leon"))
expect_silent(esp_get_nuts(region = "Canarias"))
expect_silent(esp_get_nuts(region = "ES1"))
expect_message(esp_get_nuts(verbose = TRUE))
expect_error(esp_get_nuts(resolution = 32))
expect_error(esp_get_nuts(spatialtype = "XX"))
expect_error(esp_get_nuts(nuts_level = "XX"))
expect_error(esp_get_nuts(region = "Maidrid"))

# Check all nuts codes
a <- unique(c(
  esp_codelist$nuts1.code,
  esp_codelist$nuts2.code,
  esp_codelist$nuts3.code
))

l1 <- unique(esp_codelist$nuts1.code)
ff <- esp_get_nuts(region = l1)
expect_equal(length(l1), nrow(ff))

l1 <- unique(esp_codelist$nuts2.code)
ff <- esp_get_nuts(region = l1)
expect_equal(length(l1), nrow(ff))

l1 <- unique(esp_codelist$nuts3.code)
ff <- esp_get_nuts(region = l1)
expect_equal(length(l1), nrow(ff))


# Check all iso codes
b <- unique(c(esp_codelist$iso2.ccaa.code,
              esp_codelist$iso2.prov.code))
expect_warning(esp_get_nuts(region = b))

# Check names

expect_silent(esp_get_nuts(region = esp_codelist$nuts1.name))
expect_silent(esp_get_nuts(region = esp_codelist$nuts2.name))
expect_silent(esp_get_nuts(region = esp_codelist$nuts3.name))
expect_silent(esp_get_nuts(resolution = "20"))
