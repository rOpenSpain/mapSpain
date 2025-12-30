test_that("convert_to_nuts", {
  skip_on_cran()

  expect_snapshot(n <- convert_to_nuts(NULL))
  expect_null(n)

  expect_snapshot(n <- convert_to_nuts(NA))
  expect_null(n)
  expect_snapshot(n <- convert_to_nuts(c(NA, NULL)))
  expect_null(n)

  expect_silent(n <- convert_to_nuts(c("Madrid", NA, NULL)))
  expect_identical("ES30", n)

  expect_snapshot(convert_to_nuts(c("Lugo", "Zaporilla", "ES1", "ES-CL")))
  expect_snapshot(convert_to_nuts(c("Aama", "ES888", "FR12", "ES9")))
  expect_silent(
    all <- convert_to_nuts(c(
      "Sur",
      "ES-PV",
      "ES-O",
      "ES113",
      "La Gomera",
      "Aragon",
      "Granada"
    ))
  )

  expect_snapshot(all)
  expect_snapshot(esp_dict_region_code(
    all,
    origin = "nuts",
    destination = "text"
  ))

  # Consistency on levels
  cds <- esp_codelist
  # Level 1
  n1 <- unique(cds$nuts1.code)
  id_ccaa <- convert_to_nuts_ccaa(n1)
  expect_identical(id_ccaa, convert_to_nuts(id_ccaa))

  id_prov <- convert_to_nuts_prov(n1)
  expect_identical(id_prov, convert_to_nuts(id_prov))

  # Level 2
  n1 <- unique(cds$nuts2.code)
  id_ccaa <- convert_to_nuts_ccaa(n1)
  expect_identical(id_ccaa, convert_to_nuts(id_ccaa))
  id_prov <- convert_to_nuts_prov(n1)
  expect_identical(id_prov, convert_to_nuts(id_prov))
})


test_that("convert_to_nuts_ccaa", {
  skip_on_cran()

  expect_silent(n <- convert_to_nuts_ccaa(NULL))
  expect_null(n)

  expect_silent(n <- convert_to_nuts_ccaa(NA))
  expect_null(n)
  expect_silent(n <- convert_to_nuts_ccaa(c(NA, NULL)))
  expect_null(n)

  expect_silent(n <- convert_to_nuts_ccaa(c("Madrid", NA, NULL)))
  expect_identical("ES30", n)

  expect_snapshot(convert_to_nuts_ccaa(c(
    "Asturies",
    "Zaporilla",
    "ES1",
    "ES-CL"
  )))
  expect_snapshot(
    error = TRUE,
    convert_to_nuts_ccaa(c("Aama", "ES888", "FR12", "ES9"))
  )
  expect_silent(
    all <- convert_to_nuts_ccaa(c(
      "NOROESTE",
      "ES-PV",
      "05",
      "Extremadura",
      "Ceuta",
      "Melilla"
    ))
  )

  expect_snapshot(all)
  expect_snapshot(esp_dict_region_code(
    all,
    origin = "nuts",
    destination = "text"
  ))

  expect_snapshot(
    convert_to_nuts_ccaa(c("Murcia", "Almeria"))
  )
  expect_snapshot(
    error = TRUE,
    convert_to_nuts_ccaa(c("La Gomera", "Almeria", "Soria"))
  )
  expect_snapshot(
    error = TRUE,
    convert_to_nuts_ccaa(c("AA", "XX"))
  )

  # Check everything

  nuts1 <- unique(mapSpain::esp_codelist$nuts1.code)
  expect_silent(n <- convert_to_nuts_ccaa(nuts1))
  expect_length(n, 19)

  nuts2 <- unique(mapSpain::esp_codelist$nuts2.code)
  expect_silent(n <- convert_to_nuts_ccaa(nuts2))
  expect_length(n, 19)

  codauto <- unique(mapSpain::esp_codelist$codauto)
  expect_silent(n <- convert_to_nuts_ccaa(codauto))
  expect_length(n, 19)

  iso2 <- unique(mapSpain::esp_codelist$iso2.ccaa.code)
  expect_silent(n <- convert_to_nuts_ccaa(iso2))
  expect_length(n, 19)

  nm <- unique(mapSpain::esp_codelist$nuts1.name)
  expect_silent(n <- convert_to_nuts_ccaa(nm))
  expect_length(n, 19)

  nm <- unique(mapSpain::esp_codelist$nuts1.name.alt)
  expect_silent(n <- convert_to_nuts_ccaa(nm))
  expect_length(n, 19)

  nm <- unique(mapSpain::esp_codelist$nuts2.name)
  expect_silent(n <- convert_to_nuts_ccaa(nm))
  expect_length(n, 19)

  nm <- unique(mapSpain::esp_codelist$ine.ccaa.name)
  expect_silent(n <- convert_to_nuts_ccaa(nm))
  expect_length(n, 19)
})

