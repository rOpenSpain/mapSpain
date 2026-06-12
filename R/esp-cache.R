#' Set your \CRANpkg{mapSpain} cache directory
#'
#' @description
#' This function stores your `cache_dir` path on your local machine and loads
#' it for future sessions. Use `Sys.getenv("MAPSPAIN_CACHE_DIR")` or
#' [esp_detect_cache_dir()] to find the cached path.
#'
#' @details
#' By default, when no `cache_dir` is set, the package uses a folder inside
#' [base::tempdir()] (files are temporary and removed when the \R session
#' ends). To persist a cache across \R sessions, use
#' `esp_set_cache_dir(cache_dir, install = TRUE)`, which writes the chosen
#' path to a configuration file under `tools::R_user_dir("mapSpain", "config")`.
#'
#' @section Caching strategies:
#'
#' Some files can be read from their online source without caching using the
#' option `cache = FALSE`. Otherwise the source files are downloaded to
#' your computer. \CRANpkg{mapSpain} implements the following caching options:
#'
#' - For occasional use, rely on the default [tempdir()]-based cache (no
#'   install).
#' - Modify the cache for a single session by setting
#'   `esp_set_cache_dir(cache_dir = "a/path/here")`.
#' - For reproducible workflows, install a persistent cache with
#'   `esp_set_cache_dir(cache_dir = "a/path/here", install = TRUE)`, which
#'   persists across \R sessions.
#' - For caching specific files, use the `cache_dir` argument in the
#'   corresponding function.
#'
#' Sometimes cached files may be corrupted. In that case, try re-downloading
#' the data by setting `update_cache = TRUE` in the corresponding function.
#'
#' If you experience download problems, try downloading the file by another
#' method and save it to your `cache_dir`. Use `verbose = TRUE` to debug the
#' API query and [esp_detect_cache_dir()] to identify your cache path.
#'
#' @param cache_dir A path to a cache directory. When `NULL`, the function
#'   stores cached files in a temporary directory (see [base::tempdir()]).
#' @param install Logical. If `TRUE`, installs the key on your local machine for
#'   use in future sessions. Defaults to `FALSE`. If `cache_dir` is `FALSE`,
#'   this argument is automatically set to `FALSE`.
#' @param overwrite Logical. If `TRUE`, overwrites an existing
#'   `MAPSPAIN_CACHE_DIR` on your local machine.
#'
#' @inheritParams esp_get_nuts
#' @return
#' `esp_set_cache_dir()` returns an invisible character string with the path
#' to your `cache_dir`. It is primarily called for its side effect.
#'
#' @note
#' In \CRANpkg{mapSpain} >= 1.0.0, the configuration file location has
#' moved from `rappdirs::user_config_dir("mapSpain", "R")` to
#' `tools::R_user_dir("mapSpain", "config")`. A migration function automatically
#' transfers previous configuration files from the old to the new location.
#' A message appears once during this migration.
#'
#' @seealso [tools::R_user_dir()]
#'
#' @family cache utilities
#' @encoding UTF-8
#' @rdname esp_set_cache_dir
#'
#' @export
#' @examples
#'
#' # Do not run this. It would modify your current state.
#' \dontrun{
#' my_cache <- esp_detect_cache_dir()
#'
#' # Set an example cache.
#' ex <- file.path(tempdir(), "example", "cachenew")
#' esp_set_cache_dir(ex)
#'
#' esp_detect_cache_dir()
#'
#' # Restore the initial cache.
#' esp_set_cache_dir(my_cache)
#' identical(my_cache, esp_detect_cache_dir())
#' }
#'
esp_set_cache_dir <- function(
  cache_dir = NULL,
  overwrite = FALSE,
  install = FALSE,
  verbose = TRUE
) {
  cache_dir <- ensure_null(cache_dir)

  # Default if not provided
  if (is.null(cache_dir)) {
    make_msg(
      "info",
      verbose,
      "Using a temporary cache directory (see {.fn base::tempdir}). ",
      "Set {.arg cache_dir} to a value to store permanently."
    )

    # Create a folder in the temporary directory.
    cache_dir <- file.path(tempdir(), "mapSpain")
    is_temp <- TRUE
    install <- FALSE
  } else {
    is_temp <- FALSE
  }

  # Create and expand the cache directory.
  cache_dir <- create_cache_dir(cache_dir)
  msg <- paste0("{.pkg mapSpain} cache directory is {.path ", cache_dir, "}.")
  make_msg("info", verbose, msg)

  # Install the path in the environment variable.
  # nocov start

  if (install) {
    write_installed_cache_dir(cache_dir, overwrite)
    # nocov end
  } else {
    make_msg(
      "info",
      verbose && !is_temp,
      "To install your {.arg cache_dir} path for use in future sessions",
      "run this function with {.arg install = TRUE}."
    )
  }

  Sys.setenv(MAPSPAIN_CACHE_DIR = cache_dir)
  invisible(cache_dir)
}

