test_that("Utils names", {
  skip_on_cran()

  expect_snapshot(convert_country_code(c("Espagne", "United Kingdom")))
  expect_snapshot(convert_country_code("U"), error = TRUE)
  expect_snapshot(convert_country_code(
    c("ESP", "POR", "RTA", "USA"),
    "iso3c"
  ))
  expect_snapshot(convert_country_code(c("ESP", "Alemania")))
})

test_that("Problematic names", {
  skip_on_cran()

  expect_snapshot(convert_country_code(c("Espagne", "Antartica")))
  expect_snapshot(convert_country_code(c("spain", "antartica")))

  # Special case for Kosovo
  expect_snapshot(convert_country_code(c("Spain", "Kosovo", "Antartica")))
  expect_snapshot(convert_country_code(
    c("Spain", "Kosovo", "Antartica"),
    "iso3c"
  ))
  expect_snapshot(convert_country_code(c("ESP", "XKX", "DEU")))
  expect_snapshot(
    convert_country_code(c("Spain", "Rea", "Kosovo", "Antartica", "Murcua"))
  )

  expect_snapshot(
    convert_country_code("Kosovo")
  )
  expect_snapshot(
    convert_country_code("XKX")
  )
  expect_snapshot(
    convert_country_code("XK", "iso3c")
  )
  expect_identical(
    convert_country_code("ES"),
    "ESP"
  )
})

test_that("Test mixed countries", {
  skip_on_cran()

  expect_snapshot(convert_country_code(c(
    "Germany",
    "USA",
    "Greece",
    "united Kingdom"
  )))
})
