test_that("Test Mapbox", {
  # Skip if not API KEY
  apikey <- Sys.getenv("MAPBOX_API_KEY", "")
  if (apikey == "") {
    skip("Need a MapBox API KEY")
  }

  # test with png
  cdir <- file.path(tempdir(), "test_ext")

  save_png <- function(code, width = 256, height = 256) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    terra::plotRGB(code, axes = TRUE, mar = c(1, 1, 1, 1))

    path
  }

  x <- c(-410596.53, 4923242.45) |>
    sf::st_point() |>
    sf::st_sfc(crs = 3857) |>
    sf::st_buffer(dist = 400)

  #   Mapbox

  mapbox <- list(
    id = "MadridMapBoxPrint",
    q = paste0(
      "https://api.mapbox.com/styles/v1/dieghernan/cmkb8xgfb004601r16nw13j5x/",
      "tiles/{z}/{x}/{y}?access_token=",
      apikey
    )
  )
  tile <- esp_get_tiles(x, mapbox, cache_dir = cdir)

  expect_snapshot_file(save_png(tile), "mapbox.png")

  unlink(cdir, force = TRUE, recursive = TRUE)
})

test_that("Test Thunderforest", {
  # Skip if not API KEY
  apikey <- Sys.getenv("THUNDERFOREST_API_KEY", "")
  if (apikey == "") {
    skip("Need a ThunderForest API KEY")
  }

  # test with png
  cdir <- file.path(tempdir(), "test_ext")

  save_png <- function(code, width = 256, height = 256) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    terra::plotRGB(code, axes = TRUE, mar = c(1, 1, 1, 1))

    path
  }

  x <- c(-410596.53, 4923242.45) |>
    sf::st_point() |>
    sf::st_sfc(crs = 3857) |>
    sf::st_buffer(dist = 400)

  #   Thunder
  thunder <- list(
    id = "ThunderForest",
    q = paste0(
      "https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=",
      apikey
    )
  )

  tile <- esp_get_tiles(x, thunder, cache_dir = cdir)

  expect_snapshot_file(save_png(tile), "thunder.png")

  unlink(cdir, force = TRUE, recursive = TRUE)
})


test_that("Test OSM", {
  # test with png
  cdir <- file.path(tempdir(), "test_ext")

  save_png <- function(code, width = 256, height = 256) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    terra::plotRGB(code, axes = TRUE, mar = c(1, 1, 1, 1))

    path
  }

  x <- c(-410596.53, 4923242.45) |>
    sf::st_point() |>
    sf::st_sfc(crs = 3857) |>
    sf::st_buffer(dist = 400)

  # OSM
  osm_spec <- list(
    id = "OSM",
    q = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
  )

  tile <- esp_get_tiles(x, osm_spec, cache_dir = cdir)

  expect_snapshot_file(save_png(tile), "osm.png")

  unlink(cdir, force = TRUE, recursive = TRUE)
})
