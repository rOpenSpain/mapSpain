



test_that("rivers online", {
  expect_error(esp_get_rivers(epsg = 3367))
  expect_error(esp_get_rivers(spatialtype = "f"))


  skip_if_siane_offline()

  expect_silent(esp_get_rivers(
    spatialtype = "line",
    resolution = "10",
    epsg = 3857
  ))

  l <- esp_get_rivers(
    spatialtype = "line",
    resolution = "10",
    epsg = 3857
  )

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(esp_get_rivers(spatialtype = "area", resolution = "10"))
  expect_message(esp_get_rivers(resolution = "10", verbose = TRUE))
  expect_error(esp_get_rivers(resolution = "10", name = "NIDNIFOMDF"))
  expect_silent(esp_get_rivers(resolution = "10", name = "Ebro"))
  expect_silent(esp_get_rivers(
    resolution = "10",
    spatialtype = "area",
    name = "Serena"
  ))
})
