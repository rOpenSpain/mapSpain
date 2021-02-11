library(tinytest)

expect_silent(esp_get_hex_ccaa())
expect_silent(esp_get_hex_prov())
expect_silent(esp_get_hex_prov("ES1"))
expect_silent(esp_get_hex_ccaa("ES1"))

expect_silent(esp_get_grid_ccaa())
expect_silent(esp_get_grid_prov())
expect_silent(esp_get_grid_ccaa("ES1"))
expect_silent(esp_get_grid_prov("ES1"))

ccaa <- esp_get_hex_ccaa()
expect_silent(sf::st_transform(ccaa, 3857))

prov <- esp_get_hex_prov()
expect_silent(sf::st_transform(prov, 3857))
