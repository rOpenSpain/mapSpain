test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_rivers(update_cache = TRUE),
    "Offline"
  )
  expect_null(n)
  expect_message(
    n <- esp_get_wetlands(update_cache = TRUE),
    "Offline"
  )
  expect_null(n)
  expect_message(
    n <- get_river_names(update_cache = TRUE),
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
    n <- esp_get_rivers(update_cache = TRUE),
    "Error"
  )
  expect_null(n)
  expect_message(
    n <- esp_get_wetlands(update_cache = TRUE),
    "Error"
  )
  expect_null(n)
  expect_message(
    n <- get_river_names(update_cache = TRUE),
    "Error"
  )
  expect_null(n)
  options(mapspain_test_404 = FALSE)
})


test_that("Cache vs non-cached rivers", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testrivers")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_rivers(
      cache = FALSE,
      verbose = TRUE,
      cache_dir = cdir
    ),
    "Reading from"
  )

  expect_identical(
    list.files(cdir, recursive = TRUE),
    "siane/rivernames.rda"
  )

  # vs cache TRUE
  expect_silent(
    db_cached <- esp_get_rivers(
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
      "siane/rivernames.rda",
      "siane/se89_3_hidro_rio_l_x.gpkg",
      "siane/se89_3_hidro_rio_l_y.gpkg"
    )
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("Cache vs non-cached wetlands", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testwetland")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_wetlands(
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
    db_cached <- esp_get_wetlands(
      cache = TRUE,
      cache_dir = cdir
    )
  )

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    "siane/se89_3_hidro_rio_a_x.gpkg"
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("Filtering names", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testwetland_online")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_silent(
    l <- esp_get_rivers(
      cache_dir = cdir,
      epsg = 3857
    )
  )
  expect_s3_class(l, "sf")
  expect_s3_class(l, "tbl_df")

  expect_equal(sf::st_crs(l)$epsg, 3857)

  expect_silent(
    l <- esp_get_wetlands(
      cache_dir = cdir,
      epsg = 3857
    )
  )
  expect_s3_class(l, "sf")
  expect_s3_class(l, "tbl_df")

  expect_equal(sf::st_crs(l)$epsg, 3857)

  expect_snapshot(ss <- esp_get_rivers(cache_dir = cdir, name = "NIDNIFOMDF"))
  expect_shape(ss, nrow = 0)

  expect_snapshot(ss <- esp_get_wetlands(cache_dir = cdir, name = "NIDNIFOMDF"))
  expect_shape(ss, nrow = 0)

  expect_silent(ebro <- esp_get_rivers(cache_dir = cdir, name = "Ebro"))
  expect_s3_class(ebro, "sf")
  expect_s3_class(ebro, "tbl_df")
  expect_lt(nrow(ebro), 20)

  expect_silent(
    serena <- esp_get_wetlands(
      cache_dir = cdir,
      name = "Serena"
    )
  )
  expect_s3_class(serena, "sf")
  expect_s3_class(serena, "tbl_df")
  expect_lt(nrow(serena), 5)

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("Deprecations", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testwetland_dep")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_snapshot(
    l <- esp_get_rivers(
      cache_dir = cdir,
      resolution = 10
    )
  )
  expect_s3_class(l, "sf")
  expect_s3_class(l, "tbl_df")
  expect_equal(sf::st_crs(l)$epsg, 4258)

  expect_snapshot(
    l1 <- esp_get_rivers(
      cache_dir = cdir,
      name = "Serena",
      spatialtype = "area"
    )
  )

  expect_silent(
    l2 <- esp_get_wetlands(
      cache_dir = cdir,
      name = "Serena"
    )
  )
  expect_s3_class(l2, "sf")
  expect_s3_class(l2, "tbl_df")

  expect_identical(l1, l2)

  unlink(cdir, recursive = TRUE, force = TRUE)
})
