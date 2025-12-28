#' Check access to SIANE data
#'
#' @keywords internal
#' @description
#' Check if **R** has access to resources at
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @return A logical.
#'
#' @seealso [giscoR::gisco_check_access()].
#'
#' @examples
#'
#' esp_check_access()
#' @export
esp_check_access <- function() {
  if (!httr2::is_online()) {
    return(FALSE) # nocov
  }
  if (on_cran()) {
    return(FALSE)
  }

  req <- httr2::request("https://github.com/rOpenSpain/mapSpain/raw/sianedata/")
  req <- httr2::req_url_path_append(req, "dist/se89_3_admin_ccaa_a_y.gpkg")
  req <- httr2::req_error(req, is_error = function(x) {
    FALSE
  })
  req <- httr2::req_method(req, "HEAD")
  resp <- httr2::req_perform(req)
  if (httr2::resp_is_error(resp)) {
    FALSE # nocov
  } else {
    TRUE
  }
}

#' Skip tests if SIANE data is not reachable
#'
#' @return invisible TRUE or skips the test
#'
#' @noRd
skip_if_siane_offline <- function() {
  # nocov start
  test_offline <- getOption("mapspain_test_404", FALSE)
  if (test_offline) {
    return(invisible(TRUE))
  }

  if (esp_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("SIANE API not reachable")
  }
  invisible()
  # nocov end
}

#' Skip tests if GISCO API is not reachable
#'
#' @return invisible TRUE or skips the test
#'
#' @noRd
skip_if_gisco_offline <- function() {
  # nocov start
  test_offline <- getOption("gisco_test_404", FALSE)
  if (test_offline) {
    return(invisible(TRUE))
  }

  if (giscoR::gisco_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("GISCO API not reachable")
  }
  invisible()
  # nocov end
}


#' Internal function to check if we are on CRAN
#' @return logical
#' @noRd
on_cran <- function() {
  env <- Sys.getenv("NOT_CRAN")
  if (identical(env, "")) {
    !interactive() # nocov
  } else {
    !isTRUE(as.logical(env))
  }
}
