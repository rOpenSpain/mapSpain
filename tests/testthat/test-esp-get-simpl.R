test_that("Simplified boundary functions return NULL while offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_simpl_prov(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  expect_message(
    n <- esp_get_simpl_ccaa(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("Simplified boundary functions return NULL for HTTP 404", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(n <- esp_get_simpl_prov(update_cache = TRUE), "HTTP error")
  expect_null(n)

  expect_message(n <- esp_get_simpl_ccaa(update_cache = TRUE), "HTTP error")
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("Simplified boundary functions validate and filter data", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- withr::local_tempdir(pattern = "test-simp-")
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
