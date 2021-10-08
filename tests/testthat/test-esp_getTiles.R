test_that("tiles error", {
  skip_if_not_installed("terra")


  df <- data.frame(a = 1, b = 2)

  expect_error(esp_getTiles(df), "Only sf and sfc objects allowed")
})


test_that("tiles online", {
  skip_if_not_installed("terra")


  poly <- esp_get_ccaa("La Rioja")
  expect_error(esp_getTiles(poly, type = "FFF"))

  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_if_offline()


  expect_s4_class(esp_getTiles(poly), "SpatRaster")
  expect_message(esp_getTiles(poly,
    zoom = 5, verbose = TRUE,
    update_cache = TRUE
  ))

  # Try with geom
  geom <- sf::st_geometry(poly)

  expect_silent(esp_getTiles(geom))


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

  expect_s4_class(s, "SpatRaster")

  # Check layers
  n <- expect_silent(esp_getTiles(poly,
    type = "RedTransporte.Carreteras"
  ))
  expect_equal(terra::nlyr(n), 4)

  opaque <- expect_silent(esp_getTiles(poly,
    type = "RedTransporte.Carreteras",
    transparent = FALSE
  ))
  expect_equal(terra::nlyr(opaque), 3)
})
