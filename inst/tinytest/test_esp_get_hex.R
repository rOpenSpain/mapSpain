library(tinytest)

expect_silent(esp_get_hex_ccaa())
expect_silent(esp_get_hex_prov())
expect_silent(esp_get_hex_prov("ES1"))
expect_silent(esp_get_hex_ccaa("ES1"))
