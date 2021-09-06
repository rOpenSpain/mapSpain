#' Set your `mapSpain` cache dir
#'
#' @family cache utilities
#' @seealso [rappdirs::user_config_dir()]
#'
#' @return Invisible value
#' @description
#' This function will store your `cache_dir` path on your local machine and
#' would load it for future sessions. Type `Sys.getenv("MAPSPAIN_CACHE_DIR")` to
#' find your cached path.
#'
#' Alternatively, you can store the `cache_dir` manually with the following
#' options:
#'   * Run `Sys.setenv(MAPSPAIN_CACHE_DIR = "cache_dir")`. You would need to
#'     run this command on each session (Similar to `install = FALSE`).
#'   * Set `options(mapSpain_cache_dir = "cache_dir")`. Similar to the previous
#'     option.
#'   * Write this line on your .Renviron file:
#'     `MAPSPAIN_CACHE_DIR = "cache_dir"` (same behavior than
#'     `install = TRUE`). This would store your `cache_dir` permanently.
#'
#' @inheritParams esp_get_nuts
#' @param cache_dir A path to a cache directory.
#' @param install if `TRUE`, will install the key in your local machine for
#'   use in future sessions.  Defaults to `FALSE.`
#' @param overwrite If this is set to `TRUE`, it will overwrite an existing
#'   `MAPSPAIN_CACHE_DIR` that you already have in local machine.
#'
#'
#' @examples
#'
#' # Don't run this! It would modify your current state
#' \dontrun{
#' esp_set_cache_dir(verbose = TRUE)
#' }
#'
#' Sys.getenv("MAPSPAIN_CACHE_DIR")
#' @export
esp_set_cache_dir <- function(cache_dir = rappdirs::user_cache_dir("mapSpain", "R"),
                              overwrite = TRUE,
                              install = TRUE,
                              verbose = FALSE) {

  # nocov start
  # Validate
  stopifnot(
    is.character(cache_dir),
    is.logical(overwrite),
    is.logical(install)
  )


  # Create cache dir if it doesn't exists
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  if (verbose) {
    message(
      "mapSpain cache dir is: ",
      cache_dir
    )
  }


  # Install path on environ var.

  if (install) {
    config_dir <- rappdirs::user_cache_dir("mapSpain", "R")
    # Create cache dir if not presente
    if (!dir.exists(config_dir)) {
      dir.create(config_dir, recursive = TRUE)
    }

    mapspain_file <- file.path(config_dir, "mapSpain_cache_dir")

    if (!file.exists(mapspain_file) || overwrite == TRUE) {
      # Create file if it doesn't exist
      writeLines(cache_dir, con = mapspain_file)
    } else {
      stop(
        "A cache_dir path already exists. You can overwrite it with the ",
        "argument overwrite=TRUE",
        call. = FALSE
      )
    }
  } else {
    if (verbose) {
      message(
        "To install your cache_dir path for use in future sessions, run this ",
        "function with `install = TRUE`."
      )
    }
  }

  Sys.setenv(MAPSPAIN_CACHE_DIR = cache_dir)
  return(invisible())
  # nocov end
}


#' Detect cache dir for mapSpain
#'
#' @noRd
esp_hlp_detect_cache_dir <- function() {

  # Try from getenv
  getvar <- Sys.getenv("MAPSPAIN_CACHE_DIR")


  # 1. Get from option - This is from backwards compatibility only
  # nocov start
  from_option <- getOption("mapSpain_cache_dir", NULL)

  if (!is.null(from_option) && (is.null(getvar) || getvar == "")) {
    Sys.setenv(MAPSPAIN_CACHE_DIR = from_option)
    return(from_option)
  }




  if (is.null(getvar) || is.na(getvar) || getvar == "") {
    # Not set - tries to retrieve from cache
    cachedir <- rappdirs::user_cache_dir("mapSpain", "R")
    mapspain_cache_path <- file.path(cachedir, "mapSpain_cache_dir")

    if (file.exists(mapspain_cache_path)) {
      cached_path <- readLines(mapspain_cache_path)

      # Case on empty cached path - would default
      if (is.null(cached_path) ||
        is.na(cached_path) || cached_path == "") {
        esp_set_cache_dir(
          install = TRUE, overwrite = TRUE,
          verbose = FALSE
        )
        return(rappdirs::user_cache_dir("mapSpain", "R"))
      }

      # 3. Return from cached path
      Sys.setenv(MAPSPAIN_CACHE_DIR = cached_path)
      return(cached_path)
    } else {
      # 4. Default cache location

      esp_set_cache_dir(
        install = TRUE, overwrite = TRUE,
        verbose = FALSE
      )
      return(rappdirs::user_cache_dir("mapSpain", "R"))
    }
  } else {
    return(getvar)
  }
  # nocov end
}

#' Creates `cache_dir`
#'
#' @inheritParams esp_get_nuts
#'
#' @noRd
esp_hlp_cachedir <- function(cache_dir = NULL) {
  # Check cache dir from options if not set
  if (is.null(cache_dir)) {
    cache_dir <- esp_hlp_detect_cache_dir()
  }

  # Reevaluate
  if (is.null(cache_dir)) {
    cache_dir <- file.path(tempdir(), "mapSpain")
  }

  # Create cache dir if needed
  if (isFALSE(dir.exists(cache_dir))) {
    dir.create(cache_dir, recursive = TRUE)
  }
  return(cache_dir)
}
