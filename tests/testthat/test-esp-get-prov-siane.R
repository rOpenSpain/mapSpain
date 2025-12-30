test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_prov_siane(update_cache = TRUE, verbose = FALSE),
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
    n <- esp_get_prov_siane(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
})

test_that("Cache vs non-cached", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- file.path(tempdir(), "testprov")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_identical(
    list.files(cdir, recursive = TRUE),
    character(0)
  )
  expect_message(
    db_online <- esp_get_prov_siane(
      cache = FALSE,
      verbose = TRUE,
      resolution = 10,
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
    db_cached <- esp_get_prov_siane(
      cache = TRUE,
      resolution = 10,
      cache_dir = cdir
    )
  )

  expect_identical(db_online, db_cached)
  expect_s3_class(db_online, "sf")
  expect_s3_class(db_online, "tbl_df")
  expect_identical(
    list.files(cdir, recursive = TRUE),
    c(
      "siane/se89_10_admin_prov_a_x.gpkg",
      "siane/se89_10_admin_prov_a_y.gpkg"
    )
  )

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})

# Test siane
test_that("prov online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  cdir <- file.path(tempdir(), "testcapimun")
  if (dir.exists(cdir)) {
    unlink(cdir, recursive = TRUE, force = TRUE)
  }

  expect_error(esp_get_prov_siane(epsg = "FFF", cache_dir = cdir))

  expect_silent(esp_get_prov_siane(cache_dir = cdir))

  expect_message(esp_get_prov_siane(
    cache = FALSE,
    resolution = 10,
    verbose = TRUE,
    cache_dir = cdir
  ))

  expect_silent(esp_get_prov_siane("Canarias", cache_dir = cdir))
  expect_silent(esp_get_prov_siane(rawcols = TRUE, cache_dir = cdir))
  expect_silent(esp_get_prov_siane(
    prov = c("Galicia", "ES7", "Centro"),
    cache_dir = cdir
  ))
  expect_error(esp_get_prov_siane(epsg = 39823, cache_dir = cdir))
  expect_silent(esp_get_prov_siane(cache_dir = cdir, resolution = 10, ))
  expect_silent(esp_get_prov_siane(
    moveCAN = c(1, 2),
    resolution = 6.5,
    cache_dir = cdir
  ))
  expect_silent(esp_get_prov_siane(
    prov = c("Galicia", "ES7", "Centro"),
    cache_dir = cdir
  ))
  expect_snapshot(
    error = TRUE,
    esp_get_prov_siane(prov = "Menorca", cache_dir = cdir)
  )
  expect_snapshot(
    error = TRUE,
    esp_get_prov_siane(
      prov = "ES6x",
      cache_dir = cdir
    )
  )

  expect_equal(
    sf::st_crs(esp_get_prov_siane(epsg = 3035, cache_dir = cdir)),
    sf::st_crs(3035)
  )

  expect_equal(
    sf::st_crs(esp_get_prov_siane(epsg = 3857, cache_dir = cdir)),
    sf::st_crs(3857)
  )

  # Test all

  f <- mapSpain::esp_codelist

  n <- esp_get_prov_siane(prov = f$nuts1.code, cache_dir = cdir)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = "Melilla", cache_dir = cdir)
  expect_equal(nrow(n), 1)

  n <- esp_get_prov_siane(prov = f$nuts1.name.alt, cache_dir = cdir)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$iso2.prov.code, cache_dir = cdir)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$nuts2.code, cache_dir = cdir)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$nuts2.name, cache_dir = cdir)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$cpro, cache_dir = cdir)
  expect_equal(nrow(n), 52)

  expect_snapshot(
    n <- esp_get_prov_siane(prov = f$nuts3.code, cache_dir = cdir)
  )
  expect_equal(nrow(n), 49)

  # Cleanup
  unlink(cdir, recursive = TRUE, force = TRUE)
})
