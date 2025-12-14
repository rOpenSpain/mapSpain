#' Download data from SIANE
#'
#' @param sub Call to mainland Spain ("x") or Canary Island ("y")
#'
#' @inheritParams esp_hlp_get_siane
#'
#' @noRd
esp_hlp_download_siane <- function(
  type,
  resolution,
  cache,
  cache_dir,
  update_cache,
  verbose,
  sub
) {
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

  # If requesting riversname need to change api entry

  if (type == "rivernames") {
    api_entry <-
      "https://github.com/rOpenSpain/mapSpain/raw/sianedata/data-raw"
  }

  # Switch name

  filename <- switch(
    type,
    "munic" = paste0(
      "se89_",
      resolution,
      "_admin_muni_a_",
      sub,
      ".gpkg"
    ),
    "prov" = paste0("se89_", resolution, "_admin_prov_a_", sub, ".gpkg"),
    "ccaa" = paste0("se89_", resolution, "_admin_ccaa_a_", sub, ".gpkg"),
    "orogarea" = paste0("se89_", resolution, "_orog_hipso_a_", sub, ".gpkg"),
    "orogline" = paste0("se89_", resolution, "_orog_hipso_l_", sub, ".gpkg"),
    "riverline" = paste0("se89_", resolution, "_hidro_rio_l_", sub, ".gpkg"),
    "riverarea" = paste0("se89_", resolution, "_hidro_rio_a_", sub, ".gpkg"),
    "rivernames" = "rivernames.rda",
    "basinland" = paste0("se89_", resolution, "_hidro_demt_a_", sub, ".gpkg"),
    "basinlandsea" = paste0(
      "se89_",
      resolution,
      "_hidro_demc_a_",
      sub,
      ".gpkg"
    ),
    "capimun" = paste0("se89_3_urban_capimuni_p_", sub, ".gpkg"),
    "roads" = paste0("se89_3_vias_ctra_l_", sub, ".gpkg"),
    "ffccline" = paste0("se89_3_vias_ffcc_l_", sub, ".gpkg"),
    "ffccpoint" = paste0("se89_3_vias_ffcc_p_", sub, ".gpkg"),
    # This should never be activated, as it is an internal function
    stop("Type not recognized")
  )

  url <- file.path(api_entry, filename)

  cache_dir <- create_cache_dir(cache_dir)

  if (verbose) {
    message("Cache dir is ", cache_dir)
  }

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
      download.file(url, filepath, quiet = isFALSE(verbose), mode = "wb"),
      silent = TRUE
    )

    if (inherits(err_dwnload, "try-error")) {
      if (verbose) {
        message("Retrying query")
      }
      err_dwnload <- try(
        download.file(url, filepath, quiet = isFALSE(verbose), mode = "wb"),
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

  # Rivernames is special cas
  if (type == "rivernames") {
    data <- readRDS(filepath)
    return(data)
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

  if (verbose) {
    message("File loaded")
  }
  err_onload
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
esp_hlp_get_siane <- function(
  type,
  resolution,
  cache,
  cache_dir,
  update_cache,
  verbose,
  year
) {
  # Rivers names
  if (type == "rivernames") {
    df <-
      esp_hlp_download_siane(
        type,
        3,
        cache,
        cache_dir,
        update_cache,
        verbose,
        "x"
      )
    return(df)
  }

  # Mainland
  data_sf1 <-
    esp_hlp_download_siane(
      type,
      resolution,
      cache,
      cache_dir,
      update_cache,
      verbose,
      "x"
    )
  # Canary Islands
  if (type == "riverline" && as.character(resolution) != "3") {
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

    if (ncol(data_sf1) != ncol(data_sf2)) {
      data_sf2[, setdiff(names(data_sf1), names(data_sf2))] <- NA
    }

    data_sf <- rbind(data_sf1, data_sf2)
  } else {
    if (verbose) {
      message("Shape not provided for Canary Islands")
    }
    data_sf <- data_sf1
  }
  # Date management
  # Need to adjust on 2024 dist
  if (
    type %in%
      c(
        "roads",
        "riverline",
        "riverarea",
        "orogarea",
        "orogline"
      )
  ) {
    data_sf$fecha_baja <- NA
  }

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
  if (type %in% c("ffccline", "ffccpoint")) {
    return(data_sf)
  }

  df <- data_sf
  # By date
  df$fecha_bajamod <- as.character(df$fecha_baja)
  df$fecha_bajamod <-
    as.Date(ifelse(
      is.na(df$fecha_bajamod),
      as.character(Sys.Date()),
      df$fecha_bajamod
    ))
  df <- df[
    df$fecha_alta <= selDate & selDate <= df$fecha_bajamod,
    colnames(data_sf)
  ]

  df
}
