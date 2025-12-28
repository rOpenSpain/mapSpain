test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_ccaa(update_cache = TRUE, verbose = TRUE),
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
    n <- esp_get_ccaa(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})


test_that("CCAA", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  expect_snapshot(error = TRUE, esp_get_ccaa("FFF"))
  expect_snapshot(n <- esp_get_ccaa(c("FFF", "Murcia")))
  expect_equal(nrow(n), 1)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")

  expect_silent(n <- esp_get_ccaa())
  expect_equal(nrow(n), 19)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")

  expect_silent(n <- esp_get_ccaa(ccaa = c("Galicia", "ES7", "Centro")))
  expect_equal(nrow(n), 5)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_snapshot(error = TRUE, esp_get_ccaa(ccaa = "Zamora"))
  expect_snapshot(error = TRUE, esp_get_ccaa(ccaa = "ES6x"))

  # Test all

  f <- mapSpain::esp_codelist

  n <- esp_get_ccaa(ccaa = f$nuts1.code)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa(ccaa = "Melilla")
  expect_equal(nrow(n), 1)

  n <- esp_get_ccaa(ccaa = f$nuts1.name.alt)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa(ccaa = f$iso2.ccaa.code)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa(ccaa = f$nuts2.code)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa(ccaa = f$nuts2.name)
  expect_equal(nrow(n), 19)

  n <- esp_get_ccaa(ccaa = f$codauto)
  expect_equal(nrow(n), 19)
})
