expect_error(esp_get_hydrobasin(epsg = 3367))
expect_error(esp_get_hydrobasin(domain = "f"))



if (giscoR::gisco_check_access()) {
  expect_silent(esp_get_hydrobasin(
    domain = "landsea",
    resolution = "10",
    epsg = 3857
  ))

  l <- esp_get_hydrobasin(
    resolution = "10",
    epsg = 3857
  )

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(esp_get_hydrobasin(resolution = "10"))
  expect_message(esp_get_hydrobasin(resolution = "10", verbose = TRUE))
  expect_silent(esp_get_hydrobasin(resolution = "6.5"))
  expect_silent(esp_get_hydrobasin(resolution = "3"))
  expect_silent(esp_get_hydrobasin(resolution = "6.5", domain = "landsea"))
  expect_silent(esp_get_hydrobasin(resolution = "3", domain = "landsea"))
}
