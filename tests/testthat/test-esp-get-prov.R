test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  local_fun <- esp_get_nuts
  local_mocked_bindings(esp_get_nuts = function(...) {
    NULL
  })
  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })

  n <- esp_get_prov(update_cache = TRUE, verbose = FALSE)

  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
  local_mocked_bindings(esp_get_nuts = local_fun)
})

test_that("prov offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  expect_snapshot(error = TRUE, esp_get_prov(prov = "FFF"))
  expect_snapshot(error = TRUE, esp_get_prov(prov = "Menorca"))
  expect_snapshot(error = TRUE, esp_get_prov(prov = "ES6x"))

  expect_silent(esp_get_prov())
  expect_silent(esp_get_prov(prov = c("Galicia", "ES7", "Centro")))

  expect_silent(
    mix <- esp_get_prov(
      prov = c(
        "Euskadi",
        "Catalunya",
        "ES-EX",
        "ES52",
        "01"
      )
    )
  )
  expect_snapshot(mix$ine.prov.name)
  # Islands
  expect_silent(islands <- esp_get_prov(prov = c("Baleares", "Canarias")))
  expect_snapshot(islands$ine.prov.name)

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

  expect_snapshot(n2 <- esp_get_prov(prov = c(f$cpro, "La Gomera")))
  expect_equal(nrow(n2), 52)

  n <- esp_get_prov(prov = f$prov.shortname.es)
  expect_equal(nrow(n), 52)
})
