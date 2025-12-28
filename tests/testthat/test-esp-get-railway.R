test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)

  expect_message(
    n <- esp_get_railway(update_cache = TRUE),
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
    n <- esp_get_railway(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
})


test_that("Cache vs non-cached", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "test_stations")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_railway(
      cache = FALSE,
      verbose = TRUE,
      cache_dir = cdir
    ),
    "Reading from"
  )

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )

  # vs cache TRUE
  expect_silent(
    db_cached <- esp_get_railway(
      cache = TRUE,
      cache_dir = cdir
    )
  )

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    "siane/se89_3_vias_ffcc_l_x.gpkg"
  )

  l <- esp_get_railway(epsg = 3857, cache_dir = cdir)

  expect_identical(sf::st_crs(l), sf::st_crs(3857))

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})


test_that("Deprecations", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "test_stations")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_snapshot(
    db_redirected <- esp_get_railway(cache_dir = cdir, spatialtype = "point")
  )

  nowcache <- list.files(cdir, recursive = TRUE)

  expect_silent(
    db2 <- esp_get_stations(cache = TRUE, update_cache = TRUE, cache_dir = cdir)
  )

  # Cache not modified, then must be the same file
  expect_identical(nowcache, list.files(cdir, recursive = TRUE))

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})
