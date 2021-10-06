#' Download data from SIANE
#'
#' @param sub Call to mainland Spain ("x") or Canary Island ("y")
#'
#' @inheritParams esp_hlp_get_siane
#'
#' @noRd
esp_hlp_download_siane <- function(type,
                                   resolution,
                                   cache,
                                   cache_dir,
                                   update_cache,
                                   verbose,
                                   sub) {
  resolution <- as.character(resolution)
  # Valid res
  validres <- c("3", "6.5", "10")

  if (!resolution %in% validres) {
    stop(
      "resolution should be one of '",
      paste0(validres, collapse = "', "),
      "'"
    )
  }
  resolution <- gsub("6.5", "6m5", resolution)
  # Create url
  api_entry <-
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist"

  if (type == "munic") {
    filename <-
      paste0("se89_", resolution, "_admin_muni_a_", sub, ".gpkg")
  } else if (type == "prov") {
    filename <-
      paste0("se89_", resolution, "_admin_prov_a_", sub, ".gpkg")
  } else if (type == "ccaa") {
    filename <-
      paste0("se89_", resolution, "_admin_ccaa_a_", sub, ".gpkg")
  } else if (type == "orogarea") {
    filename <-
      paste0("se89_", resolution, "_orog_hipso_a_", sub, ".gpkg")
  } else if (type == "orogline") {
    filename <-
      paste0("se89_", resolution, "_orog_hipso_l_", sub, ".gpkg")
  } else if (type == "riverline") {
    filename <-
      paste0("se89_", resolution, "_hidro_rio_l_", sub, ".gpkg")
  } else if (type == "riverarea") {
    filename <-
      paste0("se89_", resolution, "_hidro_rio_a_", sub, ".gpkg")
  } else if (type == "rivernames") {
    filename <- "rivernames.rda"
    api_entry <-
      "https://github.com/rOpenSpain/mapSpain/raw/sianedata/data-raw"
  } else if (type == "basinland") {
    filename <-
      paste0("se89_", resolution, "_hidro_demt_a_", sub, ".gpkg")
  } else if (type == "basinlandsea") {
    filename <-
      paste0("se89_", resolution, "_hidro_demc_a_", sub, ".gpkg")
  } else if (type == "capimun") {
    filename <-
      paste0("se89_3_urban_capimuni_p_", sub, ".gpkg")
  } else if (type == "roads") {
    filename <-
      paste0("se89_3_vias_ctra_l_", sub, ".gpkg")
  } else if (type == "ffccline") {
    filename <-
      paste0("se89_3_vias_ffcc_l_", sub, ".gpkg")
  } else if (type == "ffccpoint") {
    filename <-
      paste0("se89_3_vias_ffcc_p_", sub, ".gpkg")
  } else {
    # This should never be activated, as it is an internal function
    stop("Type not recognized")
  }

  url <- file.path(api_entry, filename)

  cache_dir <- esp_hlp_cachedir(cache_dir)

  if (verbose) {
    message("Cache dir is ", cache_dir)
  }

  # Create filepath
  filepath <- file.path(cache_dir, filename)
  localfile <- file.exists(filepath)

  # nocov start

  if (isFALSE(cache)) {
    dwnload <- FALSE
    filepath <- url
    if (verbose) {
      message("Try loading from ", filepath)
    }
  } else if (update_cache | isFALSE(localfile)) {
    dwnload <- TRUE
    if (verbose) {
      message(
        "Downloading file from ",
        url,
        "\n\nSee https://github.com/rOpenSpain/mapSpain/tree/sianedata/ for more info"
      )
    }
    if (verbose & update_cache) {
      message("\nUpdating cache")
    }
  } else if (localfile) {
    dwnload <- FALSE
    if (verbose & isFALSE(update_cache)) {
      message("File already available on ", filepath)
    }
  }

  # Downloading
  file_avail <- TRUE

  if (dwnload) {
    err_dwnload <- tryCatch(
      download.file(url, filepath, quiet = isFALSE(verbose), mode = "wb"),
      warning = function(e) {
        message(
          "Download failed",
          "\n\nurl \n ",
          url,
          " not reachable.\n\nPlease try with another options. If you think this is a bug please consider opening an issue on https://github.com/rOpenSpain/mapSpain/issues"
        )
        return(TRUE)
      }
    )

    # Try again if fails
    if (isTRUE(err_dwnload)) {
      if (verbose) message("Retry download")
      Sys.sleep(1)
      err_dwnload <- tryCatch(
        download.file(url, filepath, quiet = isFALSE(verbose), mode = "wb"),
        warning = function(e) {
          message(
            "Download failed",
            "\n\nurl \n ",
            url,
            " not reachable.\n\nPlease try with another options. If you think this is a bug please consider opening an issue on https://github.com/rOpenSpain/mapSpain/issues"
          )
          return(TRUE)
        }
      )
    }


    if (isTRUE(err_dwnload)) {
      file_avail <- FALSE
    } else if (verbose) {
      message("Download succesful")
    }
  }

  loaded <- FALSE

  if (file_avail) {
    if (verbose & isTRUE(cache)) {
      message("Reading from local file ", filepath)
      size <- file.size(filepath)
      class(size) <- "object_size"
      message(format(size, units = "auto"))
    }
    if (type == "rivernames") {
      data <- readRDS(filepath)
      return(data)
    }
    err_onload <- tryCatch(
      data_sf <- sf::st_read(
        filepath,
        quiet = isFALSE(verbose),
        stringsAsFactors = FALSE
      ),
      warning = function(e) {
        message(
          "\n\nFile couldn't be loaded from \n\n",
          filepath,
          "\n\n Please try cache = TRUE"
        )
        return(TRUE)
      },
      error = function(e) {
        message("File may be corrupt. Please try again using cache = TRUE and update_cache = TRUE")
        return(TRUE)
      }
    )
    if (isTRUE(err_onload)) {
      loaded <- FALSE
    } else {
      loaded <- TRUE
      if (verbose) {
        message("File loaded")
      }
    }
  }
  if (loaded) {
    return(data_sf)
  } else {
    stop("\nExecution halted")
  }
  # nocov end
}

