test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_spain_siane(update_cache = TRUE, verbose = TRUE),
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
  skip_if_gisco_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(
    n <- esp_get_spain_siane(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("Check country", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "testcntry_siane")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  expect_silent(s <- esp_get_spain_siane(cache_dir = cdir))

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_shape(s, nrow = 1)

  # EPSG work
  expect_silent(
    s <- esp_get_spain_siane(epsg = 3035, resolution = 6.5, cache_dir = cdir)
  )

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_identical(sf::st_crs(s)$epsg, 3035L)

  # Resolution work
  expect_silent(
    s2 <- esp_get_spain_siane(epsg = 3035, resolution = 10, cache_dir = cdir)
  )
  expect_s3_class(s2, "sf")
  expect_s3_class(s2, "tbl_df")

  expect_lt(object.size(s2), object.size(s))
  unlink(cdir, recursive = TRUE, force = TRUE)
})
