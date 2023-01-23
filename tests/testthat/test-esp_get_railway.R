test_that("railway online", {
  expect_error(esp_get_railway(epsg = 3367))
  expect_error(esp_get_railway(spatialtype = "aaff"))

  skip_on_cran()
  skip_if_siane_offline()

  expect_silent(esp_get_railway())

  l <- esp_get_railway(epsg = 3857)

  expect_identical(sf::st_crs(l), sf::st_crs(3857))
  expect_silent(esp_get_railway(spatialtype = "point"))
})
