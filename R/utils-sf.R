#' Read geospatial file into sf object with optional query
#'
#' @param file_local Local file path or URL to the geospatial file.
#' @param q Optional SQL query string to filter the data during reading.
#' @param ... Additional arguments passed to `sf::read_sf()`.
#'
#' @return An `sf` object containing the geospatial data.
#'
#' @noRd
read_geo_file_sf <- function(file_local, q = NULL, ..., shp_hint = NULL) {
  # Normalize NULL and empty values.
  file_local <- ensure_null(file_local)
  if (is.null(file_local)) {
    return(NULL)
  }

  # Warn for large files when no SQL query is provided.

  if (all(!grepl("^http", file_local), file.exists(file_local), is.null(q))) {
    fsize <- file.size(file_local)
    fsize_unit <- fsize
    class(fsize_unit) <- class(object.size("a"))
    thr <- 20 * (1024^2)
    if (fsize > thr) {
      fsize_unit <- paste0("(", format(fsize_unit, units = "auto"), ").")
      make_msg("warning", TRUE, "Reading large file", fsize_unit)
      make_msg("generic", TRUE, "It can take a while. Hold on!")
    }
  }

  # Create and read 'vsizip' construct for shp.zip
  if (grepl(".zip$", file_local, ignore.case = TRUE)) {
    shp_zip <- unzip(file_local, list = TRUE)
    shp_zip <- shp_zip$Name
    shp_zip <- shp_zip[grepl("shp$", shp_zip)]
    shp_hint <- ensure_null(shp_hint)
    if (!is.null(shp_hint)) {
      shp_zip <- shp_zip[grepl(shp_hint, shp_zip)]
    }
    shp_end <- shp_zip[1]
    shp_end <- ensure_null(shp_end)
    if (is.null(shp_end)) {
      cli::cli_alert_warning("Can't read file {.file {file_local}}")
      cli::cli_abort(
        paste0(
          "Please open an issue: ",
          "{.url https://github.com/rOpenSpain/mapSpain/issues}."
        )
      )
    }

    # Read with vsizip.
    file_local <- file.path("/vsizip/", file_local, shp_end)
    file_local <- gsub("//", "/", file_local, fixed = TRUE)
  }
  q <- ensure_null(q)
  if (!is.null(q)) {
    data_sf <- sf::read_sf(file_local, query = q)
  } else {
    data_sf <- sf::read_sf(file_local)
  }

  data_sf <- sanitize_sf(data_sf)

  data_sf
}

#' Convert sf object to UTF-8
#'
#' Ensures all character columns use UTF-8 encoding.
#'
#' @param data_sf Input object to convert to UTF-8.
#'
#' @return An `sf` object with UTF-8 encoding set for all columns.
#'
#' @source Extracted from [`sf`][sf::st_sf] package.
#'
#' @noRd
sanitize_sf <- function(data_sf) {
  # From sf/read.R - https://github.com/r-spatial/sf/blob/master/R/read.R
  set_utf8 <- function(x) {
    n <- names(x)
    Encoding(n) <- "UTF-8"
    to_utf8 <- function(x) {
      if (is.character(x)) {
        Encoding(x) <- "UTF-8"
      }
      x
    }
    structure(lapply(x, to_utf8), names = n)
  }
  # End set_utf8 helper.

  # Remove empty geometries.
  data_sf <- data_sf[!sf::st_is_empty(data_sf), ]

  # To UTF-8
  names <- names(data_sf)
  g <- sf::st_geometry(data_sf)

  nm <- "geometry"
  data_utf8 <-
    as.data.frame(
      set_utf8(sf::st_drop_geometry(data_sf)),
      stringsAsFactors = FALSE
    )

  data_utf8 <- tibble::as_tibble(data_utf8)

  # Reconstruct the sf object with corrected encoding.
  data_sf <- sf::st_as_sf(data_utf8, g)

  # Rename the geometry column from "g" to "geometry".
  newnames <- names(data_sf)
  newnames[newnames == "g"] <- nm
  colnames(data_sf) <- newnames
  data_sf <- sf::st_set_geometry(data_sf, nm)

  # Some CRS definitions carry extra properties; normalize using the EPSG code.

  epsg_num <- sf::st_crs(data_sf)$epsg
  epsg_num <- ensure_null(epsg_num)
  if (is.null(epsg_num)) {
    data_sf <- sf::st_set_crs(data_sf, sf::st_crs(NA))
  } else if (!identical(sf::st_crs(data_sf), sf::st_crs(epsg_num))) {
    data_sf <- sf::st_transform(data_sf, sf::st_crs(epsg_num))
  }

  data_sf <- sf::st_zm(data_sf)
  data_sf <- sf::st_make_valid(data_sf)

  data_sf
}

#' Get column names from a geospatial file
#'
#' @param file_local Local file path or URL to the geospatial file.
#' @return A character vector with the column names.
#'
#' @noRd
get_geo_file_colnames <- function(file_local) {
  layer <- get_sf_layer_name(file_local)
  # Use LIMIT 1 to avoid loading the full dataset.
  q_base <- paste0("SELECT * FROM \"", layer, "\"")
  get_cols <- read_geo_file_sf(file_local, q = paste(q_base, "LIMIT 1"))

  names(get_cols)
}

#' Get column name for filtering from a geospatial file
#'
#' @param file_local Local file path or URL to the geospatial file.
#' @param candidates Character vector of candidate column names.
#'
#' @return
#' A character vector with the matching column names or `NULL` if none found.
#'
#' @noRd
#'
get_col_name <- function(
  file_local,
  candidates = c("CNTR_ID", "CNTR_CODE")
) {
  actual_names <- get_geo_file_colnames(file_local)
  match <- intersect(candidates, actual_names)
  if (length(match) == 0) {
    return(NULL)
  }
  match
}

get_sf_layer_name <- function(file_local) {
  layer <- sf::st_layers(file_local)
  layer <- layer[which.max(layer$features), ]$name

  layer
}