#' @return
#' `esp_detect_cache_dir()` returns the path to the `cache_dir` used in the
#' current session.
#'
#' @rdname esp_set_cache_dir
#' @export
#' @examples
#'
#' esp_detect_cache_dir()
#'
esp_detect_cache_dir <- function() {
  cd <- detect_cache_dir_muted()
  cli::cli_alert_info("{.path {cd}}")
  cd
}

#' Clear your \CRANpkg{mapSpain} cache directory
#'
#' @description
#' **Use this function with caution.** It clears your cached data and
#' configuration, specifically:
#'
#' - Deletes the \CRANpkg{mapSpain} configuration directory
#'   (`tools::R_user_dir("mapSpain", "config")`).
#' - Deletes the `cache_dir` directory and its contents.
#' - Clears the value stored in `Sys.getenv("MAPSPAIN_CACHE_DIR")`.
#'
#' @details
#' This is an aggressive function intended to reset your installation as if you
#' had never installed or used \CRANpkg{mapSpain}.
#'
#' @param config Logical. If `TRUE`, deletes the configuration folder of
#'   \CRANpkg{mapSpain}.
#' @param cached_data Logical. If `TRUE`, deletes your `cache_dir` and all
#'   its contents.
#' @inheritParams esp_set_cache_dir
#'
#' @return Invisible. This function is called for its side effects.
#'
#' @seealso [tools::R_user_dir()]
#'
#' @family cache utilities
#' @encoding UTF-8
#'
#' @rdname esp_clear_cache
#' @export
#' @examples
#'
#' # Do not run this. It would modify your current state.
#' \dontrun{
#' my_cache <- esp_detect_cache_dir()
#'
#' # Set an example cache.
#' ex <- file.path(tempdir(), "example", "cache")
#' esp_set_cache_dir(ex, verbose = FALSE)
#'
#' # Restore the initial cache.
#' esp_clear_cache(verbose = TRUE)
#'
#' esp_set_cache_dir(my_cache)
#' identical(my_cache, esp_detect_cache_dir())
#' }
esp_clear_cache <- function(
  config = FALSE,
  cached_data = TRUE,
  verbose = FALSE
) {
  migrate_cache()

  config_dir <- cache_config_dir()
  data_dir <- detect_cache_dir_muted()

  # nocov start
  if (config && dir.exists(config_dir)) {
    unlink(config_dir, recursive = TRUE, force = TRUE)

    if (verbose) {
      cli::cli_alert_warning("{.pkg mapSpain} cache configuration deleted.")
    }
  }
  # nocov end
  if (cached_data && dir.exists(data_dir)) {
    siz <- cache_dir_size(data_dir)
    unlink(data_dir, recursive = TRUE, force = TRUE)
    if (verbose) {
      msg <- paste0(
        "{.pkg mapSpain} data deleted: {.file {data_dir}} (",
        siz,
        ")."
      )
      cli::cli_alert_success(msg)
    }
  }

  Sys.setenv(MAPSPAIN_CACHE_DIR = "")

  # Reset the cache directory.
  invisible()
}

