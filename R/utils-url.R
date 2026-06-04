#' Internal function to download and cache a file from a URL
#'
#' @param url Character string. The URL to download.
#' @param name Character string. The name of the file to save.
#' @param cache_dir Character string. The base cache directory.
#' @param subdir Character string. The subdirectory inside the cache directory.
#' @param update_cache Logical. Whether to update the cached file.
#' @param verbose Logical. Whether to print messages.
#'
#' @return The local file path of the downloaded file.
#'
#' @noRd
download_url <- function(
  url = NULL,
  name = basename(url),
  cache_dir = NULL,
  subdir = "fixme",
  update_cache = FALSE,
  verbose = TRUE
) {
  cache_dir <- create_cache_dir(cache_dir)
  cache_dir <- create_cache_dir(file.path(cache_dir, subdir))

  # Create and normalize the destination file path.
  file_local <- file.path(cache_dir, name)
  file_local <- gsub("//", "/", file_local, fixed = TRUE)

  msg <- paste0("Cache directory is {.path ", cache_dir, "}.")
  make_msg("info", verbose, msg)

  # Check whether the file already exists.
  fileoncache <- file.exists(file_local)

  # Return the cached file when updates are not requested.
  if (isFALSE(update_cache) && fileoncache) {
    msg <- paste0("File already cached: {.file ", file_local, "}.")
    make_msg("success", verbose, msg)

    return(file_local)
  }

  if (fileoncache) {
    make_msg("warning", verbose, "Updating cached file.")
  }

  msg <- paste0("Downloading {.url ", url, "}.")
  make_msg("info", verbose, msg)

  req <- httr2::request(url)
  req <- httr2::req_timeout(req, getOption("mapspain_timeout", 300L))
  req <- httr2::req_error(req, is_error = function(x) {
    FALSE
  })

  # Create a folder for caching httr2 requests.
  cache_httr2 <- file.path(tempdir(), "mapSpain", "cache_request")
  cache_httr2 <- create_cache_dir(cache_httr2)

  req <- httr2::req_cache(
    req,
    cache_httr2,
    max_size = 1024^3 / 2,
    max_age = 3600
  )

  req <- httr2::req_retry(req, max_tries = 3)
  if (verbose) {
    req <- httr2::req_progress(req)
  }

  if (!is_online_fun()) {
    cli::cli_alert_danger("Offline.")
    return(alert_return_null())
  }

  # Use HEAD to check whether the download is large enough to warn about.
  get_header <- httr2::req_method(req, "HEAD")
  getsize <- httr2::req_perform(get_header)

  size_dwn <- as.numeric(httr2::resp_header(getsize, "content-length", 0))
  class(size_dwn) <- class(object.size("a"))
  thr <- 50 * (1024^2)
  if (size_dwn > thr) {
    sz_dwn <- paste0(format(size_dwn, units = "auto"), ".")
    make_msg("warning", TRUE, "The download size is", sz_dwn)
    req <- httr2::req_progress(req)
  }

  # Testing
  test_offline <- is_404()
  if (test_offline) {
    # Modify to redirect to a fake URL.
    req <- httr2::req_url(
      req,
      "https://github.com/rOpenSpain/mapSpain/raw/sianedata/fake"
    )
    file_local <- tempfile(fileext = ".txt")
  }

  resp <- httr2::req_perform(req, path = file_local)

  if (httr2::resp_is_error(resp)) {
    unlink(file_local, force = TRUE)
    get_status_code <- httr2::resp_status(resp) # nolint
    get_status_desc <- httr2::resp_status_desc(resp) # nolint

    cli::cli_alert_danger(c(
      "{.strong Error {get_status_code}} ({get_status_desc}):",
      " {.url {url}}."
    ))
    alert_open_issue()
    return(alert_return_null())
  }
  msg <- paste0("Download saved to {.file ", file_local, "}.")
  make_msg("success", verbose, msg)

  file_local
}

#' Allow jsonlite in Imports
#'
#' The only purpose of this function is to use \CRANpkg{jsonlite} in the
#' source package code, so it can be included in the Imports field. Otherwise
#' CRAN would complain that it is not directly used.
#'
#' We need to import \CRANpkg{jsonlite} because the package makes heavy use of
#' it under the hood with [httr2::resp_body_json()], but \CRANpkg{httr2} lists
#' it in Suggests. This small helper avoids that issue.
#'
#' This function is never used by the package.
#'
#' @noRd
for_import_jsonlite <- function() {
  # Read JSON from the package website.
  url <- "https://ropenspain.github.io/mapSpain/search.json"
  res <- httr2::request(url)
  resp <- httr2::req_perform(res)
  txt <- httr2::resp_body_string(resp)
  local <- jsonlite::parse_json(txt)

  # Also import tibble.
  local <- tibble::tibble(row = unlist(local[[1]]))
  local <- NULL
  invisible(local)
}

#' Wrap `httr2::is_online()` for testing
#' @noRd
is_online_fun <- function(...) {
  httr2::is_online()
}

#' Wrap 404 checks for testing
#' @noRd
is_404 <- function(...) {
  FALSE
}
