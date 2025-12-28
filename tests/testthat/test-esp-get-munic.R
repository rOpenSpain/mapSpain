test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_munic(update_cache = TRUE, verbose = TRUE),
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
    n <- esp_get_munic(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})


test_that("Test munic online", {
  skip_on_cran()
  skip_if_gisco_offline()
  cdir <- file.path(tempdir(), "test_gisco_munis")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  expect_no_error(
    a1 <- esp_get_munic(year = 2024, cache_dir = cdir)
  )
  expect_s3_class(a1, "sf")
  expect_s3_class(a1, "tbl_df")
  expect_identical(unique(a1$CNTR_CODE), "ES")

  # Issue #121
  expect_no_error(
    a1 <- esp_get_munic(year = 2001, cache_dir = cdir)
  )

  expect_s3_class(a1, "sf")
  expect_s3_class(a1, "tbl_df")
  expect_identical(unique(a1$CNTR_CODE), "ES")

  # Issue #121
  expect_no_error(
    a1 <- esp_get_munic(year = 2004, cache_dir = cdir)
  )

  expect_s3_class(a1, "sf")
  expect_s3_class(a1, "tbl_df")
  expect_identical(unique(a1$CNTR_CODE), "ES")

  # Filtering
  db_cached <- esp_get_munic(munic = "Melque", cache_dir = cdir, year = 2024)
  expect_shape(db_cached, nrow = 1)
  expect_identical(db_cached$ine.prov.name, "Segovia")

  db_cached <- esp_get_capimun(munic = "Nieva", cache_dir = cdir, year = 2024)
  expect_shape(db_cached, nrow = 3)
  expect_s3_class(db_cached, "sf")
  expect_s3_class(db_cached, "tbl_df")
  db_cached_reg <- esp_get_munic(
    munic = "Nieva",
    region = "La Rioja",
    year = 2024,
    cache_dir = cdir
  )

  expect_lt(nrow(db_cached_reg), nrow(db_cached))

  expect_snapshot(
    null_res <- esp_get_munic(
      region = "Galicia",
      munic = "Melque",
      year = 2024,
      cache_dir = cdir
    )
  )
  expect_identical(nrow(null_res), 0L)

  # Canary island not move
  ten_move <- esp_get_munic(
    region = "Canarias",
    munic = "Tenerife",
    year = 2024,
    cache_dir = cdir
  )

  ten_move_par <- esp_get_munic(
    region = "Canarias",
    munic = "Tenerife",
    year = 2024,
    moveCAN = TRUE,
    cache_dir = cdir
  )

  ten_nomove <- esp_get_munic(
    region = "Canarias",
    munic = "Tenerife",
    year = 2024,
    moveCAN = FALSE,
    cache_dir = cdir
  )
  expect_identical(ten_move, ten_move_par)
  expect_false(identical(ten_move, ten_nomove))

  db_3035 <- esp_get_munic(
    munic = "Nieva",
    region = "La Rioja",
    epsg = 3035,
    cache_dir = cdir
  )
  expect_identical(sf::st_crs(3035), sf::st_crs(db_3035))

  unlink(cdir, recursive = TRUE, force = TRUE)
})
