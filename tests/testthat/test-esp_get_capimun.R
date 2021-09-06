
test_that("capimun online", {
  skip_if_not(
    giscoR::gisco_check_access(),
    "Skipping... GISCO not reachable."
  )

  expect_silent(esp_get_capimun())
  expect_silent(esp_get_capimun(rawcols = TRUE))

  expect_message(esp_get_capimun(verbose = TRUE))
  expect_message(esp_get_capimun(verbose = TRUE, update_cache = TRUE))
  expect_message(esp_get_capimun(region = "Canarias", verbose = TRUE))

  expect_error(esp_get_capimun(year = "2019-15-23"))
  expect_error(esp_get_capimun(year = "2019-15"))
  expect_warning(expect_error(expect_warning(esp_get_capimun(region = "XX"))))
  expect_error(esp_get_capimun(epsg = "5689"))
  expect_error(esp_get_capimun(year = "2040"))
  expect_error(expect_warning(esp_get_capimun(munic = "XX")))

  expect_silent(esp_get_capimun(moveCAN = FALSE))
  expect_silent(esp_get_capimun(moveCAN = c(0, 10)))
  expect_silent(esp_get_capimun(year = "2019-10-23"))
  expect_silent(esp_get_capimun(munic = "Nieva"))
  expect_silent(esp_get_capimun(region = "Alava"))


  a <- mapSpain::esp_codelist
  n <- a$nuts1.name

  s <- esp_get_capimun(region = n)
  expect_equal(length(unique(s$cpro)), 52)
})
