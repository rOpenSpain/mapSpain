test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()

  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_countries_siane(update_cache = TRUE),
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
    n <- esp_get_countries_siane(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
})


test_that("Cache vs non-cached", {
  skip_on_cran()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "testcountry")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_countries_siane(
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
    db_cached <- esp_get_countries_siane(
      cache = TRUE,
      cache_dir = cdir
    )
  )

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    "siane/ww84_60_admin_pais_a.gpkg"
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})
test_that("Filter countries", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testcountry")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  db_cached <- esp_get_countries_siane(country = "Italy", cache_dir = cdir)

  expect_identical(db_cached$id_iso3, "ITA")
  expect_s3_class(db_cached, "sf")
  expect_s3_class(db_cached, "tbl_df")

  # Combine with cnt
  db_cached_full <- esp_get_countries_siane(
    country = c("Spain", "Angola", "Japan"),
    cache_dir = cdir
  )
  expect_identical(nrow(db_cached_full), 3L)
  expect_identical(
    db_cached_full$id_iso3,
    convert_country_code(c("Angola", "Japan", "Spain"), "iso3c")
  )

  # Not cached
  db_no_cached_full <- esp_get_countries_siane(
    country = c("Spain", "Angola", "Japan"),
    cache_dir = cdir,
    cache = FALSE
  )
  expect_identical(db_cached_full, db_no_cached_full)

  # NULL
  expect_snapshot(
    db_null <- esp_get_countries_siane(
      country = "greenland",
      cache_dir = cdir
    )
  )

  expect_true(nrow(db_null) == 0)
  expect_s3_class(db_null, "sf")
  expect_s3_class(db_null, "tbl_df")

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})
