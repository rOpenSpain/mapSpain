test_that("Test gridmaps", {
  expect_silent(n <- esp_get_hex_ccaa())
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 19)

  expect_silent(n <- esp_get_hex_prov())
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 52)

  expect_silent(n <- esp_get_hex_prov("ES1"))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 6)

  expect_silent(n <- esp_get_hex_ccaa("ES1"))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 3)

  # Grids

  expect_silent(n <- esp_get_grid_ccaa())
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 19)

  expect_silent(n <- esp_get_grid_prov())
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 52)

  expect_silent(n <- esp_get_grid_prov("ES1"))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 6)

  expect_silent(n <- esp_get_grid_ccaa("ES1"))
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")
  expect_shape(n, nrow = 3)

  expect_silent(esp_get_grid_ccaa())
  expect_silent(esp_get_grid_prov())
  expect_silent(esp_get_grid_ccaa("ES1"))
  expect_silent(esp_get_grid_prov("ES1"))

  #  Errors
  expect_snapshot(error = TRUE, esp_get_grid_prov("Mallorca"))

  expect_snapshot(error = TRUE, esp_get_grid_ccaa("Mallorca"))

  ccaa <- esp_get_hex_ccaa()
  expect_equal(sf::st_crs(ccaa)$epsg, 4258)

  ccaa <- esp_get_grid_ccaa()
  expect_equal(sf::st_crs(ccaa)$epsg, 4258)

  prov <- esp_get_hex_prov()
  expect_equal(sf::st_crs(prov)$epsg, 4258)

  prov <- esp_get_grid_prov()
  expect_equal(sf::st_crs(prov)$epsg, 4258)

  # Test all filter
  cpros <- unique(mapSpain::esp_codelist$cpro)
  expect_shape(esp_get_grid_prov(cpros), nrow = 52)

  ccaa <- unique(mapSpain::esp_codelist$nuts2.name)
  expect_shape(esp_get_grid_ccaa(ccaa), nrow = 19)
})
