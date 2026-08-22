test_that("esp_get_grid_ESDAC() returns NULL while offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_grid_ESDAC(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_get_grid_ESDAC() returns NULL for HTTP 404 responses", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(n <- esp_get_grid_ESDAC(update_cache = TRUE), "HTTP error")
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("esp_get_grid_ESDAC() rejects invalid resolutions", {
  expect_snapshot(error = TRUE, esp_get_grid_ESDAC("50"))
})

test_that("esp_get_grid_ESDAC() downloads the 10 km grid", {
  skip_on_cran()
  skip_if_siane_offline()

  tdir <- file.path(tempdir(), "testthat_test_esdac")
  tdir <- create_cache_dir(tdir)

  # Grid 10 vs 1

  expect_silent(grid10 <- esp_get_grid_ESDAC(resolution = 10, cache_dir = tdir))
  expect_s3_class(grid10, "sf")
  expect_s3_class(grid10, "tbl_df")
  expect_gt(nrow(grid10), 0)

  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})

test_that("esp_get_grid_ESDAC() builds the 1 km download request", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(download_and_read_geo_file = function(url, ...) {
    expect_snapshot(url)
    NULL
  })

  tdir <- file.path(tempdir(), "testthat_test_esdac2")
  tdir <- create_cache_dir(tdir)
  expect_null(esp_get_grid_ESDAC(resolution = 1, cache_dir = tdir))
  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})
