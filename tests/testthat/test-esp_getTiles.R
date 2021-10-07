test_that("tiles online", {
  poly <- esp_get_ccaa("La Rioja")
  expect_error(esp_getTiles(poly, type = "FFF"))

  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_if_offline()


  expect_s4_class(esp_getTiles(poly), "RasterBrick")
  expect_message(esp_getTiles(poly,
    zoom = 5, verbose = TRUE,
    update_cache = TRUE
  ))

  # From cache
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


  # Try with jpg
  provs <- leaflet.providersESP.df
  jpeg <- provs[provs$value == "jpeg", ]

  expect_message(esp_getTiles(poly,
    type = jpeg$provider,
    verbose = TRUE
  ))

  s <- esp_getTiles(poly,
    type = jpeg$provider
  )

  expect_s4_class(s, "RasterBrick")
})
