#' Internal function to download and cache a file from a URL
#'
#' @param url character string. The URL to download.
#' @param name character string. The name of the file to save.
#' @param cache_dir character string. The base cache directory.
#' @param subdir character string. The subdirectory inside the cache directory.
#' @param update_cache logical. Whether to update the cached file.
#' @param verbose logical. Whether to print messages.
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

  # Create destfile and clean
  file_local <- file.path(cache_dir, name)
  file_local <- gsub("//", "/", file_local)

  msg <- paste0("Cache dir is {.path ", cache_dir, "}.")
  make_msg("info", verbose, msg)

  # Check if file already exists
  fileoncache <- file.exists(file_local)

  # If already cached return
  if (isFALSE(update_cache) && fileoncache) {
    msg <- paste0("File already cached: {.file ", file_local, "}.")
    make_msg("success", verbose, msg)

    return(file_local)
  }

  if (fileoncache) {
    make_msg("warning", verbose, "Updating cached file")
  }

  msg <- paste0("Downloading {.url ", url, "}.")
  make_msg("info", verbose, msg)

  req <- httr2::request(url)
  req <- httr2::req_error(req, is_error = function(x) {
    FALSE
  })

  # Create a folder for caching httr2 requests
  cache_httr2 <- file.path(tempdir(), "mapSpain", "cache_request")
  cache_httr2 <- create_cache_dir(cache_httr2)

  req <- httr2::req_cache(
    req,
    cache_httr2,
    max_size = 1024^3 / 2,
    max_age = 3600
  )

  req <- httr2::req_timeout(req, 300)
  req <- httr2::req_retry(req, max_tries = 3)
  if (verbose) {
    req <- httr2::req_progress(req)
  }

  test_off <- getOption("mapspain_test_offline", FALSE)

  if (any(!httr2::is_online(), test_off)) {
    cli::cli_alert_danger("Offline")
    cli::cli_alert("Returning {.val NULL}")
    return(NULL)
  }

  # Response

  # Check before the size to see if we need to inform with HEAD
  get_header <- httr2::req_method(req, "HEAD")
  getsize <- httr2::req_perform(get_header)

  size_dwn <- as.numeric(httr2::resp_header(getsize, "content-length", 0))
  class(size_dwn) <- class(object.size("a"))
  thr <- 50 * (1024^2)
  if (size_dwn > thr) {
    sz_dwn <- paste0(format(size_dwn, units = "auto"), ".")
    make_msg("warning", TRUE, "The file to be downloaded has size", sz_dwn)
    req <- httr2::req_progress(req)
  }

  # Testing
  test_offline <- getOption("mapspain_test_404", FALSE)
  if (test_offline) {
    # Modify to redirect to fake url
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

    cli::cli_alert_danger(
      c(
        "{.strong Error {.num {get_status_code}}} ({get_status_desc}):",
        " {.url {url}}."
      )
    )
    cli::cli_alert_warning(
      c(
        "If you think this is a bug please consider opening an issue on ",
        "{.url https://github.com/https://github.com/rOpenSpain/mapSpain/issues}"
      )
    )
    cli::cli_alert("Returning {.val NULL}")
    return(NULL)
  }
  msg <- paste0("Download succesful on {.file ", file_local, "}.")
  make_msg("success", verbose, msg)

  file_local
}


#' Allows to use jsonlite in Imports
#'
#' The only purpose of this function is to use \CRANpkg{jsonlite} in the
#' source package code, so it should be included in the Imports file. Otherwise
#' CRAN would complain as it is not directly used.
#'
#' We need to import \CRANpkg{jsonlite} because the package makes heavy use of
#' it under the hood with [httr2::resp_body_json()], but \CRANpkg{httr2} lists
#' it on Suggests. So we need to avoid this with this simple trick.
#'
#' This function is never used on the package.
#'
#' @noRd
for_import_jsonlite <- function() {
  # To json on our website
  url <- "https://ropenspain.github.io/mapSpain/search.json"
  res <- httr2::request(url)
  resp <- httr2::req_perform(res)
  txt <- httr2::resp_body_string(resp)
  local <- jsonlite::parse_json(txt)

  # Import also tibble
  local <- tibble::tibble(row = unlist(local[[1]]))
  local <- NULL
  invisible(local)
}
