esp_hlp_dwnload_sianedata <- function(api_entry, filename, cache_dir,
                                      verbose, update_cache, cache) {
  url <- file.path(api_entry, filename)

  cache_dir <- esp_hlp_cachedir(cache_dir)

  if (verbose) message("Cache dir is ", cache_dir)

  # Create filepath
  filepath <- file.path(cache_dir, filename)
  localfile <- file.exists(filepath)

  if (isFALSE(cache)) {
    dwnload <- FALSE
    filepath <- url
    if (verbose) {
      message("Try loading from ", filepath)
    }
  } else if (update_cache || isFALSE(localfile)) {
    dwnload <- TRUE
    if (verbose) {
      message(
        "Downloading file from ",
        url,
        "\n\nSee https://github.com/rOpenSpain/mapSpain/tree/sianedata/ ",
        "for more info"
      )
    }
    if (verbose && update_cache) {
      message("\nUpdating cache")
    }
  } else if (localfile) {
    dwnload <- FALSE
    if (verbose && isFALSE(update_cache)) {
      message("File already available on ", filepath)
    }
  }

  # Downloading
  if (dwnload) {
    err_dwnload <- try(
      download.file(url, filepath,
        quiet = isFALSE(verbose),
        mode = "wb"
      ),
      silent = TRUE
    )

    if (inherits(err_dwnload, "try-error")) {
      if (verbose) message("Retrying query")
      err_dwnload <- try(
        download.file(url, filepath,
          quiet = isFALSE(verbose),
          mode = "wb"
        ),
        silent = TRUE
      )
    }

    # If not then message
    if (inherits(err_dwnload, "try-error")) {
      message(
        "Download failed",
        "\n\nurl \n ",
        url,
        " not reachable.\n\nPlease try with another options. ",
        "If you think this ",
        "is a bug please consider opening an issue on:",
        "\nhttps://github.com/rOpenSpain/mapSpain/issues"
      )
      stop("\nExecution halted")
    } else if (verbose) {
      message("Download succesful")
    }
  }


  if (verbose && isTRUE(cache)) {
    message("Reading from local file ", filepath)
    size <- file.size(filepath)
    class(size) <- "object_size"
    message(format(size, units = "auto"))
  }

  # Load

  err_onload <- try(
    sf::st_read(
      filepath,
      quiet = isFALSE(verbose),
      stringsAsFactors = FALSE
    ),
    silent = TRUE
  )

  if (inherits(err_onload, "try-error")) {
    message(
      "File may be corrupt. Please try again using cache = TRUE ",
      "and update_cache = TRUE"
    )
    stop("\nExecution halted")
  }

  if (verbose) message("File loaded")
  return(err_onload)
}
