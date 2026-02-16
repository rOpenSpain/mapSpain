test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_grid_MTN(update_cache = TRUE),
    "Offline"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("Test 404", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(
    n <- esp_get_grid_MTN(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("Errors", {
  expect_error(esp_get_grid_MTN("abcde"))
})

test_that("MTN grid online", {
  skip_on_cran()
  skip_if_siane_offline()
  tdir <- file.path(tempdir(), "testthat_test")
  tdir <- create_cache_dir(tdir)

  expect_message(
    esp_get_grid_MTN(
      cache_dir = tdir,
      verbose = TRUE
    )
  )

  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})
