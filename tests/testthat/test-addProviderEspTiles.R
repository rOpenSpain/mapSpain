test_that("Testing leaflet", {
  skip_if_not_installed("leaflet")
  skip_on_cran()

  library(leaflet)

  expect_silent(providerEspTileOptions())

  expect_error(
    puertadelsol <- leaflet() %>%
      setView(
        lat = 40.4166,
        lng = -3.7038400,
        zoom = 18
      ) %>%
      addProviderEspTiles(provider = "TESTING")
  )

  expect_silent(
    puertadelsol <- leaflet() %>%
      setView(
        lat = 40.4166,
        lng = -3.7038400,
        zoom = 18
      ) %>%
      addProviderEspTiles(provider = "IGNBase.Gris") %>%
      addProviderEspTiles(provider = "RedTransporte.Carreteras")
  )
})
