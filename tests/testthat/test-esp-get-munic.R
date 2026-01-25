test_that("Test null", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  my_fun <- giscor_get_lau

  # Risky approach...
  local_mocked_bindings(giscor_get_lau = function(...) {
    NULL
  })

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })

  n <- esp_get_munic(update_cache = TRUE, verbose = TRUE)
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
  local_mocked_bindings(giscor_get_lau = my_fun)
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
