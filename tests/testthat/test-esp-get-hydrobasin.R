test_that("esp_get_hydrobasin() returns NULL while offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_hydrobasin(update_cache = TRUE, verbose = FALSE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_get_hydrobasin() returns NULL for HTTP 404 responses", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  expect_message(n <- esp_get_hydrobasin(update_cache = TRUE), "HTTP error")
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})
test_that("esp_get_hydrobasin() returns identical cached and uncached data", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- withr::local_tempdir(pattern = "testhydrobascache-")
  expect_identical(list.files(cdir, recursive = TRUE), character(0))
  expect_message(
    db_online <- esp_get_hydrobasin(
      cache = FALSE,
      verbose = TRUE,
      cache_dir = cdir
    ),
    "Reading from"
  )

  expect_identical(list.files(cdir, recursive = TRUE), character(0))

  # vs cache TRUE
  expect_silent(db_cached <- esp_get_hydrobasin(cache = TRUE, cache_dir = cdir))

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    c("siane/se89_3_hidro_demt_a_x.gpkg", "siane/se89_3_hidro_demt_a_y.gpkg")
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_hydrobasin() validates options and returns both domains", {
  expect_snapshot(error = TRUE, esp_get_hydrobasin(epsg = 3367))
  expect_snapshot(error = TRUE, esp_get_hydrobasin(domain = "f"))

  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- withr::local_tempdir(pattern = "test-cuencas-")

  expect_silent(
    l <- esp_get_hydrobasin(resolution = "10", epsg = 3857, cache_dir = cdir)
  )

  expect_equal(sf::st_crs(l), sf::st_crs(3857))
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

  expect_equal(sf::st_crs(l), sf::st_crs(3857))
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
