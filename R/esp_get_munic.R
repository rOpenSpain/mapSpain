#' Get municipalities of Spain as [`sf`][sf::st_sf] `POLYGON`
#'
#' @description
#' Returns municipalities of Spain `sf` POLYGON` at a specified scale.
#'
#' - [esp_get_munic()] uses GISCO (Eurostat) as source. Please use
#'   [giscoR::gisco_attributions()].
#'
#' @family political
#' @family municipalities
#' @seealso [giscoR::gisco_get_lau()], [base::regex()].
#'
#' @return A [`sf`][sf::st_sf] `POLYGON`.
#'
#' @export
#'
#' @source
#' [GISCO API](https://gisco-services.ec.europa.eu/distribution/v2/)
#'
#' @param year Release year. See **Details** for years available.
#' @param region A vector of names and/or codes for provinces
#'  or `NULL` to get all the municipalities. See **Details**.
#'
#' @param munic A name or [`regex`][base::grep()] expression with the names of
#'   the required municipalities. `NULL` would return all municipalities.
#'
#' @inheritParams esp_get_nuts
#'
#'
#' @details
#'
#' The years available are:
#' - [esp_get_munic()]:  `year` could be one of "2001", "2004", "2006", "2008",
#'    "2010", "2013" and any year between 2016 and 2019.
#'    See [giscoR::gisco_get_lau()], [giscoR::gisco_get_communes()].
#' - [esp_get_munic_siane()]: `year` could be passed as a single year ("YYYY"
#'   format, as end of year) or as a specific date ("YYYY-MM-DD" format).
#'   Historical information starts as of 2005.
#'
#' When using `region` you can use and mix names and NUTS codes (levels 1, 2 or
#' 3), ISO codes (corresponding to level 2 or 3) or `"cpro"`
#' (see [esp_codelist]).
#'
#' When calling a higher level (Province, Autonomous Community or NUTS1), all
#' the municipalities of that level would be added.
#'
#' @examples
#' \donttest{
#' # Get munics
#' Base <- esp_get_munic(year = "2019", region = "Castilla y Leon")
#'
#' # Provs for delimiting
#' provs <- esp_get_prov(prov = "Castilla y Leon")
#'
#' # Load population data
#' data("pobmun19")
#'
#' # Arrange and create breaks
#'
#' Base_pop <- merge(Base, pobmun19,
#'   by = c("cpro", "cmun"),
#'   all.x = TRUE
#' )
#'
#' br <- sort(c(
#'   0, 50, 100, 200, 500,
#'   1000, 5000, 50000, 100000,
#'   Inf
#' ))
#'
#' Base_pop$cuts <- cut(Base_pop$pob19, br, dig.lab = 20)
#'
#' # Plot
#' library(ggplot2)
#'
#'
#' ggplot(Base_pop) +
#'   geom_sf(aes(fill = cuts), color = NA) +
#'   geom_sf(data = provs, fill = NA, color = "grey70") +
#'   scale_fill_manual(values = hcl.colors(length(br), "cividis")) +
#'   labs(
#'     title = "Population in Castilla y Leon",
#'     subtitle = "INE, 2019",
#'     fill = "Persons"
#'   ) +
#'   theme_void()
#' }
esp_get_munic <- function(
  year = "2019",
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  region = NULL,
  munic = NULL,
  moveCAN = TRUE
) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)

  yearsav <- c(
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

  cache_dir <- create_cache_dir(cache_dir)

  if (init_epsg == "4258") {
    epsg <- "4326"
  }

  dwnload <- TRUE

  if (all(year == "2019", epsg == "4326", isFALSE(update_cache))) {
    if (verbose) {
      message("Reading from esp_munic.sf")
    }
    data_sf <- mapSpain::esp_munic.sf

    dwnload <- FALSE
  }

  if (dwnload) {
    if (year >= "2016") {
      data_sf <- giscoR::gisco_get_lau(
        year = year,
        epsg = epsg,
        update_cache = update_cache,
        cache_dir = cache_dir,
        verbose = verbose,
        country = "ES"
      )
    } else {
      data_sf <- giscoR::gisco_get_communes(
        year = year,
        epsg = epsg,
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

    cod <- unique(mapSpain::esp_codelist[, c(
      "codauto",
      "ine.ccaa.name",
      "cpro",
      "ine.prov.name"
    )])

    df2 <- merge(df, cod, by = "cpro", all.x = TRUE, no.dups = TRUE)

    df2 <- df2[, c(
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

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data_sf <- data_sf[grep(munic, data_sf$name, ignore.case = TRUE), ]
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

  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))
  data_sf <-
    data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$cmun), ]

  data_sf
}


#' @rdname esp_get_munic
#'
#'
#' @description
#' - [esp_get_munic_siane()] uses CartoBase ANE as source, provided by
#'   Instituto Geografico Nacional (IGN), <http://www.ign.es/web/ign/portal>.
#'   Years available are 2005 up to today.
#'
#' @source
#' IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#' @param resolution Resolution of the polygon. Values available are
#'   `"3"`, `"6.5"` or  `"10"`.
#'
#' @inheritParams esp_get_ccaa_siane
#'
#'
#' @export
esp_get_munic_siane <- function(
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = 3,
  region = NULL,
  munic = NULL,
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
  df$cmun <- ifelse(
    substr(df$LAU_CODE, 1, 2) %in% idprov,
    substr(df$LAU_CODE, 3, 8),
    NA
  )

  cod <- unique(mapSpain::esp_codelist[, c(
    "codauto",
    "ine.ccaa.name",
    "cpro",
    "ine.prov.name"
  )])

  df2 <- merge(df, cod, by = "cpro", all.x = TRUE, no.dups = TRUE)

  data_sf <- df2

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data_sf <- data_sf[grep(munic, data_sf$name, ignore.case = TRUE), ]
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
    data_sf <- data_sf[
      ,
      c(
        "codauto",
        "ine.ccaa.name",
        "cpro",
        "ine.prov.name",
        "cmun",
        "name",
        "LAU_CODE"
      )
    ]
  }
  data_sf
}
