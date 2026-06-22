#' Check access to SIANE data resources
#'
#' @description
#' Check whether \R has access to resources at
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @return Logical scalar, `TRUE` if accessible and `FALSE` otherwise.
#'
#' @seealso [giscoR::gisco_check_access()].
#'
#' @keywords internal
#' @encoding UTF-8
#' @export
#' @examples
#'
#' esp_check_access()
esp_check_access <- function() {
  if (!is_httr2_online()) {
    return(FALSE)
  }
  if (on_cran()) {
    return(FALSE)
  }

  url <- api_entry_for_checks()
  req <- httr2::request(url)
  req <- httr2::req_timeout(req, getOption("mapspain_timeout", 300L))
  req <- httr2::req_url_path_append(req, "dist/se89_3_admin_ccaa_a_y.gpkg")
  req <- httr2::req_error(req, is_error = function(x) {
    FALSE
  })
  req <- httr2::req_method(req, "HEAD")
  resp <- httr2::req_perform(req)
  if (httr2::resp_is_error(resp)) {
    FALSE
  } else {
    TRUE
  }
}

#' Internal function to check if we are on CRAN
#' @return Logical scalar, `TRUE` if running on CRAN and `FALSE` otherwise.
#' @noRd
on_cran <- function() {
  env <- Sys.getenv("NOT_CRAN")
  if (identical(env, "")) {
    !interactive()
  } else {
    !isTRUE(as.logical(env))
  }
}

is_httr2_online <- function() {
  httr2::is_online()
}

api_entry_for_checks <- function() {
  "https://github.com/rOpenSpain/mapSpain/raw/sianedata/"
}
