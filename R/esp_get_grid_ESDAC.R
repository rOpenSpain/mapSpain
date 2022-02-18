#' Get `sf` polygons of the national geographic grids provided by ESDAC
#'
#' @description
#' Loads a `sf` polygon with the geographic grids of Spain as provided by the
#' European Soil Data Centre (ESDAC).
#'
#' @family grids
#'
#' @return A `sf` polygon
#'
#'
#' @source
#' [EEA reference grid](https://esdac.jrc.ec.europa.eu/content/european-reference-grids).
#'
#' @references
#' - Panagos P., Van Liedekerke M., Jones A., Montanarella L., "European Soil
#'   Data Centre: Response to European policy support and public data
#'   requirements"; (2012) _Land Use Policy_, 29 (2), pp. 329-338.
#'   \doi{10.1016/j.landusepol.2011.07.003}
#' - European Soil Data Centre (ESDAC), esdac.jrc.ec.europa.eu, European
#'   Commission, Joint Research Centre.
#'
#' @export
#' @param resolution Resolution of the grid in kms. Could be `1` or `10`.
#'
#' @inheritParams esp_get_grid_EEA
#'
#' @inheritSection esp_get_nuts About caching
#' @examplesIf esp_check_access()
#' \dontrun{
#' grid <- esp_get_grid_ESDAC()
#' esp <- esp_get_country(moveCAN = FALSE)
#'
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf() +
#'   geom_sf(data = esp, color = "grey50", fill = NA) +
#'   theme_light() +
#'   labs(title = "ESDAC Grid for Spain")
#' }
#'
esp_get_grid_ESDAC <- function(resolution = 10,
                               update_cache = FALSE,
                               cache_dir = NULL,
                               verbose = FALSE) {

  # Check grid
  res <- as.numeric(resolution)

  if (!res %in% c(1, 10)) {
    stop(
      "resolution should be one of 1, 10"
    )
  }

  cache_dir <- esp_hlp_cachedir(cache_dir)


  # Url
  if (res == 10) {
    url <- "https://esdac.jrc.ec.europa.eu/Library/Reference_Grids/Grids/grids_for_single_eu25_countries_etrs_laea_10k.zip"
    filename <- "grids_for_single_eu25_countries_etrs_laea_10k.zip"
    init_grid <- "grid_spain_etrs_laea_10k.shp"
  } else {
    # nocov start
    url <- "https://esdac.jrc.ec.europa.eu/Library/Reference_Grids/Grids/grid_spain_etrs_laea_1k.zip"
    filename <- "grid_spain_etrs_laea_1k.zip"
    init_grid <- "grid_spain_etrs_laea_1k.shp"
    # nocov end
  }


  filepath <- file.path(cache_dir, filename)

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
