test_that("comarcas online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  expect_silent(esp_get_comarca())

  expect_message(esp_get_comarca(verbose = TRUE))
  expect_message(esp_get_comarca(verbose = TRUE, update_cache = TRUE))
  expect_message(esp_get_comarca(region = "Canarias", verbose = TRUE))

  expect_warning(expect_error(expect_warning(esp_get_comarca(region = "XX"))))
  expect_error(esp_get_comarca(epsg = "5689"))
  expect_error(expect_warning(esp_get_comarca(comarca = "XX")))

  expect_silent(esp_get_comarca(moveCAN = FALSE))
  expect_silent(esp_get_comarca(moveCAN = c(0, 10)))
  expect_silent(esp_get_comarca(comarca = "Rioja"))
  expect_silent(esp_get_comarca(region = "Alava"))

  a <- mapSpain::esp_codelist
  n <- a$nuts1.name

  s <- esp_get_comarca(region = n)
  expect_equal(length(unique(s$cpro)), 52)

  # Types
  ine <- esp_get_comarca()
  ign <- esp_get_comarca(type = "IGN")
  agr <- esp_get_comarca(type = "AGR")
  liv <- esp_get_comarca(type = "LIV")

  expect_length(unique(c(nrow(ine), nrow(ign), nrow(agr), nrow(liv))), 4)
})
