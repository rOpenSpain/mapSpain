test_that("esp_get_grid_MTN() returns NULL while offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_grid_MTN(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_get_grid_MTN() returns NULL for HTTP 404 responses", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(n <- esp_get_grid_MTN(update_cache = TRUE), "HTTP error")
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("esp_get_grid_MTN() rejects unknown grids", {
  expect_snapshot(error = TRUE, esp_get_grid_MTN("abcde"))
})

test_that("esp_get_grid_MTN() downloads a selected grid", {
  skip_on_cran()
  skip_if_siane_offline()
  tdir <- file.path(tempdir(), "testthat_test")
  tdir <- create_cache_dir(tdir)

  expect_message(esp_get_grid_MTN(cache_dir = tdir, verbose = TRUE))

  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})
