test_that("Test WMS png", {
  # test with png

  cdir <- file.path(tempdir(), "test_png1")
  save_png <- function(code, width = 200, height = 200) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    terra::plotRGB(code, axes = TRUE, mar = c(1, 1, 1, 1))

    path
  }

  all_int <- mapSpain::esp_tiles_providers

  all_n <- names(all_int)

  expect_silent(
    validated <- lapply(all_n, function(nm) {
      static <- all_int[[nm]]$static
      static$id <- nm
      validate_provider(static)
    })
  )
  prov_type <- vapply(validated, guess_provider_type, FUN.VALUE = character(1))
  all_wms <- all_int[prov_type == "WMS"]
  all_n <- names(all_wms)

  santiago <- esp_get_capimun(munic = "Santiago de Compostela", epsg = 3857)
  santiago <- santiago |> sf::st_buffer(dist = 1000)

  for (n in all_n) {
    tile <- try(
      esp_get_tiles(santiago, type = n, cache_dir = cdir),
      silent = TRUE
    )
    if (!inherits(tile, "try-error")) {
      expect_snapshot_file(save_png(tile), paste0(n, ".png"))
    }
  }
  unlink(cdir, force = TRUE, recursive = TRUE)
})
