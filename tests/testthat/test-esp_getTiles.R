test_that("tiles online", {
  poly <- esp_get_ccaa("La Rioja")
  expect_error(esp_getTiles(poly, type = "FFF"))

  skip_on_cran()
  skip_if_offline()

  # Skip test as tiles sometimes are not available

  expect_true("RasterBrick" %in% class(esp_getTiles(poly)))
  expect_message(esp_getTiles(poly, zoom = 5, verbose = TRUE))
  expect_message(esp_getTiles(sf::st_geometry(poly), verbose = TRUE))
  expect_message(esp_getTiles(poly, verbose = TRUE))
  expect_message(esp_getTiles(
    poly,
    zoom = 2,
    verbose = TRUE,
    type = "IGNBase.Orto"
  ))

  # Single point
  point <- esp_get_ccaa("Madrid")
  point <- sf::st_transform(point, 3857)
  point <- sf::st_sample(point, 1)

  expect_message(esp_getTiles(point,
    type = "RedTransporte.Carreteras",
    verbose = TRUE
  ))
  expect_message(esp_getTiles(poly,
    type = "RedTransporte.Carreteras",
    verbose = TRUE, mask = TRUE
  ))
  expect_message(esp_getTiles(poly,
    type = "RedTransporte.Carreteras",
    verbose = TRUE, mask = TRUE
  ))
})
