test_that("hypsobath online", {
  expect_error(esp_get_hypsobath(epsg = 3367))
  expect_error(esp_get_hypsobath(spatialtype = "f"))
  expect_error(esp_get_hypsobath(resolution = "10"))

  skip_if_siane_offline()

  expect_silent(esp_get_hypsobath(
    spatialtype = "line",
    resolution = "6.5",
    epsg = 3857
  ))

  l <- esp_get_hypsobath(
    spatialtype = "line",
    resolution = "6.5",
    epsg = 3857
  )

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(esp_get_hypsobath(spatialtype = "area", resolution = "6.5"))
})
