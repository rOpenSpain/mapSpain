test_that("Testing dict", {
  vals <- c("Errioxa", "Coruna", "Gerona", "Madrid")

  expect_error(esp_dict_region_code(vals, "aa"))
  expect_error(esp_dict_region_code(vals, destination = "aa"))

  expect_message(esp_dict_region_code(vals))
  expect_silent(esp_dict_region_code(vals, destination = "nuts"))
  expect_silent(esp_dict_region_code(vals, destination = "cpro"))
  expect_silent(esp_dict_region_code(vals, destination = "iso2"))

  # test different casing of strings
  expect_silent(esp_dict_region_code(c(
    "AlBaceTe",
    "albacete",
    "ALBACETE"
  ), destination = "cpro"))
  # From ISO2 to another codes

  iso2vals <- c("ES-M", "ES-S", "ES-SG")

  expect_silent(esp_dict_region_code(iso2vals, origin = "iso2"))


  # Test all ISO2 prov

  f <- unique(esp_codelist$iso2.prov.code)

  expect_silent(esp_dict_region_code(f, "iso2", "cpro"))

  # Test all ISO2 auto

  f <- unique(esp_codelist$iso2.ccaa.code)

  expect_silent(esp_dict_region_code(f, "iso2", "codauto"))




  # Mixing levels
  valsmix <- c("Centro", "Andalucia", "Seville", "Menorca")
  expect_silent(esp_dict_region_code(valsmix, destination = "nuts"))


  expect_warning(esp_dict_region_code(valsmix, destination = "codauto"))
  expect_warning(esp_dict_region_code(valsmix, destination = "iso2"))



  vals <- c("La Rioja", "Sevilla", "Madrid", "Jaen", "Orense", "Baleares")
  expect_error(esp_dict_translate(vals, "xx"))
  expect_silent(esp_dict_translate(vals))
  expect_true(class(esp_dict_translate(vals, all = TRUE)) == "list")
  expect_warning(esp_dict_translate(c(vals, "pepe")))

  # Check results

  vals <- unique(esp_codelist$prov.shortname.es)
  test <- unique(esp_codelist$cldr.prov.name.en)

  expect_false(all(vals == test))
  expect_true(all(vals == esp_dict_translate(test, "es")))
})
