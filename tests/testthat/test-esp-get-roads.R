test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_roads(update_cache = TRUE),
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
    n <- esp_get_roads(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
})


test_that("Cache vs non-cached", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testcacheroads")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_roads(
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
    db_cached <- esp_get_roads(
      cache = TRUE,
      cache_dir = cdir
    )
  )

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    c(
      "siane/se89_3_vias_ctra_l_x.gpkg",
      "siane/se89_3_vias_ctra_l_y.gpkg"
    )
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("roads online", {
  expect_error(esp_get_roads(epsg = 3367))

  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testroads")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_silent(regular <- esp_get_roads(cache_dir = cdir))

  l <- esp_get_roads(epsg = 3857, cache_dir = cdir)

  expect_identical(sf::st_crs(l), sf::st_crs(3857))
  expect_silent(nomov <- esp_get_roads(moveCAN = FALSE, cache_dir = cdir))

  expect_false(
    identical(sf::st_bbox(regular), sf::st_bbox(nomov))
  )
  expect_silent(moved <- esp_get_roads(moveCAN = TRUE, cache_dir = cdir))
  expect_identical(sf::st_bbox(regular), sf::st_bbox(moved))

  unlink(cdir, recursive = TRUE, force = TRUE)
})
