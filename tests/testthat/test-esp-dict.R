test_that("Testing dict", {
  skip_on_cran()

  vals <- c("Errioxa", "Coruna", "Gerona", "Madrid")

  expect_snapshot(error = TRUE, esp_dict_region_code(vals, "aa"))
  expect_snapshot(error = TRUE, esp_dict_region_code(vals, destination = "aa"))

  expect_snapshot(esp_dict_region_code(vals))
  expect_snapshot(esp_dict_region_code(vals, destination = "nuts"))
  expect_snapshot(esp_dict_region_code(vals, destination = "cpro"))
  expect_snapshot(esp_dict_region_code(vals, destination = "iso2"))

  # test fix on new database
  expect_snapshot(
    esp_dict_region_code(
      c(
        "Región de Murcia",
        "Principado de Asturias",
        "Ciudad de Ceuta",
        "Ciudad de Melilla",
        "Sta. Cruz de Tenerife"
      ),
      destination = "cpro"
    )
  )

  # test different casing of strings
  expect_snapshot(esp_dict_region_code(
    c(
      "AlBaceTe",
      "albacete",
      "ALBACETE"
    ),
    destination = "cpro"
  ))
  # From ISO2 to another codes

  iso2vals <- c("ES-M", "ES-S", "ES-SG")

  expect_snapshot(esp_dict_region_code(iso2vals, origin = "iso2"))

  # Test all ISO2 prov

  f <- unique(esp_codelist$iso2.prov.code)

  expect_silent(esp_dict_region_code(f, "iso2", "cpro"))

  # Test all ISO2 auto

  f <- unique(esp_codelist$iso2.ccaa.code)

  expect_silent(esp_dict_region_code(f, "iso2", "codauto"))

  # Mixing levels
  valsmix <- c("Centro", "Andalucia", "Seville", "Menorca")
  expect_snapshot(esp_dict_region_code(valsmix, destination = "nuts"))

  expect_snapshot(esp_dict_region_code(valsmix, destination = "codauto"))
  expect_snapshot(esp_dict_region_code(valsmix, destination = "iso2"))

  vals <- c("La Rioja", "Sevilla", "Madrid", "Jaen", "Orense", "Baleares")
  expect_snapshot(error = TRUE, esp_dict_translate(vals, "xx"))
  expect_silent(esp_dict_translate(vals))

  expect_snapshot(esp_dict_translate(c("Ceuta", "Melilla", vals), all = TRUE))
  expect_snapshot(esp_dict_translate(c(vals, "pepe")))

  # Check results

  vals <- unique(esp_codelist$prov.shortname.es)
  test <- unique(esp_codelist$cldr.prov.name.en)

  expect_false(all(vals == test))
  expect_true(all(vals == esp_dict_translate(test, "es")))
  expect_snapshot(
    esp_dict_translate(
      c(
        "Región de Murcia",
        "Principado de Asturias",
        "Ciudad de Ceuta",
        "Ciudad de Melilla",
        "Sta. Cruz de Tenerife"
      ),
      lang = "eu"
    )
  )
})