#' Return data from SIANE
#'
#' @param type Type of data to be requestes
#'
#' @inheritParams esp_get_capimun
#'
#' @inheritParams esp_get_ccaa_siane
#'
#' @noRd
esp_hlp_get_siane <- function(type,
                              resolution,
                              cache,
                              cache_dir,
                              update_cache,
                              verbose,
                              year) {
  # Rivers names
  if (type == "rivernames") {
    df <-
      esp_hlp_download_siane(
        type, 3, cache, cache_dir, update_cache,
        verbose, "x"
      )
    return(df)
  }

  # Mainland
  data_sf1 <-
    esp_hlp_download_siane(
      type, resolution, cache, cache_dir, update_cache,
      verbose, "x"
    )
  # Canary Islands
  if (type == "riverline" & as.character(resolution) != "3") {
    # Nothing
  } else if (type == "riverarea") {
    # Nothing
  } else if (type %in% c("ffccline", "ffccpoint")) {
    # Nothing
  } else {
    data_sf2 <-
      esp_hlp_download_siane(
        type,
        resolution,
        cache,
        cache_dir,
        update_cache,
        verbose,
        "y"
      )
  }
  # CCAA
  if (type == "ccaa") {
    data_sf1$x_cap2 <- NA
    data_sf1$y_cap2 <- NA
    data_sf1 <- data_sf1[, colnames(data_sf2)]
  }

  if (exists("data_sf2")) {
    # Transform and bind
    data_sf2 <- sf::st_transform(data_sf2, sf::st_crs(data_sf1))

    data_sf <- rbind(data_sf1, data_sf2)
  } else {
    if (verbose) {
      message("Shape not provided for Canary Islands")
    }
    data_sf <- data_sf1
  }
  # Date management
  mindate <- min(data_sf$fecha_alta)
  maxdate <- Sys.Date()
  year <- as.character(year)

  if (nchar(year) != 10) {
    selDate <- paste(year, "12", "31", sep = "-")
  } else {
    selDate <- year
  }

  if (nchar(selDate) != 10) {
    stop(
      "Date '",
      selDate,
      "' doesn't seem to be valid, use YYYY or YYYY-MM-DD format"
    )
  }

  selDate <- as.Date(selDate)

  # Check range
  checkDateRange <- mindate <= selDate & selDate <= maxdate

  if (isFALSE(checkDateRange)) {
    stop(
      "year not available. Select a year/date between '",
      mindate,
      "' and '",
      maxdate,
      "'"
    )
  }

  # Filter
  df <- data_sf
  # By date
  df$fecha_bajamod <- as.character(df$fecha_baja)
  df$fecha_bajamod <-
    as.Date(ifelse(
      is.na(df$fecha_bajamod),
      as.character(Sys.Date()),
      df$fecha_bajamod
    ))
  df <-
    df[df$fecha_alta <= selDate &
      selDate <= df$fecha_bajamod, colnames(data_sf)]

  return(df)
}
