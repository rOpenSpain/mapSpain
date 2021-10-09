test_that("tiles error", {
  skip_if_not_installed("terra")


  df <- data.frame(a = 1, b = 2)

  expect_error(esp_getTiles(df), "Only sf objects allowed")

  # Try with geom
  poly <- esp_get_ccaa("La Rioja")
  geom <- sf::st_geometry(poly)

  expect_error(esp_getTiles(geom), "Only sf objects allowed")
})


test_that("tiles online", {
  skip_if_not_installed("terra")


  poly <- esp_get_ccaa("La Rioja")
  expect_error(esp_getTiles(poly, type = "FFF"))


  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_if_offline()


  save_png <- function(code, width = 400, height = 400) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    code

    path
  }
  expect_s4_class(esp_getTiles(poly), "SpatRaster")
  expect_message(esp_getTiles(poly,
    zoom = 5, verbose = TRUE,
    update_cache = TRUE
  ))



  s <- esp_getTiles(poly)


  expect_snapshot_file(save_png(
    terra::plotRGB(s)
  ), "silent.png")

  # From cache
  expect_message(esp_getTiles(poly, zoom = 5, verbose = TRUE))
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

  expect_message(esp_getTiles(point,
    type = "RedTransporte.Carreteras",
    verbose = TRUE
  ))

  p <- esp_getTiles(point,
    type = "RedTransporte.Carreteras"
  )

  expect_snapshot_file(
    save_png(terra::plotRGB(p)),
    "point.png"
  )

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
    type = as.character(jpeg$provider[1]),
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




  expect_snapshot_file(save_png(
    terra::plotRGB(n)
  ), "transp.png")
  expect_equal(terra::nlyr(n), 4)

  opaque <- expect_silent(esp_getTiles(poly,
    type = "RedTransporte.Carreteras",
    transparent = FALSE
  ))
  expect_snapshot_file(save_png(
    terra::plotRGB(opaque)
  ), "opaque.png")
  expect_equal(terra::nlyr(opaque), 3)
})
