#' Get municipalities boundaries of Spain
#'
#' @concept political
#'
#' @description
#' Loads a simple feature (`sf`) object containing the
#' municipalities boundaries of Spain.
#'
#' `esp_get_munic` uses GISCO (Eurostat) as source.
#'
#' @return A `POLYGON` object.
#'
#' @export
#'
#' @source [GISCO API](https://gisco-services.ec.europa.eu/distribution/v2/)
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @seealso [esp_get_nuts()], [esp_munic.sf], [esp_codelist].
#'
#'
#' @param year Release year. See Details for years available.

#' @param region A vector of names and/or codes for provinces
#'  or `NULL` to get all the municipalities. See Details.
#'
#' @param munic A name or regex expression with the names of the required
#'  municipalities. `NULL` would not produce any filtering.
#'
#' @inheritParams esp_get_nuts
#'
#' @details
#' When using `region` you can use and mix names and NUTS codes
#' (levels 1, 2 or 3), ISO codes (corresponding to level 2 or 3) or
#' `cpro`.
#'
#' When calling a superior level (Province, Autonomous Community or NUTS1) ,
#' all the municipalities of that level would be added.
#'
#' On `esp_get_munic` years available are: 2001, 2004, 2006,
#' 2008, 2010, 2013 and any year between 2016 and 2019.
#'
#' @examples
#'
#' library(sf)
#'
#' Base <- esp_get_munic(region = c("Castilla y Leon"))
#' SAN <-
#'   esp_get_munic(
#'     region = c("Castilla y Leon"),
#'     munic = c("^San ", "^Santa ")
#'   )
#'
#' plot(st_geometry(Base), col = "cornsilk", border = "grey80")
#' plot(st_geometry(SAN),
#'   col = "firebrick3",
#'   border = NA,
#'   add = TRUE
#' )
esp_get_munic <- function(year = "2019",
                          epsg = "4258",
                          cache = TRUE,
                          update_cache = FALSE,
                          cache_dir = NULL,
                          verbose = FALSE,
                          region = NULL,
                          munic = NULL,
                          moveCAN = TRUE) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  yearsav <-
    c(
      "2001",
      "2004",
      "2006",
      "2008",
      "2010",
      "2013",
      "2016",
      "2017",
      "2018",
      "2019"
    )

  if (!year %in% yearsav) {
    stop(
      "year ",
      year,
      " not available, try ",
      paste0("'", yearsav, "'", collapse = ", ")
    )
  }

  cache_dir <- esp_hlp_cachedir(cache_dir)

  if (init_epsg == "4258") {
    epsg <- "4326"
  }

  dwnload <- TRUE


  if (year == "2019" &
    epsg == "4326" &
    isFALSE(update_cache)) {
    if (verbose) {
      message("Reading from esp_munic.sf")
    }
    data_sf <- mapSpain::esp_munic.sf


    dwnload <- FALSE
  }

  # nocov start

  if (dwnload) {
    if (year >= "2016") {
      data_sf <- giscoR::gisco_get_lau(
        year = year,
        epsg = epsg,
        cache = cache,
        update_cache = update_cache,
        cache_dir = cache_dir,
        verbose = verbose,
        country = "ES"
      )
    } else {
      data_sf <- giscoR::gisco_get_communes(
        year = year,
        epsg = epsg,
        cache = cache,
        update_cache = update_cache,
        cache_dir = cache_dir,
        verbose = verbose,
        country = "ES",
        spatialtype = "RG"
      )
    }

    # Create dataframe

    df <- data_sf

    # Names management

    if ("LAU_ID" %in% colnames(df)) {
      df$LAU_CODE <- df$LAU_ID
    }

    if ("NSI_CODE" %in% colnames(df)) {
      df$LAU_CODE <- df$NSI_CODE
    }

    if ("LAU_NAME" %in% colnames(df)) {
      df$name <- df$LAU_NAME
    }

    if ("COMM_NAME" %in% colnames(df)) {
      df$name <- df$COMM_NAME
    }

    if ("SABE_NAME" %in% colnames(df)) {
      df$name <- df$SABE_NAME
    }

    df <- df[, c("LAU_CODE", "name")]


    df$LAU_CODE <- gsub("ES", "", df$LAU_CODE)

    df$cpro <- substr(df$LAU_CODE, 1, 2)
    df$cmun <- substr(df$LAU_CODE, 3, 8)

    df <- df[, c("cpro", "cmun", "name", "LAU_CODE")]

    cod <-
      unique(mapSpain::esp_codelist[, c(
        "codauto",
        "ine.ccaa.name",
        "cpro", "ine.prov.name"
      )])

    df2 <- merge(df,
      cod,
      by = "cpro",
      all.x = TRUE,
      no.dups = TRUE
    )


    df2 <-
      df2[, c(
        "codauto",
        "ine.ccaa.name",
        "cpro",
        "ine.prov.name",
        "cmun",
        "name",
        "LAU_CODE"
      )]


    data_sf <- df2
  }

  # nocov end

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data_sf <- data_sf[grep(munic, data_sf$name), ]
  }



  if (!is.null(region)) {
    tonuts <- esp_hlp_all2prov(region)

    # toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)

    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  if (nrow(data_sf) == 0) {
    stop(
      "The combination of region and/or munic does ",
      "not return any result"
    )
  }



  # Move CAN

  # Checks

  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1


  if (moving) {
    if (length(grep("05", data_sf$codauto)) > 0) {
      offset <- c(550000, 920000)

      if (length(moveCAN) > 1) {
        coords <- sf::st_point(moveCAN)
        coords <- sf::st_sfc(coords, crs = sf::st_crs(4326))
        coords <- sf::st_transform(coords, 3857)
        coords <- sf::st_coordinates(coords)
        offset <- offset + as.double(coords)
      }

      data_sf <- sf::st_transform(data_sf, 3857)
      PENIN <- data_sf[-grep("05", data_sf$codauto), ]
      CAN <- data_sf[grep("05", data_sf$codauto), ]

      # Move CAN
      CAN <- sf::st_sf(
        sf::st_drop_geometry(CAN),
        geometry = sf::st_geometry(CAN) + offset,
        crs = sf::st_crs(CAN)
      )

      # Regenerate
      if (nrow(PENIN) > 0) {
        data_sf <- rbind(PENIN, CAN)
      } else {
        data_sf <- CAN
      }
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  data_sf <-
    data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$cmun), ]

  data_sf <- esp_hlp_fix_multigeoms(data_sf)

  return(data_sf)
}


