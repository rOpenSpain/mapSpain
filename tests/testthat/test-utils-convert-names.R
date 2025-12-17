test_that("convert_to_nuts", {
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
})


test_that("convert_to_nuts_ccaa", {
  expect_snapshot(n <- convert_to_nuts_ccaa(NULL))
  expect_null(n)

  expect_snapshot(n <- convert_to_nuts_ccaa(NA))
  expect_null(n)
  expect_snapshot(n <- convert_to_nuts_ccaa(c(NA, NULL)))
  expect_null(n)

  expect_silent(n <- convert_to_nuts_ccaa(c("Madrid", NA, NULL)))
  expect_identical("ES30", n)

  expect_snapshot(convert_to_nuts_ccaa(c(
    "Asturies",
    "Zaporilla",
    "ES1",
    "ES-CL"
  )))
  expect_snapshot(convert_to_nuts(c("Aama", "ES888", "FR12", "ES9")))
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
    is_null <- convert_to_nuts_ccaa(c("La Gomera", "Almeria", "Soria"))
  )
  expect_null(is_null)
  expect_snapshot(
    is_null <- convert_to_nuts_ccaa(c("AA", "XX"))
  )

  expect_null(is_null)
})
