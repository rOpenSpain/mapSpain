expect_error(esp_get_roads(epsg = 3367))


if (giscoR::gisco_check_access()) {
  expect_silent(esp_get_roads())

  l <- esp_get_roads(epsg = 3857)

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(esp_get_roads(moveCAN = FALSE))
  expect_silent(esp_get_roads(moveCAN = TRUE))
  expect_silent(esp_get_roads(moveCAN = c(2, 2)))
}
