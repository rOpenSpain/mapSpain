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
})