#' @rdname esp_get_munic
#'
#' @concept political
#'
#' @description
#' `esp_get_munic_siane` uses CartoBase ANE as source, provided by Instituto
#' Geografico Nacional (IGN), <http://www.ign.es/web/ign/portal>. Years
#' available are 2005 up to today.
#'
#' @source
#' IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @param resolution Resolution of the polygon. Values available are
#' "3", "6.5" or  "10".
#'
#' @inheritParams esp_get_ccaa_siane
#'
#' @details
#' On `esp_get_munic_siane`, `year` could be passed as a single
#' year ("YYYY" format, as end of year) or as a specific
#' date ("YYYY-MM-DD" format). Historical information starts as of 2005.
#'
#' @export
esp_get_munic_siane <- function(year = Sys.Date(),
                                epsg = "4258",
                                cache = TRUE,
                                update_cache = FALSE,
                                cache_dir = NULL,
                                verbose = FALSE,
                                resolution = 3,
                                region = NULL,
                                munic = NULL,
                                moveCAN = TRUE,
                                rawcols = FALSE) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Get Data from SIANE
  data_sf <- esp_hlp_get_siane(
    "munic",
    resolution,
    cache,
    cache_dir,
    update_cache,
    verbose,
    year
  )

  colnames_init <- colnames(sf::st_drop_geometry(data_sf))
  df <- data_sf

  # Name management
  df$LAU_CODE <- df$id_ine
  df$name <- df$rotulo
  df$cpro <- df$id_prov

  idprov <- sort(unique(mapSpain::esp_codelist$cpro))
  df$cmun <- ifelse(substr(df$LAU_CODE, 1, 2) %in% idprov,
    substr(df$LAU_CODE, 3, 8),
    NA
  )

  cod <-
    unique(mapSpain::esp_codelist[, c(
      "codauto",
      "ine.ccaa.name",
      "cpro", "ine.prov.name"
    )])

  df2 <- merge(df,
    cod,
    by = "cpro",
    all.x = TRUE,
    no.dups = TRUE
  )

  data_sf <- df2

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data_sf <- data_sf[grep(munic, data_sf$name), ]
  }

  if (!is.null(region)) {
    tonuts <- esp_hlp_all2prov(region)
    # toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)
    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  if (nrow(data_sf) == 0) {
    stop(
      "The combination of region and/or munic does ",
      "not return any result"
    )
  }
  # Move CAN

  # Checks
  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    if (length(grep("05", data_sf$codauto)) > 0) {
      offset <- c(550000, 920000)

      if (length(moveCAN) > 1) {
        coords <- sf::st_point(moveCAN)
        coords <- sf::st_sfc(coords, crs = sf::st_crs(4326))
        coords <- sf::st_transform(coords, 3857)
        coords <- sf::st_coordinates(coords)
        offset <- offset + as.double(coords)
      }

      data_sf <- sf::st_transform(data_sf, 3857)
      PENIN <- data_sf[-grep("05", data_sf$codauto), ]
      CAN <- data_sf[grep("05", data_sf$codauto), ]

      # Move CAN
      CAN <- sf::st_sf(
        sf::st_drop_geometry(CAN),
        geometry = sf::st_geometry(CAN) + offset,
        crs = sf::st_crs(CAN)
      )

      # Regenerate
      if (nrow(PENIN) > 0) {
        data_sf <- rbind(PENIN, CAN)
      } else {
        data_sf <- CAN
      }
    }
  }

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  data_sf <-
    data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$cmun), ]

  namesend <- unique(c(
    colnames_init,
    c(
      "codauto",
      "ine.ccaa.name",
      "cpro",
      "ine.prov.name",
      "cmun",
      "name",
      "LAU_CODE"
    ),
    colnames(data_sf)
  ))

  data_sf <- data_sf[, namesend]

  if (isFALSE(rawcols)) {
    data_sf <- data_sf[, c(
      "codauto",
      "ine.ccaa.name",
      "cpro",
      "ine.prov.name",
      "cmun",
      "name",
      "LAU_CODE"
    )]
  }
  return(data_sf)
}
