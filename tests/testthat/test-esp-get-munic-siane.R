test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_munic_siane(update_cache = TRUE),
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
    n <- esp_get_munic_siane(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
})


test_that("Cache vs non-cached", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testmunicsiane")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_munic_siane(
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
    db_cached <- esp_get_munic_siane(
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
      "siane/se89_3_admin_muni_a_x.gpkg",
      "siane/se89_3_admin_muni_a_y.gpkg"
    )
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("Filter munis and regions", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testmunicsiane")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  db_cached <- esp_get_munic_siane(munic = "Melque", cache_dir = cdir)
  expect_shape(db_cached, nrow = 1)
  expect_identical(db_cached$ine.prov.name, "Segovia")

  db_cached <- esp_get_munic_siane(
    munic = "Nieva",
    cache_dir = cdir,
    year = 2010
  )
  expect_shape(db_cached, nrow = 4)
  expect_s3_class(db_cached, "sf")
  expect_s3_class(db_cached, "tbl_df")
  db_cached_reg <- esp_get_munic_siane(
    munic = "Nieva",
    region = "La Rioja",
    cache_dir = cdir,
    year = 2010
  )

  expect_lt(nrow(db_cached_reg), nrow(db_cached))

  expect_snapshot(
    null_res <- esp_get_munic_siane(
      region = "Galicia",
      munic = "Melque",
      cache_dir = cdir
    )
  )
  expect_identical(nrow(null_res), 0L)

  # Canary island not move
  ten_move <- esp_get_munic_siane(
    region = "Canarias",
    munic = "Tenerife",
    cache_dir = cdir
  )

  ten_move_par <- esp_get_munic_siane(
    region = "Canarias",
    munic = "Tenerife",
    moveCAN = TRUE,
    cache_dir = cdir
  )

  ten_nomove <- esp_get_munic_siane(
    region = "Canarias",
    munic = "Tenerife",
    moveCAN = FALSE,
    cache_dir = cdir
  )
  expect_identical(ten_move[1, ], ten_move_par[1, ])
  expect_false(identical(ten_move[1, ], ten_nomove[, 1]))

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})
