test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_grid_ESDAC(update_cache = TRUE),
    "Offline"
  )
  expect_null(n)

  options(mapspain_test_offline = FALSE)
})

test_that("Test 404", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_404 = TRUE)
  expect_message(
    n <- esp_get_grid_ESDAC(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
})

test_that("Errors", {
  expect_error(esp_get_grid_ESDAC("50"))
})

test_that("ESDAC grid online", {
  skip_on_cran()
  skip_if_siane_offline()

  tdir <- file.path(tempdir(), "testthat_test")
  tdir <- create_cache_dir(tdir)

  # Grid 10 vs 1

  grid10 <- esp_get_grid_ESDAC(resolution = 10, cache_dir = tdir)
  expect_message(grid1 <- esp_get_grid_ESDAC(resolution = 1, cache_dir = tdir))

  expect_gt(object.size(grid1), object.size(grid10))

  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})
