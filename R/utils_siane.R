#' @name esp_hlp_download_siane
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
    stop("resolution should be one of '",
         paste0(validres, collapse = "', "),
         "'")
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
  }

  url <- file.path(api_entry, filename)

  cache_dir <- esp_hlp_cachedir(cache_dir)

  # Create filepath
  filepath <- file.path(cache_dir, filename)
  localfile <- file.exists(filepath)

  #nocov start

  if (isFALSE(cache)) {
    dwnload <- FALSE
    filepath <- url
    if (verbose)
      message("Try loading from ", filepath)
  } else if (update_cache | isFALSE(localfile)) {
    dwnload <- TRUE
    if (verbose)
      message(
        "Downloading file from ",
        url,
        "\n\nSee https://github.com/rOpenSpain/mapSpain/tree/sianedata/ for more info"
      )
    if (verbose & update_cache)
      message("\nUpdating cache")
  } else if (localfile) {
    dwnload <- FALSE
    if (verbose & isFALSE(update_cache))
      message("File already available on ", filepath)
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
    err_onload <- tryCatch(
      data.sf <- sf::st_read(
        filepath,
        quiet = isFALSE(verbose),
        stringsAsFactors = FALSE
      ),
      warning = function(e) {
        message("\n\nFile couldn't be loaded from \n\n",
                filepath,
                "\n\n Please try cache = TRUE")
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
      if (verbose)
        message("File loaded")
    }
  }
  if (loaded) {
    return(data.sf)
  } else {
    stop("\nExecution halted")
  }
  #nocov end
}

#' @name esp_hlp_download_siane
#' @noRd
esp_hlp_get_siane <- function(type,
                              resolution,
                              cache,
                              cache_dir,
                              update_cache,
                              verbose,
                              year) {
  # Mainland
  data.sf1 <-
    esp_hlp_download_siane(type, resolution, cache, cache_dir, update_cache,
                           verbose, "x")
  # Canary Islands
  data.sf2 <-
    esp_hlp_download_siane(type, resolution, cache, cache_dir, update_cache,
                           verbose, "y")

  # CCAA
  if (type == "ccaa") {
    data.sf1$x_cap2 <- NA
    data.sf1$y_cap2 <- NA
    data.sf1 <- data.sf1[, colnames(data.sf2)]
  }

  # Transform and bind
  data.sf2 <- sf::st_transform(data.sf2, sf::st_crs(data.sf1))

  data.sf <- rbind(data.sf1, data.sf2)

  # Date management
  minDate <- min(data.sf$fecha_alta)
  maxDate <- Sys.Date()
  year <- as.character(year)

  if (nchar(year) != 10) {
    selDate <- paste(year, "12", "31", sep = "-")
  } else {
    selDate <- year
  }

  if (nchar(selDate) != 10) {
    stop("Date '",
         selDate,
         "' doesn't seem to be valid, use YYYY or YYYY-MM-DD format")
  }

  selDate <- as.Date(selDate)

  # Check range
  checkDateRange <-  minDate <= selDate &  selDate <= maxDate

  if (isFALSE(checkDateRange)) {
    stop("year not available. Select a year/date between '",
         minDate,
         "' and '",
         maxDate,
         "'")
  }

  # Filter
  df <- data.sf
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
         selDate <= df$fecha_bajamod, colnames(data.sf)]

  return(df)

}
