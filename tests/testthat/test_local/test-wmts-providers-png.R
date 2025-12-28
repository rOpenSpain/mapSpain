test_that("Test WMTS png", {
  # test with png

  cdir <- file.path(tempdir(), "test_png3")
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
  all_wmts <- all_int[prov_type == "WMTS"]
  all_n <- names(all_wmts)

  cala <- esp_get_capimun(munic = "Calahorra", epsg = 3857, region = "La Rioja")
  cala <- cala |> sf::st_buffer(dist = 1000)

  for (n in all_n) {
    tile <- try(
      esp_get_tiles2(cala, type = n, cache_dir = cdir),
      silent = TRUE
    )
    if (!inherits(tile, "try-error")) {
      expect_snapshot_file(save_png(tile), paste0(n, ".png"))
    }
  }
  unlink(cdir, force = TRUE, recursive = TRUE)
})
