test_that("Read shp", {
  skip_on_cran()
  skip_if_offline()

  cdir <- file.path(tempdir(), "testthat_ex")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  url <- paste0(
    "https://esdac.jrc.ec.europa.eu/Library/Reference_Grids/",
    "Grids/grids_for_single_eu25_countries_etrs_laea_10k.zip"
  )

  fake_local <- download_url(
    url,
    basename(url),
    cdir,
    "fake",
    update_cache = FALSE,
    verbose = FALSE
  )
  s_test <- read_geo_file_sf(fake_local)

  # Different from
  s <- read_geo_file_sf(fake_local, shp_hint = "spain")
  expect_false(nrow(s) == nrow(s_test))

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_true(file.exists(fake_local))

  # Bad hint
  expect_snapshot(
    error = TRUE,
    read_geo_file_sf(fake_local, shp_hint = "fake"),
    transform = function(x) {
      gsub(fake_local, "<path>", x, fixed = TRUE)
    }
  )

  unlink(cdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(cdir))
})

test_that("Read gpkg", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testthat_ex")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/refs/heads/",
    "sianedata/dist/se89_10_admin_ccaa_a_x.gpkg"
  )

  fake_local <- download_url(
    url,
    basename(url),
    cdir,
    "fake",
    update_cache = FALSE,
    verbose = FALSE
  )

  expect_null(get_col_name(fake_local, c("a_non_existing_col")))
  nms1 <- get_col_name(fake_local, c("ccaa", "id_ccaa"))
  expect_identical(nms1, "id_ccaa")
  nm <- get_geo_file_colnames(fake_local)
  expect_true("geometry" %in% nm)
  expect_true("id_ccaa" %in% nm)
  s <- read_geo_file_sf(fake_local)

  expect_s3_class(s, "sf")
  expect_s3_class(s, "tbl_df")
  expect_true(file.exists(fake_local))

  ly <- get_sf_layer_name(fake_local)
  # With query
  sq <- read_geo_file_sf(
    fake_local,
    q = "SELECT * from \"se89_10_admin_ccaa_a_x\" LIMIT 1"
  )
  expect_equal(
    sf::st_drop_geometry(sq),
    sf::st_drop_geometry(s[1, ])
  )

  unlink(cdir, recursive = TRUE, force = TRUE)
  expect_false(dir.exists(cdir))
})

test_that("NULLs and no CRS", {
  skip_on_cran()
  skip_if_siane_offline()

  expect_null(read_geo_file_sf(NULL))

  a_sf <- mapSpain::esp_nuts_2024[1, ]
  no_crs <- sf::st_set_crs(a_sf, NA)

  expect_false(identical(sf::st_crs(a_sf), sf::st_crs(no_crs)))

  expect_no_error(sanitize_sf(no_crs))
})
