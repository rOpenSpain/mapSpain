library(leaflet)

expect_silent(providerEspTileOptions())

expect_error(
  PuertadelSol <- leaflet() %>%
    setView(
      lat = 40.4166,
      lng = -3.7038400,
      zoom = 18
    ) %>%
    addProviderEspTiles(provider = "TESTING")
)

expect_silent(
  PuertadelSol <- leaflet() %>%
    setView(
      lat = 40.4166,
      lng = -3.7038400,
      zoom = 18
    ) %>%
    addProviderEspTiles(provider = "IGNBase.Gris") %>%
    addProviderEspTiles(provider = "RedTransporte.Carreteras")
)
