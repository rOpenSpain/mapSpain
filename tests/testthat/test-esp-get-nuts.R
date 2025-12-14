test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_nuts(update_cache = TRUE, verbose = TRUE),
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
    n <- esp_get_capimun(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})

test_that("Test local NUTS", {
  expect_silent(esp_get_nuts())
  expect_silent(esp_get_nuts(resolution = 1))
  expect_silent(esp_get_nuts(nuts_level = 2, moveCAN = FALSE))
  expect_silent(esp_get_nuts(nuts_level = 2, moveCAN = c(2, 2)))

  expect_silent(esp_get_nuts(region = c("ES-AN", "ES-PV", "ES-P")))

  expect_silent(esp_get_nuts(region = "Leon"))
  expect_silent(esp_get_nuts(region = "Canarias"))
  expect_silent(esp_get_nuts(region = "ES1"))
  expect_message(esp_get_nuts(verbose = TRUE))
  expect_error(esp_get_nuts(resolution = 32))
  expect_error(esp_get_nuts(spatialtype = "XX"))
  expect_error(esp_get_nuts(nuts_level = "XX"))

  # Check all nuts codes
  a <- unique(c(
    esp_codelist$nuts1.code,
    esp_codelist$nuts2.code,
    esp_codelist$nuts3.code
  ))

  l1 <- unique(esp_codelist$nuts1.code)
  ff <- esp_get_nuts(region = l1)
  expect_equal(length(l1), nrow(ff))

  l1 <- unique(esp_codelist$nuts2.code)
  ff <- esp_get_nuts(region = l1)
  expect_equal(length(l1), nrow(ff))

  l1 <- unique(esp_codelist$nuts3.code)
  ff <- esp_get_nuts(region = l1)
  expect_equal(length(l1), nrow(ff))

  # Check all iso codes
  b <- unique(c(
    esp_codelist$iso2.ccaa.code,
    esp_codelist$iso2.prov.code
  ))
  expect_warning(esp_get_nuts(region = b))

  # Check names

  expect_silent(esp_get_nuts(region = esp_codelist$nuts1.name))
  expect_silent(esp_get_nuts(region = esp_codelist$nuts2.name))
  expect_silent(esp_get_nuts(region = esp_codelist$nuts3.name))
  expect_silent(esp_get_nuts(resolution = "20"))
})

test_that("Valid inputs", {
  skip_on_cran()
  skip_if_gisco_offline()

  # validate ext
  expect_snapshot(esp_get_nuts(ext = "docx"), error = TRUE)

  # validate level
  expect_snapshot(esp_get_nuts(nuts_level = "docx"), error = TRUE)

  # But rest of levels should work
  all <- esp_get_nuts(nuts_level = "all")
  l1 <- esp_get_nuts(nuts_level = "1")
  l2 <- esp_get_nuts(nuts_level = "2")
  l3 <- esp_get_nuts(nuts_level = "3")
  expect_identical(
    nrow(all[all$LEVL_CODE == 1, ]),
    nrow(l1)
  )

  expect_identical(
    nrow(all[all$LEVL_CODE == 2, ]),
    nrow(l2)
  )

  expect_identical(
    nrow(all[all$LEVL_CODE == 3, ]),
    nrow(l3)
  )
})

test_that("Cached dataset vs updated", {
  skip_on_cran()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "testnuts")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_snapshot(db_cached <- esp_get_nuts(verbose = TRUE, region = "Murcia"))

  # In some levels should also filter from cache
  db_cached_l1 <- esp_get_nuts(nuts_level = 1)
  db_cached_l2 <- esp_get_nuts(nuts_level = 2)
  db_cached_l3 <- esp_get_nuts(nuts_level = 3)
  expect_true(
    all(db_cached_l1$LEVL_CODE == 1)
  )
  expect_true(
    all(db_cached_l2$LEVL_CODE == 2)
  )

  expect_true(
    all(db_cached_l3$LEVL_CODE == 3)
  )
  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  # Force download

  db_cached2 <- esp_get_nuts(
    update_cache = TRUE,
    cache_dir = cdir,
    region = "Murcia"
  )

  expect_s3_class(db_cached2, "sf")
  expect_s3_class(db_cached2, "tbl_df")

  expect_identical(
    list.files(cdir, recursive = TRUE),
    "nuts/NUTS_RG_01M_2024_4326.gpkg"
  )

  expect_identical(db_cached$NUTS_ID, db_cached2$NUTS_ID)
  expect_true("geo" %in% names(db_cached))
  expect_true("geo" %in% names(db_cached2))
  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})
test_that("Spatial types", {
  skip_on_cran()
  skip_if_gisco_offline()

  # LB
  lb <- esp_get_nuts(spatialtype = "LB")
  expect_true(unique(sf::st_geometry_type(lb)) == "POINT") # Can filter
  expect_true("CNTR_CODE" %in% names(lb))
  lb_filter <- esp_get_nuts(spatialtype = "LB", region = "Segovia")
  expect_true(all(lb_filter$NUTS_ID == "ES416"))

  # BN
  expect_snapshot(
    error = TRUE,
    bn <- esp_get_nuts(spatialtype = "BN", resolution = "60")
  )
})

test_that("Extensions", {
  skip_on_cran()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "testnuts")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )

  db_geojson <- esp_get_nuts(
    resolution = "60",
    cache_dir = cdir,
    nuts_level = 0,
    ext = "geojson"
  )
  expect_s3_class(db_geojson, "sf")
  expect_s3_class(db_geojson, "tbl_df")

  expect_length(
    list.files(cdir, recursive = TRUE, pattern = "geojson"),
    1
  )

  db_zip <- esp_get_nuts(
    resolution = "60",
    nuts_level = 0,
    cache_dir = cdir,
    verbose = TRUE,
    ext = "shp"
  )

  expect_s3_class(db_zip, "sf")
  expect_s3_class(db_zip, "tbl_df")

  expect_length(
    list.files(cdir, recursive = TRUE, pattern = "shp.zip"),
    1
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("Test NUTS online", {
  skip_on_cran()
  skip_if_gisco_offline()
  cdir <- file.path(tempdir(), "testnuts")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }
  expect_silent(a1 <- esp_get_nuts(resolution = "60", year = 2021))
  expect_silent(a2 <- esp_get_nuts(resolution = "60", year = 2016))
  expect_s3_class(a1, "sf")
  expect_s3_class(a1, "tbl_df")
  expect_s3_class(a2, "sf")
  expect_s3_class(a2, "tbl_df")
  unlink(cdir, recursive = TRUE, force = TRUE)
})
