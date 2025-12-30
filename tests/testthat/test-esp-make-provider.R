test_that("Custom WMTS provider", {
  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_if_offline()

  custom_wmts <- esp_make_provider(
    id = "wmts_test",
    q = "https://www.ign.es/wmts/ign-base?",
    service = "WMTS",
    layer = "IGNBaseTodo-nofondo"
  )

  # Ignore tilematrixset
  custom_wmts2 <- esp_make_provider(
    id = "wmts_test",
    q = "https://www.ign.es/wmts/ign-base", # No ? at the end
    service = "WMTS",
    layer = "IGNBaseTodo-nofondo",
    tileMatrixSet = "ignored"
  )

  expect_identical(custom_wmts, custom_wmts2)
})

test_that("Custom WMS provider", {
  skip_on_cran()
  skip_if_offline()

  custom_wms_11 <- esp_make_provider(
    id = "wms_1.1",
    q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
    service = "WMS",
    version = "1.1.1",
    crs = "EPSG:25830",
    layers = "geolog_cyl_litologia"
  )

  # In pieces:
  custom_wms_11_pieces <- validate_provider(custom_wms_11)
  expect_null(ensure_null(custom_wms_11_pieces$crs))
  expect_identical(ensure_null(custom_wms_11_pieces$srs), "EPSG:25830")

  custom_wms_13 <- esp_make_provider(
    id = "wms_1.3",
    q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
    service = "WMS",
    version = "1.3.0",
    srs = "EPSG:25830",
    layers = "geolog_cyl_litologia"
  )

  custom_wms_13_pieces <- validate_provider(custom_wms_13)
  expect_null(ensure_null(custom_wms_13_pieces$srs))
  expect_identical(ensure_null(custom_wms_13_pieces$crs), "EPSG:25830")
})
