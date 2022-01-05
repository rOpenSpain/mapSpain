test_that("Errors", {
  expect_error(esp_get_grid_EEA("50"))
  expect_error(esp_get_grid_EEA(type = "50"))
})

test_that("EEA grid online", {
  skip_on_cran()
  skip_if_siane_offline()

  expect_message(
    esp_get_grid_EEA(
      cache_dir = tempdir(),
      verbose = TRUE
    )
  )

  expect_message(
    esp_get_grid_EEA(
      cache_dir = tempdir(),
      update_cache = TRUE,
      verbose = TRUE
    )
  )
  expect_silent(esp_get_grid_EEA())
  expect_silent(esp_get_grid_EEA(type = "canary", resolution = 10))
})