# Internal functions ----

#' Detect cache directory silently
#'
#' @return Path to cache directory.
#' @noRd
detect_cache_dir_muted <- function() {
  migrate_cache()

  # Try the environment variable.
  getvar <- Sys.getenv("MAPSPAIN_CACHE_DIR")
  getvar <- ensure_null(getvar)

  if (is.null(getvar)) {
    cached_path <- read_installed_cache_dir()

    if (is.null(cached_path)) {
      return(esp_set_cache_dir(overwrite = TRUE, verbose = FALSE))
    }

    Sys.setenv(MAPSPAIN_CACHE_DIR = cached_path)
    cached_path
  } else {
    getvar
  }
}

cache_config_dir <- function() {
  tools::R_user_dir("mapSpain", "config")
}

cache_config_file <- function() {
  file.path(cache_config_dir(), "mapSpain_cache_dir")
}

read_installed_cache_dir <- function() {
  cache_config <- cache_config_file()
  if (!file.exists(cache_config)) {
    return(NULL)
  }

  ensure_null(readLines(cache_config))
}

write_installed_cache_dir <- function(cache_dir, overwrite = FALSE) {
  config_dir <- cache_config_dir()
  if (!dir.exists(config_dir)) {
    dir.create(config_dir, recursive = TRUE)
  }

  mapspain_file <- cache_config_file()
  if (!file.exists(mapspain_file) || overwrite) {
    writeLines(cache_dir, con = mapspain_file)
    return(invisible(cache_dir))
  }

  # nocov start
  cli::cli_abort(c(
    "A {.arg cache_dir} path already exists.",
    "You can overwrite it with {.arg overwrite = TRUE}."
  ))
  # nocov end
}

cache_dir_size <- function(data_dir) {
  siz <- file.size(list.files(data_dir, recursive = TRUE, full.names = TRUE))
  siz <- sum(siz, na.rm = TRUE)
  class(siz) <- class(object.size("a"))

  format(siz, unit = "auto")
}

#' Create `cache_dir` if needed
#'
#' @param cache_dir Path to the cache directory.
#' @return Path to the cache directory.
#'
#' @noRd
create_cache_dir <- function(cache_dir = NULL) {
  cache_dir <- ensure_null(cache_dir)

  # Check the cache directory from options if it is not set.
  if (is.null(cache_dir)) {
    cache_dir <- detect_cache_dir_muted()
  }

  cache_dir <- path.expand(cache_dir)

  # Create the cache directory if needed.
  if (isFALSE(dir.exists(cache_dir))) {
    dir.create(cache_dir, recursive = TRUE)
  }
  cache_dir
}

#' Migrate cache configuration from rappdirs to tools
#'
#' One-time function for \CRANpkg{mapSpain} >= 1.0.0.
#'
#' @param old Old cache configuration folder.
#' @param new New cache configuration folder.
#'
#' @noRd
migrate_cache <- function(
  old = rappdirs::user_config_dir("mapSpain", "R"),
  new = tools::R_user_dir("mapSpain", "config")
) {
  old_fname <- file.path(old, basename(cache_config_file()))
  new_fname <- file.path(new, basename(cache_config_file()))

  if (file.exists(new_fname)) {
    unlink(old, force = TRUE, recursive = TRUE)
    return(invisible())
  }

  if (file.exists(old_fname)) {
    cache_dir <- readLines(old_fname)
    esp_set_cache_dir(cache_dir, install = TRUE, verbose = FALSE)
    cli::cli_alert_success(c(
      "{.pkg mapSpain} >= 1.0.0: Cache configuration migrated. ",
      "See {.strong Note} in {.fn mapSpain::esp_set_cache_dir} for details."
    ))
    cli::cli_alert_info(
      "This is a one-time message. It will not be displayed again."
    )
  }
  unlink(old, force = TRUE, recursive = TRUE)

  invisible()
}
