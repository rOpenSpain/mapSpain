test_that("Errors", {
  teide <- data.frame(
    name = "Teide Peak",
    lon = -16.6437593,
    lat = 28.2722883
  )

  expect_snapshot(error = TRUE, esp_move_can(teide))
})

test_that("sfc", {
  teide <- data.frame(
    name = rep("test", 20),
    lon = seq(-16.1, -15.8, length.out = 20),
    lat = seq(28.2, 29, length.out = 20)
  )

  teide_sf <- sf::st_as_sf(teide, coords = c("lon", "lat"), crs = 4326)

  teide_sfc <- sf::st_geometry(teide_sf)

  # Do nothing
  moved <- esp_move_can(teide_sfc, moveCAN = FALSE)
  expect_identical(moved, teide_sfc)

  # Moved
  moved2 <- esp_move_can(teide_sfc, moveCAN = TRUE)
  expect_identical(length(moved2), length(teide_sfc))
  expect_identical(sf::st_crs(moved2), sf::st_crs(teide_sfc))

  # Moved with another CRS
  teide_sfc_3857 <- sf::st_transform(teide_sfc, 3857)
  moved3 <- esp_move_can(teide_sfc_3857, moveCAN = TRUE)
  expect_identical(length(moved3), length(teide_sfc))
  expect_identical(sf::st_crs(moved3), sf::st_crs(teide_sfc_3857))

  # Check movs

  # Avoid errors due to changes in precision across GDAL versions
  skip_on_cran()

  a1 <- sf::st_geometry(moved3[1]) - sf::st_geometry(teide_sfc_3857[1])
  mat <- sf::st_coordinates(a1)

  # Default mov in 3857
  expect_identical(
    as.data.frame(mat),
    data.frame(X = 550000, Y = 920000)
  )

  # Mov with params

  moved4 <- esp_move_can(teide_sfc, moveCAN = c(5, 10))

  a2 <- sf::st_geometry(moved4) - sf::st_geometry(teide_sfc)
  mat2 <- sf::st_coordinates(a2)

  expect_equal(sort(unique(as.integer(mat2))), c(9L, 14L))
})


test_that("sf", {
  teide <- data.frame(
    name = rep("test", 20),
    lon = seq(-16.1, -15.8, length.out = 20),
    lat = seq(28.2, 29, length.out = 20)
  )

  teide_sf <- sf::st_as_sf(teide, coords = c("lon", "lat"), crs = 4326)

  # Col with other name
  teide_sf2 <- sf::st_sf(
    sf::st_drop_geometry(teide_sf),
    mygeomcol = sf::st_geometry(teide_sf)
  )
  # Do nothing
  moved <- esp_move_can(teide_sf, moveCAN = FALSE)
  expect_identical(moved, teide_sf)

  moved_n <- esp_move_can(teide_sf2, moveCAN = FALSE)
  expect_identical(moved_n, teide_sf2)

  expect_true(all(sf::st_is_valid(moved_n)))

  # Moved
  moved2 <- esp_move_can(teide_sf, moveCAN = TRUE)

  expect_identical(nrow(moved2), nrow(teide_sf))
  expect_identical(sf::st_crs(moved2), sf::st_crs(teide_sf))

  # Moved with another CRS
  teide_sf_3857 <- sf::st_transform(teide_sf2, 3857)
  moved3 <- esp_move_can(teide_sf_3857, moveCAN = TRUE)
  expect_identical(nrow(moved3), nrow(teide_sf2))
  expect_identical(sf::st_crs(moved3), sf::st_crs(teide_sf_3857))
  expect_identical(names(moved3), names(teide_sf_3857))

  expect_true(all(sf::st_is_valid(moved3)))
})


test_that("Empty", {
  teide <- data.frame(
    name = rep("test", 20),
    lon = seq(-16.1, -15.8, length.out = 20),
    lat = seq(28.2, 29, length.out = 20)
  )

  teide_sf <- sf::st_as_sf(teide, coords = c("lon", "lat"), crs = 4326)
  teide_null <- teide_sf[teide_sf$name != "test", ]
  expect_equal(nrow(teide_null), 0)
  expect_identical(teide_null, esp_move_can(teide_null, moveCAN = TRUE))

  # sfc
  teide_null_sfc <- sf::st_geometry(teide_null)
  expect_equal(length(teide_null_sfc), 0)
  expect_identical(teide_null_sfc, esp_move_can(teide_null_sfc, moveCAN = TRUE))
})
