test_that("Test offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_offline = TRUE)
  options(mapspain_test_offline = TRUE)
  expect_message(
    n <- esp_get_prov(update_cache = TRUE, verbose = FALSE),
    "Offline"
  )
  expect_null(n)

  options(mapspain_test_offline = FALSE)
  options(gisco_test_offline = FALSE)
})

test_that("Test 404", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  options(gisco_test_404 = TRUE)
  options(mapspain_test_404 = TRUE)
  expect_message(
    n <- esp_get_prov(update_cache = TRUE),
    "Error"
  )
  expect_null(n)

  options(mapspain_test_404 = FALSE)
  options(gisco_test_404 = FALSE)
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
