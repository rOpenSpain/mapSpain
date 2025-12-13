test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_grid_BDN(update_cache = TRUE),
    "Offline"
  )
  expect_null(n)

  expect_message(
    n <- esp_get_grid_BDN_ccaa(ccaa = "Murcia", update_cache = TRUE),
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
    n <- esp_get_grid_BDN(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  expect_message(
    n <- esp_get_grid_BDN_ccaa(ccaa = "Murcia", update_cache = TRUE),
    "Error"
  )
  expect_null(n)
  options(mapspain_test_404 = FALSE)
})

test_that("Errors", {
  expect_snapshot(error = TRUE, esp_get_grid_BDN("50"))
  expect_snapshot(error = TRUE, esp_get_grid_BDN(type = "50"))
  expect_snapshot(error = TRUE, esp_get_grid_BDN_ccaa("Sevilla"))
  expect_snapshot(error = TRUE, esp_get_grid_BDN_ccaa())
})


test_that("BDN grid online", {
  skip_on_cran()
  skip_if_siane_offline()

  tdir <- file.path(tempdir(), "testthat_test")
  tdir <- create_cache_dir(tdir)

  # Grid 10 vs 5

  grid10 <- esp_get_grid_BDN(resolution = 10, cache_dir = tdir)
  expect_message(grid5 <- esp_get_grid_BDN(resolution = 5, cache_dir = tdir))

  expect_gt(object.size(grid5), object.size(grid10))

  # Canarias
  grid10_c <- esp_get_grid_BDN(
    resolution = 10,
    cache_dir = tdir,
    type = "canary"
  )
  expect_silent(
    grid5_c <- esp_get_grid_BDN(
      resolution = 5,
      cache_dir = tdir,
      type = "canary"
    )
  )

  expect_gt(object.size(grid5_c), object.size(grid10_c))
  expect_gt(object.size(grid5), object.size(grid5_c))
  expect_gt(object.size(grid10), object.size(grid10_c))

  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})


test_that("BDN grid online CCAA", {
  skip_on_cran()
  skip_if_siane_offline()

  tdir <- file.path(tempdir(), "testthat_test")
  tdir <- create_cache_dir(tdir)
  expect_message(
    esp_get_grid_BDN_ccaa("Ceuta", cache_dir = tdir, verbose = TRUE)
  )

  expect_silent(esp_get_grid_BDN_ccaa("Melilla", cache_dir = tdir))
  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})
