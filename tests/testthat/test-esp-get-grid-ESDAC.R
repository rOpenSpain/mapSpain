test_that("esp_get_grid_ESDAC() returns NULL while offline", {
  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  expect_message(
    n <- esp_get_grid_ESDAC(update_cache = TRUE),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_get_grid_ESDAC() returns NULL for HTTP 404 responses", {
  local_mocked_bindings(
    is_online_fun = function(...) TRUE,
    esp_req_perform = function(req, ...) {
      httr2::response(status_code = 404, url = req$url)
    }
  )
  cdir <- withr::local_tempdir()
  expect_message(
    result <- esp_get_grid_ESDAC(update_cache = TRUE, cache_dir = cdir),
    "HTTP error 404"
  )
  expect_null(result)
})

test_that("esp_get_grid_ESDAC() rejects invalid resolutions", {
  expect_snapshot(error = TRUE, esp_get_grid_ESDAC("50"))
})

test_that("esp_get_grid_ESDAC() reads Spain from the 10 km download", {
  local_mocked_bindings(download_url = function(url, ...) {
    expect_identical(
      url,
      paste0(
        "https://esdac.jrc.ec.europa.eu/Library/Reference_Grids/",
        "Grids/grids_for_single_eu25_countries_etrs_laea_10k.zip"
      )
    )
    normalizePath(test_path("fixtures", "shapes.zip"), winslash = "/")
  })

  grid10 <- esp_get_grid_ESDAC(resolution = 10)
  expect_s3_class(grid10, "sf")
  expect_s3_class(grid10, "tbl_df")
  expect_equal(grid10$id, 1:2)
  expect_equal(sf::st_crs(grid10)$epsg, 3035L)
})

test_that("esp_get_grid_ESDAC() builds the 1 km download request", {
  local_mocked_bindings(download_and_read_geo_file = function(url, ...) {
    expect_snapshot(url)
    NULL
  })

  tdir <- withr::local_tempfile(pattern = "testthat-grid-esdac-")
  tdir <- create_cache_dir(tdir)
  expect_null(esp_get_grid_ESDAC(resolution = 1, cache_dir = tdir))
  unlink(tdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(tdir))
})
