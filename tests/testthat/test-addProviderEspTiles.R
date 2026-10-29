test_that("addProviderEspTiles() validates providers and adds leaflet tiles", {
  skip_on_cran()

  withr::local_package("leaflet")

  expect_snapshot(
    error = TRUE,
    # jarl-ignore nested_pipe: Pipe is intentionally captured by testthat
    puertadelsol <- leaflet() |>
      setView(lat = 40.4166, lng = -3.7038400, zoom = 18) |>
      addProviderEspTiles(provider = "TESTING")
  )

  expect_silent(
    # jarl-ignore nested_pipe: Pipe is intentionally captured by testthat
    puertadelsol <- leaflet() |>
      setView(lat = 40.4166, lng = -3.7038400, zoom = 18) |>
      addProviderEspTiles(provider = "IDErioja.Claro") |>
      addProviderEspTiles(provider = "RedTransporte.Carreteras")
  )
  expect_s3_class(puertadelsol, "leaflet")
})

test_that("new historical imagery and maps use their WMS and WMTS layers", {
  map <- addProviderEspTiles(leaflet::leaflet(), "PNOAHistorico.PNOA2024")
  call <- map$x$calls[[1]]
  expect_identical(call$method, "addWMSTiles")
  expect_identical(call$args[[4]]$layers, "PNOA2024")

  map <- addProviderEspTiles(leaflet::leaflet(), "MTNHistorico.MTN25")
  call <- map$x$calls[[1]]
  expect_identical(call$method, "addTiles")
  expect_match(call$args[[1]], "layer=mtn25-edicion1", fixed = TRUE)
  expect_equal(call$args[[4]]$maxNativeZoom, 19)
})

test_that("updated providers preserve native zoom limits and geographic CRS", {
  map <- addProviderEspTiles(leaflet::leaflet(), "IGNBase.Simplificado")
  call <- map$x$calls[[1]]
  expect_match(call$args[[1]], "layer=IGNBaseSimplificado", fixed = TRUE)
  expect_equal(call$args[[4]]$maxNativeZoom, 20)

  map <- addProviderEspTiles(leaflet::leaflet(), "Copernicus.ForestLeaf")
  call <- map$x$calls[[1]]
  expect_match(call$args[[1]], "discomap.eea.europa.eu", fixed = TRUE)
  expect_identical(call$args[[4]]$crs$crsClass, "L.CRS.EPSG4326")
  expect_identical(call$args[[4]]$version, "1.3.0")
})
