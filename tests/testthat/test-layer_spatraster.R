test_that("Test layers", {

  # Test with sf

  x <- esp_get_ccaa("Catalonia")

  expect_s3_class(x, "sf")
  expect_error(layer_spatraster(x))

  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggspatial")
  skip_if_not_installed("raster")
  skip_if_not_installed("slippymath")
  skip_if_not_installed("terra")
  skip_if_not_installed("png")

  skip_on_cran()
  skip_if_offline()

  tile <- esp_getTiles(x)


  expect_silent(layer_spatraster(tile))

  g <- ggplot2::ggplot() +
    layer_spatraster(tile)


  expect_s3_class(g, "ggplot")
  t <- tempfile(fileext = ".png")

  # Run only locally
  skip_on_ci()

  suppressWarnings(ggplot2::ggsave(t, g,
    width = 3, height = 3,
    dpi = 90
  ))
  expect_snapshot_file(t, "layer_spatraster.png")
})
