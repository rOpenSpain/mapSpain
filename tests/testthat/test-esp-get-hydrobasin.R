test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_hydrobasin(update_cache = TRUE, verbose = FALSE),
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
    n <- esp_get_hydrobasin(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})
test_that("Cache vs non-cached", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testhydrobascache")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_hydrobasin(
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
    db_cached <- esp_get_hydrobasin(
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
      "siane/se89_3_hidro_demt_a_x.gpkg",
      "siane/se89_3_hidro_demt_a_y.gpkg"
    )
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("hydrobasin online", {
  expect_snapshot(error = TRUE, esp_get_hydrobasin(epsg = 3367))
  expect_snapshot(error = TRUE, esp_get_hydrobasin(domain = "f"))

  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "test_cuencas")
  unlink(cdir, recursive = TRUE, force = TRUE)

  expect_silent(
    l <- esp_get_hydrobasin(
      resolution = "10",
      epsg = 3857,
      cache_dir = cdir
    )
  )

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(l2 <- esp_get_hydrobasin(resolution = "6.5", cache_dir = cdir))

  expect_s3_class(l2, "sf")
  expect_s3_class(l2, "tbl_df")
  expect_lt(object.size(l), object.size(l2))

  expect_silent(
    l <- esp_get_hydrobasin(
      domain = "landsea",
      resolution = "10",
      epsg = 3857,
      cache_dir = cdir
    )
  )

  expect_true(sf::st_crs(l) == sf::st_crs(3857))
  expect_silent(
    l2 <- esp_get_hydrobasin(
      resolution = "6.5",
      domain = "landsea",
      cache_dir = cdir
    )
  )

  expect_s3_class(l2, "sf")
  expect_s3_class(l2, "tbl_df")
  expect_lt(object.size(l), object.size(l2))

  unlink(cdir)
})
