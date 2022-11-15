test_that("Test layers", {
  # Test with sf

  x <- esp_get_ccaa("Catalonia")

  expect_s3_class(x, "sf")
  expect_error(layer_spatraster(x))

  skip_if_not_installed("ggplot2")
  skip_if_not_installed("tidyterra")
  skip_if_not_installed("raster")
  skip_if_not_installed("slippymath")
  skip_if_not_installed("terra")
  skip_if_not_installed("png")

  # Skip test as tiles sometimes are not available
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()
  skip_on_covr()


  tile <- esp_getTiles(x)


  expect_error(layer_spatraster(tile))
})
