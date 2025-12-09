test_that("Custom WMTS provider", {
  skip_if_not_installed("terra")
  skip_if_not_installed("png")

  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_if_offline()

  segovia <- esp_get_prov("segovia", epsg = 3857)
  custom_wmts <- esp_make_provider(
    id = "wmts_test",
    q = "https://www.ign.es/wmts/ign-base?",
    service = "WMTS",
    layer = "IGNBaseTodo-nofondo"
  )

  tile <- esp_getTiles(segovia, type = custom_wmts)
  expect_s4_class(tile, "SpatRaster")
})

test_that("Custom WMS provider", {
  skip_if_not_installed("terra")
  skip_if_not_installed("png")

  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_if_offline()
  segovia <- esp_get_prov("segovia", epsg = 3857)

  custom_wms_11 <- esp_make_provider(
    id = "wms_1.1",
    q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
    service = "WMS",
    version = "1.1.1",
    crs = "EPSG:25830",
    layers = "geolog_cyl_litologia"
  )

  custom_wms_13 <- esp_make_provider(
    id = "wms_1.3",
    q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
    service = "WMS",
    version = "1.3.0",
    crs = "EPSG:25830",
    layers = "geolog_cyl_litologia"
  )

  # Both works

  tilewms1 <- esp_getTiles(segovia, custom_wms_11, cache_dir = tempdir())
  expect_s4_class(tilewms1, "SpatRaster")
  tilewms13 <- esp_getTiles(segovia, custom_wms_13, cache_dir = tempdir())
  expect_s4_class(tilewms13, "SpatRaster")
})
