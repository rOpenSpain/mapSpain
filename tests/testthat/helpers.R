skip_if_siane_offline <- function() {
  test_offline <- is_404()
  if (test_offline) {
    return(invisible(TRUE))
  }

  if (esp_check_access()) {
    return(invisible(TRUE))
  }

  testthat::skip("SIANE API not reachable")

  invisible()
}

skip_if_gisco_offline <- function() {
  test_offline <- is_404()
  if (test_offline) {
    return(invisible(TRUE))
  }

  if (giscoR::gisco_check_access()) {
    return(invisible(TRUE))
  }

  testthat::skip("GISCO API not reachable")

  invisible()
}
