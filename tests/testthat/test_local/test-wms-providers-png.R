test_that("WMS providers with high minimum zoom render expected tiles", {
  # test with png, only with minzoom

  cdir <- file.path(tempdir(), "test_png1")
  save_png <- function(code, width = 256, height = 256) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    terra::plotRGB(code, axes = TRUE, mar = c(1, 1, 1, 1))

    path
  }

  all_int <- mapSpain::esp_tiles_providers

  all_n <- names(all_int)

  has_min_zoom <- vapply(
    all_int,
    function(x) {
      if (is.null(x$leaflet$minZoom)) {
        return(FALSE)
      }

      z <- as.integer(x$leaflet$minZoom)

      z > 9
    },
    FUN.VALUE = logical(1)
  )

  has_min_zoom <- names(has_min_zoom[has_min_zoom])

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

  all_n <- all_n[all_n %in% has_min_zoom]

  santiago <- esp_get_capimun(munic = "Santiago de Compostela", epsg = 3857)
  santiago <- santiago |> sf::st_buffer(dist = 1000)

  fails <- c(NULL)
  for (n in all_n) {
    tile <- try(
      esp_get_tiles(santiago, type = n, cache_dir = cdir),
      silent = TRUE
    )
    if (inherits(tile, "try-error")) {
      fails <- c(fails, n)
    } else {
      expect_type(ensure_null(terra::crs(tile)), "character")
      expect_snapshot_file(save_png(tile), paste0(n, ".png"))
    }
  }
  expect_snapshot(fails)
  unlink(cdir, force = TRUE, recursive = TRUE)
})
