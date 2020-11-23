library(tinytest)
library(sf)

poly <- esp_get_ccaa("La Rioja")
expect_error(esp_getTiles(poly, type = "FFF"))



library(giscoR)
if (gisco_check_access()) {
  expect_message(esp_getTiles(poly, zoom = 5, verbose = TRUE))
  expect_message(esp_getTiles(st_geometry(poly), verbose = TRUE))
  expect_message(esp_getTiles(st_geometry(poly), verbose = TRUE))
  expect_message(esp_getTiles(
    poly,
    zoom = 2,
    verbose = TRUE,
    type = "IGNBase.Orto"
  ))

  # Single point
  point <- esp_get_ccaa("Madrid", spatialtype = "LB")

  expect_message(esp_getTiles(point, type = "RedTransporte.Carreteras",
                             verbose = TRUE))
  expect_message(esp_getTiles(st_geometry(point),
                             type = "RedTransporte.Carreteras",
                             verbose = TRUE))


}
