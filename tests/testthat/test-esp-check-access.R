test_that("Access", {
  skip_on_cran()
  skip_if_siane_offline()

  expect_true(esp_check_access())
})

test_that("On CRAN", {
  skip_on_cran()
  skip_if_siane_offline()

  withr::local_envvar(c(NOT_CRAN = "false"))

  expect_true(on_cran())
  expect_false(esp_check_access())

  withr::local_envvar(c(NOT_CRAN = ""))

  expect_identical(!interactive(), on_cran())
})

test_that("On HTTP error", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(
    api_entry_for_checks = function(...) {
      "https://ropenspain.github.io/mapSpain/"
    }
  )

  expect_false(esp_check_access())
})

test_that("On HTTP offline", {
  skip_on_cran()
  skip_if_siane_offline()

  local_mocked_bindings(
    is_httr2_online = function(...) {
      FALSE
    }
  )

  expect_false(esp_check_access())
})
