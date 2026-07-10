test_that("Test WMS png", {
  # test with png
  cdir <- file.path(tempdir(), "test_png2")

  save_png <- function(code, width = 256, height = 256) {
    path <- tempfile(fileext = ".png")
    png(path, width = width, height = height)
    on.exit(dev.off())
    terra::plotRGB(code, axes = TRUE, mar = c(1, 1, 1, 1))

    path
  }

  all_int <- mapSpain::esp_tiles_providers
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

  all_n <- all_n[!all_n %in% has_min_zoom]

  galicia <- esp_get_ccaa_siane(ccaa = "Galicia", epsg = 3857, cache_dir = cdir)
  fails <- c(NULL)

  for (n in all_n) {
    tile <- try(
      esp_get_tiles(galicia, type = n, cache_dir = cdir),
      silent = TRUE
    )
    if (!inherits(tile, "try-error")) {
      expect_type(ensure_null(terra::crs(tile)), "character")

      expect_snapshot_file(save_png(tile), paste0(n, ".png"))
    } else {
      fails <- c(fails, n)
    }
  }
  expect_snapshot(fails)
  unlink(cdir, force = TRUE, recursive = TRUE)
})
