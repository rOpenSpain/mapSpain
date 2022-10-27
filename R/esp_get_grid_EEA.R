#' Get `sf` polygons of the national geographic grids provided by EEA
#'
#' @description
#' Loads a `sf` polygon with the geographic grids of Spain as provided by the
#' European Environment Agency (EEA).
#'
#' @family grids
#'
#' @return A `sf` polygon
#'
#'
#' @source
#' [EEA reference grid](https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2).
#'
#' @export
#' @param resolution Resolution of the grid in kms. Could be `1`, `10` or `100`.
#'
#' @inheritParams esp_get_grid_BDN
#'
#' @inheritSection esp_get_nuts About caching
#' @examplesIf esp_check_access()
#' \dontrun{
#'
#' grid <- esp_get_grid_EEA(type = "main", resolution = 100)
#' grid_can <- esp_get_grid_EEA(type = "canary", resolution = 100)
#' esp <- esp_get_country(moveCAN = FALSE)
#'
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf() +
#'   geom_sf(data = grid_can) +
#'   geom_sf(data = esp, fill = NA) +
#'   theme_light() +
#'   labs(title = "EEA Grid for Spain")
#' }
esp_get_grid_EEA <- function(resolution = 100,
                             type = "main",
                             update_cache = FALSE,
                             cache_dir = NULL,
                             verbose = FALSE) {
  # Check grid
  res <- as.numeric(resolution)

  if (!res %in% c(1, 10, 100)) {
    stop(
      "resolution should be one of 1, 10 or 100"
    )
  }

  if (!type %in% c("main", "canary")) {
    stop(
      "type should be one of 'main', 'canary'"
    )
  }

  newtype <- switch(type,
    "main" = "es",
    "ic"
  )

  # Url
  url <- "https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2/gis-files/spain-shapefile/at_download/file"
  cache_dir <- esp_hlp_cachedir(cache_dir)

  # Create filepath
  filename <- "Spain_shapefile.zip"

  filepath <- file.path(cache_dir, filename)


  init_grid <- paste0(
    newtype, "_",
    resolution,
    "km.shp"
  )

  init_grid <- file.path(cache_dir, init_grid)

  localfile <- file.exists(init_grid)

  if (verbose) message("Cache dir is ", cache_dir)

  if (update_cache | isFALSE(localfile)) {
    dwnload <- TRUE
    if (verbose) {
      message(
        "Downloading file from ",
        url
      )
    }
    if (verbose & update_cache) {
      message("\nUpdating cache")
    }
  } else {
    dwnload <- FALSE
    if (verbose & isFALSE(update_cache)) {
      message("File already available on ", filepath)
    }
  }

  # Downloading
  if (dwnload) {
    err_dwnload <- try(download.file(url, filepath,
      quiet = isFALSE(verbose),
      mode = "wb"
    ), silent = TRUE)
    # nocov start
    if (inherits(err_dwnload, "try-error")) {
      if (verbose) message("Retrying query")
      err_dwnload <- try(download.file(url, filepath,
        quiet = isFALSE(verbose),
        mode = "wb"
      ), silent = TRUE)
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
      # nocov end
    } else if (verbose) {
      message("Download succesful")
    }

    if (verbose) message("Unzipping ", filepath, " on ", cache_dir)
    unzip(filepath, exdir = cache_dir, overwrite = TRUE)
  }

  err_onload <- try(
    data_sf <- sf::st_read(
      init_grid,
      quiet = isFALSE(verbose),
      stringsAsFactors = FALSE
    ),
    silent = TRUE
  )
  # nocov start
  if (inherits(err_onload, "try-error")) {
    message(
      "File may be corrupt. Please try again using cache = TRUE ",
      "and update_cache = TRUE"
    )
    stop("\nExecution halted")
  }
  # nocov end
  if (verbose) message("File loaded")
  return(err_onload)
}
