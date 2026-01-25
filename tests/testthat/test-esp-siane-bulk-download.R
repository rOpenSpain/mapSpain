test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_siane_bulk_download(update_cache = TRUE),
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
    n <- esp_siane_bulk_download(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})


test_that("Online", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testthat", "bulk")
  if (dir.exists(cdir)) {
    unlink(cdir, force = TRUE, recursive = TRUE)
  }

  s <- esp_siane_bulk_download(cache_dir = cdir)

  expect_true(all(file.exists(s)))
  expect_message(s <- esp_siane_bulk_download(cache_dir = cdir, verbose = TRUE))

  if (dir.exists(cdir)) {
    unlink(cdir, force = TRUE, recursive = TRUE)
  }
})
