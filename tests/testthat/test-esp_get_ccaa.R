test_that("CCAA", {
  expect_warning(expect_error(esp_get_ccaa("FFF")))
  expect_silent(esp_get_ccaa())
  expect_silent(esp_get_ccaa(ccaa = c("Galicia", "ES7", "Centro")))
  expect_warning(esp_get_ccaa(ccaa = "Zamora"))
  expect_warning(expect_error(esp_get_ccaa(ccaa = "ES6x")))
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
})

# Test siane
test_that("ccaa online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  expect_error(esp_get_ccaa_siane(epsg = "FFF"))

  expect_silent(esp_get_ccaa_siane())

  expect_message(esp_get_ccaa_siane(cache = FALSE, verbose = TRUE))


  expect_silent(esp_get_ccaa_siane("Canarias"))
  expect_silent(esp_get_ccaa_siane(rawcols = TRUE))
  expect_silent(esp_get_ccaa_siane(ccaa = c("Galicia", "ES7", "Centro")))
  expect_error(esp_get_ccaa_siane(epsg = 39823))
  expect_silent(esp_get_ccaa_siane())
  expect_silent(esp_get_ccaa_siane(moveCAN = c(1, 2)))
  expect_silent(esp_get_ccaa_siane(ccaa = c("Galicia", "ES7", "Centro")))
  expect_warning(esp_get_ccaa_siane(ccaa = "Menorca"))
  expect_warning(expect_error(esp_get_ccaa_siane(ccaa = "ES6x")))


  expect_equal(
    sf::st_crs(esp_get_ccaa_siane(epsg = 3035)),
    sf::st_crs(3035)
  )

  expect_equal(
    sf::st_crs(esp_get_ccaa_siane(epsg = 3857)),
    sf::st_crs(3857)
  )



  # Test all

  f <- mapSpain::esp_codelist

  n <- esp_get_ccaa_siane(ccaa = f$nuts1.code)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa_siane(ccaa = c("Melilla"))
  expect_equal(nrow(n), 1)

  n <- esp_get_ccaa_siane(ccaa = f$nuts1.name.alt)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa_siane(ccaa = f$iso2.ccaa.code)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa_siane(ccaa = f$nuts2.code)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa_siane(ccaa = f$nuts2.name)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa_siane(ccaa = f$codauto)
  expect_equal(nrow(n), 19)
})
