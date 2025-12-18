test_that("prov offline", {
  expect_snapshot(error = TRUE, esp_get_prov(prov = "FFF"))
  expect_snapshot(error = TRUE, esp_get_prov(prov = "Menorca"))
  expect_snapshot(error = TRUE, esp_get_prov(prov = "ES6x"))

  expect_silent(esp_get_prov())
  expect_silent(esp_get_prov(prov = c("Galicia", "ES7", "Centro")))
  expect_warning(expect_error(esp_get_prov(prov = "Menorca")))

  expect_silent(esp_get_prov(
    prov = c(
      "Euskadi",
      "Catalunya",
      "ES-EX",
      "ES52",
      "01"
    )
  ))

  # Test all

  f <- mapSpain::esp_codelist

  n <- esp_get_prov(prov = f$nuts1.code)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov(prov = "Canarias")
  expect_equal(nrow(n), 2)

  n <- esp_get_prov(prov = "Baleares")
  expect_equal(nrow(n), 1)

  n <- esp_get_prov(prov = f$nuts1.name.alt)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov(prov = f$iso2.prov.code)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov(prov = f$nuts2.code)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov(prov = f$nuts2.name)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov(prov = f$cpro)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov(prov = f$prov.shortname.es)
  expect_equal(nrow(n), 52)
})
