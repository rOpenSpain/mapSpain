library(tinytest)

expect_error(esp_get_ccaa("FFF"))
expect_silent(esp_get_ccaa())
expect_silent(esp_get_ccaa(ccaa = c("Galicia", "ES7", "Centro")))
expect_warning(esp_get_ccaa(ccaa = "Zamora"))
expect_warning(esp_get_ccaa(ccaa = "ES6x"))
expect_warning(esp_get_ccaa(ccaa = "Barcelona"))


# Test all

f <- mapSpain::esp_codelist

n <- esp_get_ccaa(ccaa = f$nuts1.code)
expect_equal(nrow(n), 19)

n <- esp_get_ccaa(ccaa = c("Melilla"))
expect_equal(nrow(n), 1)

n <- esp_get_ccaa(ccaa = f$nuts1.name.alt)
expect_equal(nrow(n), 19)

n <- esp_get_ccaa(ccaa = f$iso2.ccaa.code)
expect_equal(nrow(n), 19)

n <- esp_get_ccaa(ccaa = f$nuts2.code)
expect_equal(nrow(n), 19)

n <- esp_get_ccaa(ccaa = f$nuts2.name)
expect_equal(nrow(n), 19)

n <- esp_get_ccaa(ccaa = f$codauto)
expect_equal(nrow(n), 19)
