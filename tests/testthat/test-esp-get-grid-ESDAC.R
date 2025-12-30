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

  tdir <- file.path(tempdir(), "testthat_test_esdac")
  tdir <- create_cache_dir(tdir)

  # Grid 10 vs 1

  expect_silent(
    grid10 <- esp_get_grid_ESDAC(resolution = 10, cache_dir = tdir)
  )

  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})
