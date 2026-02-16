test_that("Test null", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  local_fun <- esp_get_nuts
  local_mocked_bindings(esp_get_nuts = function(...) {
    NULL
  })
  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })

  n <- esp_get_spain(update_cache = TRUE, verbose = TRUE)

  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
  local_mocked_bindings(esp_get_nuts = local_fun)
})

test_that("Check country", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "testcntry")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  expect_silent(s <- esp_get_spain(cache_dir = cdir))

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_shape(s, nrow = 1)

  # EPSG work
  expect_silent(
    s <- esp_get_spain(epsg = 3035, resolution = 20, cache_dir = cdir)
  )

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_identical(sf::st_crs(s)$epsg, 3035L)

  # Resolution work
  expect_silent(
    s2 <- esp_get_spain(epsg = 3035, resolution = 60, cache_dir = cdir)
  )
  expect_s3_class(s2, "sf")
  expect_s3_class(s2, "tbl_df")

  expect_lt(object.size(s2), object.size(s))
  unlink(cdir, recursive = TRUE, force = TRUE)
})
