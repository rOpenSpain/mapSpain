test_that("Validate providers errors", {
  expect_snapshot(error = TRUE, validate_provider(1))
  expect_snapshot(error = TRUE, validate_provider(list(a = 1, q = "2")))
  expect_error(validate_provider("FAKE"), "`type` should be one of")
})

test_that("Validate external", {
  skip_on_cran()
  custom_wms <- esp_make_provider(
    id = "an_id_for_caching",
    q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
    service = "WMS",
    version = "1.3.0",
    format = "image/png",
    layers = "geolog_cyl_litologia"
  )
  expect_silent(res <- validate_provider(custom_wms))
  expect_true(is.list(res))
  expect_true(all(c("id", "q") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMS")
  expect_equal(get_tile_crs(res)$epsg, 3857)

  cartodb_voyager <- list(
    id = "CartoDB_Voyager",
    q = "https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png"
  )
  expect_silent(res <- validate_provider(cartodb_voyager))
  expect_true(is.list(res))
  expect_true(all(c("id", "q") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_equal(get_tile_crs(res)$epsg, 3857)
})

test_that("Validate internal", {
  skip_on_cran()
  # WMTS - Not Inspire style
  expect_silent(res <- validate_provider("IDErioja"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_equal(get_tile_crs(res)$epsg, 3857)

  # WMTS
  expect_silent(res <- validate_provider("PNOA"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution", "tilematrixset") %in% names(res)))
  expect_true("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_equal(get_tile_crs(res)$epsg, 3857)

  # WMS v1.0.0
  expect_silent(res <- validate_provider("Catastro"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution", "srs") %in% names(res)))
  expect_true("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMS")
  expect_true(res$version < "1.3.0")
  expect_equal(get_tile_crs(res)$epsg, 3857)

  # WMS v1.3.0
  expect_silent(res <- validate_provider("ADIF"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution", "crs") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMS")
  expect_true(res$version >= "1.3.0")
  expect_equal(get_tile_crs(res)$epsg, 3857)

  # TODO - Test for modifying with options
  wms_1_0_0 <- esp_make_provider(
    "ADIF1",
    q = "http://ideadif.adif.es/services/wms?",
    service = "WMS",
    version = "1.0.0",
    layers = "TN.RailTransportNetwork.RailwayLink"
  )
})

test_that("Validate all internals", {
  skip_on_cran()

  all_int <- mapSpain::esp_tiles_providers

  all_n <- names(all_int)

  expect_silent(
    validated <- lapply(all_n, function(nm) {
      static <- all_int[[nm]]$static
      static$id <- nm
      validate_provider(static)
    })
  )
  prov_type <- vapply(validated, guess_provider_type, FUN.VALUE = character(1))
  expect_snapshot(unique(prov_type))
  expect_silent(
    in_epsg <- vapply(
      validated,
      function(x) {
        ensure_null(get_tile_crs(x)$input)
      },
      FUN.VALUE = character(1)
    )
  )
  expect_snapshot(unique(in_epsg))
})
