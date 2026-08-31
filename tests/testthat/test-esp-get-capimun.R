test_that("esp_get_capimun() returns NULL while offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_capimun(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_get_capimun() returns NULL for HTTP 404 responses", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(n <- esp_get_capimun(update_cache = TRUE), "HTTP error")
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("esp_get_capimun() returns identical cached and uncached data", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- withr::local_tempdir(pattern = "testcapimun-")

  expect_identical(list.files(cdir, recursive = TRUE), character(0))
  expect_message(
    db_online <- esp_get_capimun(
      cache = FALSE,
      verbose = TRUE,
      cache_dir = cdir
    ),
    "Reading from"
  )

  expect_identical(list.files(cdir, recursive = TRUE), character(0))

  # vs cache TRUE
  expect_silent(db_cached <- esp_get_capimun(cache = TRUE, cache_dir = cdir))

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    c(
      "siane/se89_3_urban_capimuni_p_x.gpkg",
      "siane/se89_3_urban_capimuni_p_y.gpkg"
    )
  )
})

test_that("esp_get_capimun() filters municipalities and regions", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- withr::local_tempdir(pattern = "testcapimun-")

  db_cached <- esp_get_capimun(munic = "Melque", cache_dir = cdir)
  expect_shape(db_cached, nrow = 1)
  expect_identical(db_cached$ine.prov.name, "Segovia")

  db_cached <- esp_get_capimun(munic = "Nieva", cache_dir = cdir)
  expect_shape(db_cached, nrow = 3)
  expect_s3_class(db_cached, "sf")
  expect_s3_class(db_cached, "tbl_df")
  db_cached_reg <- esp_get_capimun(
    munic = "Nieva",
    region = "La Rioja",
    cache_dir = cdir
  )

  expect_lt(nrow(db_cached_reg), nrow(db_cached))

  db_3035 <- esp_get_capimun(
    munic = "Nieva",
    region = "La Rioja",
    epsg = 3035,
    cache_dir = cdir
  )
  expect_identical(sf::st_crs(3035), sf::st_crs(db_3035))

  expect_snapshot(
    null_res <- esp_get_capimun(
      region = "Galicia",
      munic = "Melque",
      cache_dir = cdir
    )
  )
  expect_identical(nrow(null_res), 0L)

  # Canary island not move
  ten_move <- esp_get_capimun(
    region = "Canarias",
    munic = "Tenerife",
    cache_dir = cdir
  )

  ten_move_par <- esp_get_capimun(
    region = "Canarias",
    munic = "Tenerife",
    moveCAN = TRUE,
    cache_dir = cdir
  )

  ten_nomove <- esp_get_capimun(
    region = "Canarias",
    munic = "Tenerife",
    moveCAN = FALSE,
    cache_dir = cdir
  )
  expect_identical(ten_move, ten_move_par)
  expect_false(identical(ten_move, ten_nomove))
})
