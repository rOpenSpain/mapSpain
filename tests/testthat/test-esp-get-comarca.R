test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_comarca(update_cache = TRUE, verbose = FALSE),
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
    n <- esp_get_comarca(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})

test_that("comarcas online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "test_comarcas")
  unlink(cdir, recursive = TRUE, force = TRUE)
  expect_silent(n <- esp_get_comarca(cache_dir = cdir))

  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")

  expect_message(
    ncan <- esp_get_comarca(
      region = "Canarias",
      verbose = TRUE,
      cache_dir = cdir
    )
  )
  expect_lt(nrow(ncan), nrow(n))

  expect_error(esp_get_comarca(region = "XX", cache_dir = cdir))
  expect_error(esp_get_comarca(epsg = "5689", cache_dir = cdir))
  expect_snapshot(nemty <- esp_get_comarca(comarca = "XX", cache_dir = cdir))

  expect_equal(nrow(nemty), 0)

  expect_silent(n <- esp_get_comarca(comarca = "Rioja", cache_dir = cdir))

  expect_shape(n, nrow = 7)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")

  expect_silent(esp_get_comarca(region = "Alava", cache_dir = cdir))

  a <- mapSpain::esp_codelist
  n <- a$nuts1.name

  s <- esp_get_comarca(region = n, cache_dir = cdir)
  expect_equal(length(unique(s$cpro)), 52)

  # Types
  n <- esp_get_comarca(comarca = "Ebro", cache_dir = cdir)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_lt(nrow(n), 10)

  n <- esp_get_comarca(type = "IGN", comarca = "Ebro", cache_dir = cdir)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_lt(nrow(n), 10)

  n <- esp_get_comarca(type = "AGR", comarca = "Ebro", cache_dir = cdir)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_lt(nrow(n), 10)

  n <- esp_get_comarca(type = "LIV", comarca = "Ebro", cache_dir = cdir)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_lt(nrow(n), 10)

  unlink(cdir, recursive = TRUE, force = TRUE)
})
