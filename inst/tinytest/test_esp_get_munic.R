library(tinytest)

expect_silent(esp_get_munic())
expect_silent(esp_get_munic(moveCAN = FALSE))
expect_silent(esp_get_munic(moveCAN = c(0, 10)))
expect_error(esp_get_munic(region = "XX"))
expect_error(esp_get_munic(year = "2040"))
expect_error(esp_get_munic(munic = "XX"))
expect_silent(esp_get_munic(munic = "Nieva"))
expect_silent(esp_get_munic(region = "Alava"))
expect_message(esp_get_munic(region = "Canarias", verbose = TRUE))

a <- mapSpain::esp_codelist
n <- a$nuts1.name

s <- esp_get_munic(region = n)
expect_equal(length(unique(s$cpro)), 52)
