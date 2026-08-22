test_that("esp_siane_bulk_download() returns NULL while offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_siane_bulk_download(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_siane_bulk_download() returns NULL for HTTP 404 responses", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(
    n <- esp_siane_bulk_download(update_cache = TRUE),
    "HTTP error"
  )
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("esp_siane_bulk_download() downloads all requested files", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testthat", "bulk")
  if (dir.exists(cdir)) {
    unlink(cdir, force = TRUE, recursive = TRUE)
  }

  s <- esp_siane_bulk_download(cache_dir = cdir)

  expect_gt(length(s), 0)
  expect_all_true(file.exists(s))
  expect_message(s <- esp_siane_bulk_download(cache_dir = cdir, verbose = TRUE))

  if (dir.exists(cdir)) {
    unlink(cdir, force = TRUE, recursive = TRUE)
  }
})
