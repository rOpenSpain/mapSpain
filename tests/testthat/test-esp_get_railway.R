expect_error(esp_get_railway(epsg = 3367))
expect_error(esp_get_railway(spatialtype = "aaff"))


test_that("railway online", {
  skip_if_not(
    giscoR::gisco_check_access(),
    "Skipping... GISCO not reachable."
  )

  expect_silent(esp_get_railway())

  l <- esp_get_railway(epsg = 3857)

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(esp_get_railway(spatialtype = "point"))
})
