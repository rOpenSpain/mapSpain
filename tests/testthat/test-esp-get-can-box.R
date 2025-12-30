test_that("Testing can bbox", {
  skip_on_cran()
  skip_if_gisco_offline()

  expect_snapshot(error = TRUE, esp_get_can_box(style = "ee"))
  expect_snapshot(error = TRUE, esp_get_can_box(epsg = "ee"))
  expect_silent(esp_get_can_box())
  expect_silent(esp_get_can_box("box"))
  expect_silent(esp_get_can_box("left"))
  expect_silent(esp_get_can_box(moveCAN = FALSE))
  expect_silent(esp_get_can_box(moveCAN = c(10, 10)))

  expect_snapshot(error = TRUE, esp_get_can_provinces(epsg = "ee"))
  expect_silent(esp_get_can_provinces(moveCAN = FALSE))
  expect_silent(esp_get_can_provinces(moveCAN = c(10, 10)))
})
