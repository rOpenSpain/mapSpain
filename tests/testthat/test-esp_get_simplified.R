test_that("simplified prov online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  expect_silent(esp_get_simpl_prov())

  expect_message(esp_get_simpl_prov(verbose = TRUE))
  expect_message(esp_get_simpl_prov(verbose = TRUE, update_cache = TRUE))
  expect_message(esp_get_simpl_prov(prov = "Canarias", verbose = TRUE))

  can <- esp_get_simpl_prov("Canarias")
  expect_equal(nrow(can), 2)
  expect_equal(sf::st_crs(can), sf::st_crs(NA))

  expect_error(esp_get_simp_prov(prov = "5689"))

  expect_silent(esp_get_simpl_prov(prov = "La Rioja"))
  expect_silent(esp_get_simpl_prov(prov = "Alava"))


  a <- mapSpain::esp_codelist
  n <- a$nuts1.name

  s <- esp_get_simpl_prov(prov = n)
  expect_equal(length(unique(s$cpro)), 52)
})


test_that("simplified ccaa online", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  expect_silent(esp_get_simpl_ccaa())

  expect_message(esp_get_simpl_ccaa(verbose = TRUE))
  expect_message(esp_get_simpl_ccaa(verbose = TRUE, update_cache = TRUE))
  expect_message(esp_get_simpl_ccaa(ccaa = "Canarias", verbose = TRUE))

  can <- esp_get_simpl_ccaa("Canarias")
  expect_equal(nrow(can), 1)
  expect_equal(sf::st_crs(can), sf::st_crs(NA))

  expect_error(esp_get_simp_prov(prov = "5689"))

  expect_silent(esp_get_simpl_ccaa(ccaa = "La Rioja"))
  expect_silent(esp_get_simpl_ccaa(ccaa = "Pais Vasco"))


  a <- mapSpain::esp_codelist
  n <- a$nuts1.name

  s <- esp_get_simpl_ccaa(ccaa = n)
  expect_equal(length(unique(s$codauto)), 19)
})
