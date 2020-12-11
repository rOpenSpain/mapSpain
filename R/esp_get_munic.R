#' @title Get municipalities boundaries of Spain
#' @name esp_get_munic
#' @description Loads a simple feature (\code{sf}) object containing the
#' municipalities boundaries of Spain.
#' @return A \code{POLYGON} object.
#' @source \href{https://gisco-services.ec.europa.eu/distribution/v2/}{GISCO API}
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @seealso \link{esp_get_nuts},\link{esp_munic.sf}, \link{esp_codelist}
#'
#'
#' @param year,epsg,cache,update_cache,cache_dir,verbose,moveCAN
#' See \link{esp_get_nuts}. Years available: 2001, 2004, 2006,
#' 2008, 2010, 2013 and any year between 2016 and 2019.
#' @param region A vector of names and/or codes for provinces
#'  or \code{NULL} to get all the municipalities. See Details.
#' @param munic A name or regex expression with the names of the required
#'  municipalities. \code{NULL} would not produce any filtering.
#'
#' @details When using \code{region} you can use and mix names and NUTS codes
#' (levels 1, 2 or 3), ISO codes (corresponding to level 2 or 3) or
#' \code{cpro}.
#'
#' When calling a superior level (Province, Autonomous Community or NUTS1) ,
#' all the municipalities of that level would be added.
#' @examples
#'
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
#'      col = "firebrick3",
#'      border = NA,
#'      add = TRUE)
#' @export
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
    c("2001",
      "2004",
      "2006",
      "2008",
      "2010",
      "2013",
      "2016",
      "2017",
      "2018",
      "2019")

  if (!year %in% yearsav) {
    stop("year ",
         year,
         " not available, try ",
         paste0("'", yearsav, "'", collapse = ", "))
  }

  cache_dir <- esp_hlp_cachedir(cache_dir)

  if (init_epsg == "4258") {
    epsg <- "4326"
  }

  dwnload <- TRUE


  if (year == "2019" &
      epsg == "4326" &
      isFALSE(update_cache)) {
    if (verbose)
      message("Reading from esp_munic.sf")
    data.sf <- mapSpain::esp_munic.sf


    dwnload <- FALSE
  }

  # nocov start

  if (dwnload) {
    if (year >= "2016") {
      data.sf <- giscoR::gisco_get_lau(
        year = year,
        epsg = epsg,
        cache = cache,
        update_cache = update_cache,
        cache_dir = cache_dir,
        verbose = verbose,
        country = "ES"
      )
    } else {
      data.sf <- giscoR::gisco_get_communes(
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

    df <- data.sf

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
      unique(mapSpain::esp_codelist[, c("codauto",
                                        "ine.ccaa.name",
                                        "cpro", "ine.prov.name")])

    df2 <- merge(df,
                 cod,
                 by = "cpro",
                 all.x = TRUE,
                 no.dups = TRUE)


    df2 <-
      df2[, c("codauto",
              "ine.ccaa.name",
              "cpro",
              "ine.prov.name",
              "cmun",
              "name",
              "LAU_CODE")]


    data.sf <- df2
  }

  # nocov end

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data.sf <- data.sf[grep(munic, data.sf$name),]
  }



  if (!is.null(region)) {
    tonuts <- esp_hlp_all2prov(region)

    #toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)

    data.sf <- data.sf[data.sf$cpro %in% toprov,]
  }

  if (nrow(data.sf) == 0) {
    stop("The combination of region and/or munic does ",
         "not return any result")
  }



  # Move CAN

  # Checks

  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1


  if (moving) {
    if (length(grep("05", data.sf$codauto)) > 0) {
      offset <- c(550000, 920000)

      if (length(moveCAN) > 1) {
        coords <- sf::st_point(moveCAN)
        coords <- sf::st_sfc(coords, crs = sf::st_crs(4326))
        coords <- sf::st_transform(coords, 3857)
        coords <- sf::st_coordinates(coords)
        offset <- offset + as.double(coords)
      }

      data.sf <- sf::st_transform(data.sf, 3857)
      PENIN <- data.sf[-grep("05", data.sf$codauto),]
      CAN <- data.sf[grep("05", data.sf$codauto),]

      # Move CAN
      CAN <- sf::st_sf(
        sf::st_drop_geometry(CAN),
        geometry = sf::st_geometry(CAN) + offset,
        crs = sf::st_crs(CAN)
      )

      #Regenerate
      if (nrow(PENIN) > 0) {
        data.sf <- rbind(PENIN, CAN)
      } else {
        data.sf <- CAN
      }
    }
  }

  data.sf <- sf::st_transform(data.sf, as.double(init_epsg))
  data.sf <-
    data.sf[order(data.sf$codauto, data.sf$cpro, data.sf$cmun),]

  return(data.sf)
}
