test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_country(update_cache = TRUE, verbose = TRUE),
    "Offline"
  )
  expect_null(n)

  options(mapspain_test_offline = FALSE)
  options(gisco_test_offline = FALSE)
})

test_that("Test 404", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_404 = TRUE)
  options(mapspain_test_404 = TRUE)
  expect_message(
    n <- esp_get_country(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})


test_that("Check country", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "testcntry")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  expect_silent(s <- esp_get_country(cache_dir = cdir))

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_shape(s, nrow = 1)

  # EPSG work
  expect_silent(
    s <- esp_get_country(epsg = 3035, resolution = 20, cache_dir = cdir)
  )

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_identical(sf::st_crs(s)$epsg, 3035L)

  # Resolution work
  expect_silent(
    s2 <- esp_get_country(epsg = 3035, resolution = 60, cache_dir = cdir)
  )
  expect_s3_class(s2, "sf")
  expect_s3_class(s2, "tbl_df")

  expect_lt(object.size(s2), object.size(s))
  unlink(cdir, recursive = TRUE, force = TRUE)
})
