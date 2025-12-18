#' Autonomous Communities of Spain - SIANE
#'
#' @source
#' CartoBase ANE provided by Instituto Geografico Nacional (IGN),
#' <http://www.ign.es/web/ign/portal>. Years available are 2005 up to today.
#'
#
#' @encoding UTF-8
#' @family political
#' @family siane
#' @inheritParams esp_get_nuts
#' @inheritParams esp_get_ccaa
#' @inherit esp_get_ccaa description return
#' @export
#'
#'
#' @param year character string or number. Release year. See **Details**.
#'
#' @param resolution character string or number. Resolution of the geospatial
#'   data. One of:
#'   * "10": 1:10 million.
#'   * "6.5": 1:6.5 million.
#'   * "6.5": 1:3 million.
#'
#' @param rawcols logical. Setting this to `TRUE` would add the raw columns of
#'   the resulting object as provided by IGN.
#'
#' @details
#' `year` could be passed as a single year (`YYYY` format, as end of year) or
#' as a specific date (`YYYY-MM-DD` format). Historical information starts as
#' of 2005.
esp_get_ccaa_siane <- function(
  ccaa = NULL,
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = "3",
  moveCAN = TRUE,
  rawcols = FALSE
) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Get Data from SIANE
  data_sf <- esp_hlp_get_siane(
    "ccaa",
    resolution,
    cache,
    cache_dir,
    update_cache,
    verbose,
    year
  )

  initcols <- colnames(sf::st_drop_geometry(data_sf))

  # Add codauto
  data_sf$lab <- data_sf$rotulo

  data_sf$lab <- gsub("Ciudad de ", "", data_sf$lab, fixed = TRUE)
  data_sf$lab <- gsub("/Catalunya", "", data_sf$lab)
  data_sf$lab <- gsub("/Euskadi", "", data_sf$lab)
  data_sf$codauto <- esp_dict_region_code(data_sf$lab, destination = "codauto")

  # Filter CCAA

  region <- ccaa
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2ccaa(region)
    nuts_id <- unique(nuts_id)

    # Get df
    df <- mapSpain::esp_codelist
    dfl2 <- df[df$nuts2.code %in% nuts_id, "codauto"]
    dfl3 <- df[df$nuts3.code %in% nuts_id, "codauto"]

    finalcodauto <- c(dfl2, dfl3)

    # Filter
    data_sf <- data_sf[data_sf$codauto %in% finalcodauto, ]
  }

  # Get df final with vars
  df <- dict_ccaa
  df <- df[, names(df) != "key"]

  # Merge
  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts1
  dfnuts <- mapSpain::esp_codelist
  dfnuts <- unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])
  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

  # Move CAN

  # Checks
  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    if (length(grep("05", data_sf$codauto)) > 0) {
      penin <- data_sf[-grep("05", data_sf$codauto), ]
      can <- data_sf[grep("05", data_sf$codauto), ]

      # Move CAN
      can <- esp_move_can(can, moveCAN = moveCAN)

      # Regenerate
      if (nrow(penin) > 0) {
        data_sf <- rbind(penin, can)
      } else {
        data_sf <- can
      }
    }
  }

  # Transform
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  # Select columns
  if (rawcols) {
    data_sf <- data_sf[
      ,
      unique(c(
        initcols,
        colnames(df),
        "nuts1.code",
        "nuts1.name"
      ))
    ]
  } else {
    data_sf <- data_sf[, unique(c(colnames(df), "nuts1.code", "nuts1.name"))]
  }

  data_sf
}
