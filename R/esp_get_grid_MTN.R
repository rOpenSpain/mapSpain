#' Get `sf` polygons of the national geographic grids provided by IGN
#'
#' @description
#' Loads a `sf` polygon with the geographic grids of Spain.
#'
#' @family grids
#'
#' @return A `sf` polygon
#'
#'
#' @source IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>).
#'
#' @export
#'
#' @param grid Name of the grid to be loaded. See **Details**.
#'
#' @inheritParams esp_get_nuts
#'
#' @inheritSection esp_get_nuts About caching
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>.
#'
#' Possible values of `grid` are:
#'
#' ```{r, echo=FALSE}
#'
#'
#' df <- data.frame(grid_name = c(
#'   "MTN25_ED50_Peninsula_Baleares",
#'   "MTN25_ETRS89_ceuta_melilla_alboran",
#'   "MTN25_ETRS89_Peninsula_Baleares_Canarias",
#'   "MTN25_RegCan95_Canarias",
#'   "MTN50_ED50_Peninsula_Baleares",
#'   "MTN50_ETRS89_Peninsula_Baleares_Canarias",
#'   "MTN50_RegCan95_Canarias"
#' ))
#'
#'
#' knitr::kable(df,
#'              col.names = "**grid_name**")
#'
#'
#'
#' ```
#'
#' ## MTN Grids
#'
#' A description of the MTN (Mapa Topografico Nacional) grids available:
#'
#'
#' **MTN25_ED50_Peninsula_Baleares**
#'
#' MTN25 grid corresponding to the Peninsula and Balearic Islands, in ED50 and
#' geographical coordinates (longitude, latitude) This is the real MTN25 grid,
#' that is, the one that divides the current printed series of the map, taking
#' into account special sheets and irregularities.
#'
#' **MTN50_ED50_Peninsula_Baleares**
#'
#' MTN50 grid corresponding to the Peninsula and Balearic Islands, in ED50 and
#' geographical coordinates (longitude, latitude) This is the real MTN50 grid,
#' that is, the one that divides the current printed series of the map, taking
#' into account special sheets and irregularities.
#'
#' **MTN25_ETRS89_ceuta_melilla_alboran**
#'
#'  MTN25 grid corresponding to Ceuta, Melilla, Alboran and Spanish territories
#' in North Africa, adjusted to the new official geodetic reference system
#' ETRS89, in geographical coordinates (longitude, latitude).
#'
#' **MTN25_ETRS89_Peninsula_Baleares_Canarias**
#'
#' MTN25 real grid corresponding to the Peninsula, the Balearic Islands and the
#' Canary Islands, adjusted to the new ETRS89 official reference geodetic
#' system, in geographical coordinates (longitude, latitude).
#'
#' **MTN50_ETRS89_Peninsula_Baleares_Canarias**
#'
#' MTN50 real grid corresponding to the Peninsula, the Balearic Islands and the
#' Canary Islands, adjusted to the new ETRS89 official reference geodetic
#' system, in geographical coordinates (longitude, latitude).
#'
#' **MTN25_RegCan95_Canarias**
#'
#' MTN25 grid corresponding to the Canary Islands, in REGCAN95 (WGS84
#' compatible) and geographic coordinates (longitude, latitude). It is the real
#' MTN25 grid, that is, the one that divides the current printed series of the
#' map, taking into account the special distribution of the Canary Islands
#' sheets.
#'
#' **MTN50_RegCan95_Canarias**
#'
#' MTN50 grid corresponding to the Canary Islands, in REGCAN95 (WGS84
#' compatible) and geographic coordinates (longitude, latitude). This is the
#' real grid of the MTN50, that is, the one that divides the current printed
#' series of the map, taking into account the special distribution of the
#' Canary Islands sheets.
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' grid <- esp_get_grid_MTN(grid = "MTN50_ETRS89_Peninsula_Baleares_Canarias")
#'
#' library(ggplot2)
#'
#' ggplot(grid) +
#'   geom_sf() +
#'   theme_light() +
#'   labs(title = "MTN50 Grid for Spain")
#' }
esp_get_grid_MTN <- function(grid = "MTN25_ETRS89_Peninsula_Baleares_Canarias",
                             update_cache = FALSE,
                             cache_dir = NULL,
                             verbose = FALSE) {
  # Check grid
  init_grid <- grid
  valid_grid <- c(
    "MTN25_ED50_Peninsula_Baleares",
    "MTN25_ETRS89_ceuta_melilla_alboran",
    "MTN25_ETRS89_Peninsula_Baleares_Canarias",
    "MTN25_RegCan95_Canarias",
    "MTN50_ED50_Peninsula_Baleares",
    "MTN50_ETRS89_Peninsula_Baleares_Canarias",
    "MTN50_RegCan95_Canarias"
  )

  if (!init_grid %in% valid_grid) {
    stop(
      "grid should be one of '",
      paste0(valid_grid, collapse = "', "),
      "'"
    )
  }

  # Url
  url <- "https://github.com/rOpenSpain/mapSpain/raw/sianedata/MTN/dist/MTN_grids.zip"

  cache_dir <- esp_hlp_cachedir(cache_dir)

  # Create filepath
  filename <- "MTN_grids.zip"

  filepath <- file.path(cache_dir, filename)

  gpkgpath <- file.path(cache_dir, paste0(init_grid, ".gpkg"))
  localfile <- file.exists(gpkgpath)

  if (verbose) message("Cache dir is ", cache_dir)

  if (update_cache || isFALSE(localfile)) {
    dwnload <- TRUE
    if (verbose) {
      message(
        "Downloading file from ",
        url,
        "\n\nSee https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN ",
        "for more info"
      )
    }
    if (verbose && update_cache) {
      message("\nUpdating cache")
    }
  } else {
    dwnload <- FALSE
    if (verbose && isFALSE(update_cache)) {
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
      gpkgpath,
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
