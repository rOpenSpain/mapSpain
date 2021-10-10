test_that("tiles error", {
  skip_if_not_installed("terra")


  df <- data.frame(a = 1, b = 2)

  expect_error(esp_getTiles(df), "Only sf and sfc objects allowed")
})


test_that("tiles online", {
  skip_if_not_installed("slippymath")
  skip_if_not_installed("terra")
  skip_if_not_installed("png")


  poly <- esp_get_ccaa("La Rioja")
  expect_error(esp_getTiles(poly, type = "FFF"))


  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_if_offline()

  png

  save_png <- function(code, width = 200, height = 200) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    terra::plotRGB(code)

    path
  }
  expect_s4_class(esp_getTiles(poly), "SpatRaster")
  expect_message(esp_getTiles(poly,
    zoom = 5, verbose = TRUE,
    update_cache = TRUE
  ))


  s <- esp_getTiles(poly)


  # With sfc
  geom <- sf::st_geometry(poly)

  # Convert from bbox

  bbox <- sf::st_bbox(poly)
  expect_error(esp_getTiles(bbox))
  expect_silent(esp_getTiles(sf::st_as_sfc(bbox)))

  frombbox <- esp_getTiles(sf::st_as_sfc(bbox))

  expect_s3_class(geom, "sfc")

  expect_silent(esp_getTiles(geom))

  sfc <- esp_getTiles(geom)

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

  point <- sf::st_centroid(
    sf::st_geometry(point),
    of_largest_polygon = TRUE
  )

  expect_length(point, 1)
  expect_s3_class(point, "sfc_POINT")

  expect_message(esp_getTiles(point,
    verbose = TRUE
  ))

  p <- esp_getTiles(point, verbose = TRUE)



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


  expect_equal(terra::nlyr(n), 4)

  opaque <- expect_silent(esp_getTiles(poly,
    type = "RedTransporte.Carreteras",
    transparent = FALSE
  ))

  expect_equal(terra::nlyr(opaque), 3)

  # Run only locally
  skip_on_ci()

  expect_snapshot_file(save_png(opaque), "opaque.png")
  expect_snapshot_file(save_png(n), "transp.png")
  expect_snapshot_file(save_png(s), "silent.png")
  expect_snapshot_file(save_png(p), "point.png")
  expect_snapshot_file(save_png(sfc), "sfc.png")
  expect_snapshot_file(save_png(frombbox), "frombbox.png")
})
