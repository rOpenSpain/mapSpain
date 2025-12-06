test_that("Errors", {
  expect_error(esp_get_grid_BDN("50"))
  expect_error(esp_get_grid_BDN(type = "50"))
  expect_warning(expect_error(esp_get_grid_BDN_ccaa("Sevilla")))
})

test_that("BDN grid online", {
  skip_on_cran()
  skip_if_siane_offline()

  expect_message(
    esp_get_grid_BDN(
      cache_dir = tempdir(),
      verbose = TRUE
    )
  )

  expect_message(
    esp_get_grid_BDN(
      cache_dir = tempdir(),
      update_cache = TRUE,
      verbose = TRUE
    )
  )

  expect_message(
    esp_get_grid_BDN(
      type = "canary",
      cache_dir = tempdir(),
      update_cache = TRUE,
      verbose = TRUE
    )
  )
  expect_silent(esp_get_grid_BDN(
    resolution = 5,
    type = "canary",
    cache_dir = tempdir()
  ))
})


test_that("BDN grid online CCAA", {
  skip_on_cran()
  skip_if_siane_offline()

  expect_message(
    esp_get_grid_BDN_ccaa("Ceuta", cache_dir = tempdir(), verbose = TRUE)
  )

  expect_message(
    esp_get_grid_BDN_ccaa(
      "Ceuta",
      cache_dir = tempdir(),
      update_cache = TRUE,
      verbose = TRUE
    )
  )

  expect_silent(esp_get_grid_BDN_ccaa("Melilla", cache_dir = tempdir()))
})
