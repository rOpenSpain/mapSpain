test_that("esp_get_grid_EEA() is defunct", {
  expect_snapshot(error = TRUE, esp_get_grid_EEA())
  lifecycle::expect_defunct(esp_get_grid_EEA())
})