test_that("convert_to_nuts_prov", {
  skip_on_cran()

  expect_snapshot(n <- convert_to_nuts_prov(NULL))
  expect_null(n)

  expect_snapshot(n <- convert_to_nuts_prov(NA))
  expect_null(n)
  expect_snapshot(n <- convert_to_nuts_prov(c(NA, NULL)))
  expect_null(n)

  expect_silent(n <- convert_to_nuts_prov(c("Madrid", NA, NULL)))
  expect_identical("ES300", n)

  expect_snapshot(convert_to_nuts_prov(c(
    "Asturies",
    "Zaporilla",
    "Euskadi",
    "Madrid"
  )))
  expect_snapshot(
    error = TRUE,
    convert_to_nuts_prov(c("Aama", "ES888", "FR12", "ES9"))
  )
  expect_silent(
    all <- convert_to_nuts_prov(c(
      "ES-PV",
      "05",
      "Extremadura",
      "Ceuta",
      "ES-SG",
      "ES-MU",
      "Baleares",
      "Melilla",
      "Sta. CRUZ de TenErife",
      "Baleares",
      "Las PalMAs"
    ))
  )

  expect_snapshot(all)
  expect_snapshot(esp_dict_region_code(
    all,
    origin = "nuts",
    destination = "text"
  ))

  expect_snapshot(
    convert_to_nuts_prov(c("Murcia", "Almeria"))
  )
  expect_snapshot(
    error = TRUE,
    convert_to_nuts_prov(c(
      "La Gomera",
      "El Hierro",
      "Formentera",
      "Mallorca"
    ))
  )
  expect_snapshot(
    error = TRUE,
    convert_to_nuts_prov(c("AA", "XX"))
  )

  # Check everything

  nuts1 <- unique(mapSpain::esp_codelist$nuts1.code)
  expect_silent(n <- convert_to_nuts_prov(nuts1))
  expect_length(n, 59)

  nuts2 <- unique(mapSpain::esp_codelist$nuts2.code)
  expect_silent(n <- convert_to_nuts_prov(nuts2))
  expect_length(n, 59)

  cpro <- unique(mapSpain::esp_codelist$cpro)
  expect_silent(n <- convert_to_nuts_prov(cpro))
  expect_length(n, 59)

  iso2 <- unique(mapSpain::esp_codelist$iso2.ccaa.code)
  expect_silent(n <- convert_to_nuts_prov(iso2))
  expect_length(n, 59)

  iso2_prov <- unique(mapSpain::esp_codelist$iso2.prov.code)
  expect_silent(n <- convert_to_nuts_prov(iso2_prov))
  expect_length(n, 59)

  nm <- unique(mapSpain::esp_codelist$nuts1.name)
  expect_silent(n <- convert_to_nuts_prov(nm))
  expect_length(n, 59)

  nm <- unique(mapSpain::esp_codelist$nuts1.name.alt)
  expect_silent(n <- convert_to_nuts_prov(nm))
  expect_length(n, 59)

  nm <- unique(mapSpain::esp_codelist$nuts2.name)
  expect_silent(n <- convert_to_nuts_prov(nm))
  expect_length(n, 59)

  nm <- unique(mapSpain::esp_codelist$ine.ccaa.name)
  expect_silent(n <- convert_to_nuts_prov(nm))
  expect_length(n, 59)

  nm <- unique(mapSpain::esp_codelist$ine.prov.name)
  expect_silent(n <- convert_to_nuts_prov(nm))
  expect_length(n, 59)

  nm <- unique(mapSpain::esp_codelist$nuts3.name)
  expect_snapshot(n <- convert_to_nuts_prov(nm))
  expect_length(n, 49)
})
