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

test_that("prov online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  n <- expect_silent(esp_get_prov(resolution = 60, year = 2006))
  expect_equal(nrow(n), 52)
  expect_s3_class(n, "sf")
  expect_error(
    esp_get_prov_siane("FFF")
  )
  expect_error(esp_get_prov_siane(epsg = 39823))
  expect_silent(n <- esp_get_prov_siane())

  expect_equal(nrow(n), 52)
  expect_s3_class(n, "sf")
  expect_s3_class(n, "tbl_df")


  expect_silent(esp_get_prov_siane(rawcols = TRUE))
  expect_silent(esp_get_prov_siane(moveCAN = c(1, 2)))
  expect_silent(esp_get_prov_siane(prov = c("Galicia", "ES7", "Centro")))
  expect_error(esp_get_prov_siane(prov = "Menorca"))
  expect_error(esp_get_prov_siane(prov = "ES6x"))

  expect_identical(
    sf::st_crs(esp_get_prov_siane(epsg = 3035)),
    sf::st_crs(3035)
  )

  expect_identical(
    sf::st_crs(esp_get_prov_siane(epsg = 3857)),
    sf::st_crs(3857)
  )

  expect_silent(esp_get_prov_siane(
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

  n <- esp_get_prov_siane(prov = f$nuts1.code)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = "Canarias")
  expect_equal(nrow(n), 2)

  n <- esp_get_prov_siane(prov = "Baleares")
  expect_equal(nrow(n), 1)

  n <- esp_get_prov_siane(prov = f$nuts1.name.alt)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$iso2.prov.code)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$nuts2.code)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$nuts2.name)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$cpro)
  expect_equal(nrow(n), 52)

  n <- esp_get_prov_siane(prov = f$prov.shortname.es)
  expect_equal(nrow(n), 52)
})
