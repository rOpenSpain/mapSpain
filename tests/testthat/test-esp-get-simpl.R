test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_simpl_prov(update_cache = TRUE),
    "Offline"
  )
  expect_null(n)

  expect_message(
    n <- esp_get_simpl_ccaa(update_cache = TRUE),
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
    n <- esp_get_simpl_prov(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  expect_message(
    n <- esp_get_simpl_ccaa(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
})


test_that("simplified online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "test_simp")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_silent(n <- esp_get_simpl_ccaa(cache_dir = cdir))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 19)

  expect_silent(n <- esp_get_simpl_prov(cache_dir = cdir))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 52)

  expect_silent(n <- esp_get_simpl_prov("ES1", cache_dir = cdir))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 6)

  expect_silent(n <- esp_get_simpl_ccaa("ES1", cache_dir = cdir))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 3)

  #  Errors
  expect_snapshot(
    error = TRUE,
    esp_get_simpl_prov("Mallorca", cache_dir = cdir)
  )

  expect_snapshot(
    error = TRUE,
    esp_get_simpl_ccaa("Mallorca", cache_dir = cdir)
  )

  # Test all filter
  cpros <- unique(mapSpain::esp_codelist$cpro)
  expect_shape(esp_get_simpl_prov(cpros, cache_dir = cdir), nrow = 52)

  ccaa <- unique(mapSpain::esp_codelist$nuts2.name)
  expect_shape(esp_get_simpl_ccaa(ccaa, cache_dir = cdir), nrow = 19)

  unlink(cdir, recursive = TRUE, force = TRUE)
})
