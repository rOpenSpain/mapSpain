#' Check access to SIANE data
#'
#' @family helper
#'
#' @description
#' Check if R has access to resources at
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @return a logical.
#'
#' @seealso [giscoR::gisco_check_access()]
#'
#' @examples
#'
#' esp_check_access()
#' @export
esp_check_access <- function() {
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/",
    "dist/se89_3_admin_ccaa_a_y.gpkg"
  )

  # nocov start
  access <-
    tryCatch(
      download.file(url, destfile = tempfile(), quiet = TRUE),
      warning = function(e) {
        return(FALSE)
      },
      error = function(e) {
        return(FALSE)
      }
    )

  if (isFALSE(access)) {
    return(FALSE)
  } else {
    return(TRUE)
  }
  # nocov end
}


skip_if_siane_offline <- function() {
  # nocov start
  if (esp_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("SIANE API not reachable")
  }
  return(invisible())
  # nocov end
}


skip_if_gisco_offline <- function() {
  # nocov start
  if (giscoR::gisco_check_access()) {
    return(invisible(TRUE))
  }

  if (requireNamespace("testthat", quietly = TRUE)) {
    testthat::skip("GISCO API not reachable")
  }
  return(invisible())
  # nocov end
}
