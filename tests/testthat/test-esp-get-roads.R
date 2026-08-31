test_that("esp_get_roads() returns NULL while offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_roads(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_get_roads() returns NULL for HTTP 404 responses", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(n <- esp_get_roads(update_cache = TRUE), "HTTP error")
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("esp_get_roads() returns identical cached and uncached data", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- withr::local_tempdir(pattern = "testcacheroads-")
  expect_identical(list.files(cdir, recursive = TRUE), character(0))
  expect_message(
    db_online <- esp_get_roads(cache = FALSE, verbose = TRUE, cache_dir = cdir),
    "Reading from"
  )

  expect_identical(list.files(cdir, recursive = TRUE), character(0))

  # vs cache TRUE
  expect_silent(db_cached <- esp_get_roads(cache = TRUE, cache_dir = cdir))

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    c("siane/se89_3_vias_ctra_l_x.gpkg", "siane/se89_3_vias_ctra_l_y.gpkg")
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_roads() rejects unsupported CRS values", {
  expect_snapshot(error = TRUE, esp_get_roads(epsg = 3367))
})

test_that("esp_get_roads() transforms CRS and moves Canary geometries", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- withr::local_tempdir(pattern = "testroads-")
  expect_silent(regular <- esp_get_roads(cache_dir = cdir))

  l <- esp_get_roads(epsg = 3857, cache_dir = cdir)

  expect_identical(sf::st_crs(l), sf::st_crs(3857))
  expect_named(l, setdiff(names(l), "codauto"))
  expect_s3_class(l, "sf")
  expect_s3_class(l, "tbl_df")
  expect_gt(nrow(l), 100)
  expect_silent(nomov <- esp_get_roads(moveCAN = FALSE, cache_dir = cdir))

  expect_false(identical(sf::st_bbox(regular), sf::st_bbox(nomov)))
  expect_silent(moved <- esp_get_roads(moveCAN = TRUE, cache_dir = cdir))
  expect_identical(sf::st_bbox(regular), sf::st_bbox(moved))

  unlink(cdir, recursive = TRUE, force = TRUE)
})
