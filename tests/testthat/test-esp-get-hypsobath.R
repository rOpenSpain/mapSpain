test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_hypsobath(update_cache = TRUE, verbose = FALSE),
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
    n <- esp_get_hypsobath(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})
test_that("hypsobath online", {
  expect_error(esp_get_hypsobath(epsg = 3367))
  expect_error(esp_get_hypsobath(spatialtype = "f"))
  expect_error(esp_get_hypsobath(resolution = "10"))

  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()
  cdir <- file.path(tempdir(), "testhypsobath")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  expect_silent(esp_get_hypsobath(
    spatialtype = "line",
    resolution = 6.5,
    epsg = 3857,
    cache_dir = cdir
  ))

  l <- esp_get_hypsobath(
    spatialtype = "line",
    resolution = "6.5",
    epsg = 3857,
    cache_dir = cdir
  )

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(esp_get_hypsobath(
    spatialtype = "area",
    resolution = "6.5",
    cache_dir = cdir
  ))
  unlink(cdir, recursive = TRUE, force = TRUE)
})
