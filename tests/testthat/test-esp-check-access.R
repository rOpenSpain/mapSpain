test_that("Access", {
  skip_on_cran()
  skip_if_siane_offline()

  expect_true(esp_check_access())
})

test_that("On CRAN", {
  skip_on_cran()
  skip_if_siane_offline()

  # Imagine we are in CRAN
  env_orig <- Sys.getenv("NOT_CRAN")
  Sys.setenv("NOT_CRAN" = "false")
  expect_true(on_cran())
  expect_false(esp_check_access())

  # Restore
  Sys.setenv("NOT_CRAN" = env_orig)
  expect_identical(Sys.getenv("NOT_CRAN"), env_orig)
  expect_true(esp_check_access())
})
