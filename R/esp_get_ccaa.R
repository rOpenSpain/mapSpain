#' Get Autonomous Communities boundaries of Spain
#'
#' @concept political
#'
#' @rdname esp_get_ccaa
#'
#' @description
#' Loads a simple feature (`sf`) object containing the autonomous communities
#' boundaries of Spain.
#'
#' `esp_get_ccaa` uses GISCO (Eurostat) as source
#'
#' @return A `POLYGON/POINT` object.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @seealso
#' [esp_get_hex_ccaa()], [esp_get_nuts()], [esp_get_prov()],
#' [esp_get_munic()], [esp_codelist]
#'
#' @export
#'
#' @param ccaa A vector of names and/or codes for autonomous communities
#'   or `NULL` to get all the autonomous communities. See Details.
#'
#' @param ... Additional parameters from [esp_get_nuts()].
#'
#' @details
#' When using `ccaa` you can use and mix names and NUTS codes (levels 1 or 2),
#' ISO codes (corresponding to level 2) or `codauto`. Ceuta and Melilla are
#' considered as Autonomous Communities on this dataset.
#'
#' When calling a NUTS1 level, all the Autonomous Communities of that level
#' would be added.
#'
#' @examples
#'
#' library(sf)
#'
#' # Random CCAA
#'
#' Random <-
#'   esp_get_ccaa(ccaa = c(
#'     "Euskadi",
#'     "Catalunya",
#'     "ES-EX",
#'     "Canarias",
#'     "ES52",
#'     "01"
#'   ))
#' plot(st_geometry(Random), col = hcl.colors(6))
#'
#' # All CCAA of a Zone plus an addition
#'
#' Mix <-
#'   esp_get_ccaa(
#'     ccaa = c("La Rioja", "Noroeste"),
#'     resolution = "20"
#'   )
#' plot(
#'   Mix[, "nuts1.code"],
#'   pal = hcl.colors(2),
#'   key.pos = NULL,
#'   main = NULL,
#'   border = "white"
#' )
esp_get_ccaa <- function(ccaa = NULL, ...) {
  params <- list(...)

  # Get region id

  ccaa <- ccaa[!is.na(ccaa)]


  region <- ccaa
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2ccaa(region)

    nuts_id <- unique(nuts_id)
    if (length(nuts_id) == 0) {
      stop(
        "region ",
        paste0("'", region, "'", collapse = ", "),
        " is not a valid name"
      )
    }
  }

  params$region <- nuts_id
  params$nuts_level <- 2


  data_sf <- do.call(mapSpain::esp_get_nuts, params)

  data_sf$nuts2.code <- data_sf$NUTS_ID
  data_sf <- data_sf[, "nuts2.code"]



  # Get df
  df <- dict_ccaa
  df <- df[, names(df) != "key"]

  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts1
  dfnuts <- mapSpain::esp_codelist
  dfnuts <-
    unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])

  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

  data_sf <- data_sf[, unique(c(colnames(df), "nuts1.code", "nuts1.name"))]

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  return(data_sf)
}



#' @rdname esp_get_ccaa
#'
#' @concept political
#'
#' @description
#' `esp_get_ccaa_siane` uses CartoBase ANE as source, provided by
#' Instituto Geografico Nacional (IGN), <http://www.ign.es/web/ign/portal>.
#'
#' Years available are 2005 up to today.
#'
#' @source
#' IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>.
#'
#' @export
#'
#' @param year Release year. See [esp_get_nuts()] for `esp_get_ccaa` and
#'   Details for `esp_get_ccaa_siane`
#'
#' @param resolution Resolution of the polygon. Values available are
#'   "3", "6.5" or "10".
#'
#' @param rawcols Logical. Setting this to `TRUE` would add the raw columns of
#'   the dataset provided by IGN.
#'
#' @inheritParams esp_get_nuts
#'
#' @details
#' On `esp_get_ccaa_siane`, `year` could be passed as a single year ("YYYY"
#' format, as end of year) or as a specific date ("YYYY-MM-DD" format).
#' Historical information starts as of 2005.

esp_get_ccaa_siane <- function(ccaa = NULL,
                               year = Sys.Date(),
                               epsg = "4258",
                               cache = TRUE,
                               update_cache = FALSE,
                               cache_dir = NULL,
                               verbose = FALSE,
                               resolution = "3",
                               moveCAN = TRUE,
                               rawcols = FALSE) {
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
  data_sf$lab <- data_sf$nombres_f

  data_sf$lab <- gsub("Ciudad de ", "", data_sf$lab, fixed = TRUE)
  data_sf$lab <- gsub("/Catalunya", "", data_sf$lab)
  data_sf$lab <- gsub("/Euskadi", "", data_sf$lab)
  data_sf$codauto <- esp_dict_region_code(data_sf$lab,
    destination = "codauto"
  )

  # Filter CCAA

  region <- ccaa
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2ccaa(region)
    nuts_id <- unique(nuts_id)
    if (length(nuts_id) == 0) {
      stop(
        "region ",
        paste0("'", region, "'", collapse = ", "),
        " is not a valid name"
      )
    }

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
  dfnuts <-
    unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])
  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

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

  # Transform
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))


  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  # Select columns
  if (rawcols) {
    data_sf <-
      data_sf[, unique(c(initcols, colnames(df), "nuts1.code", "nuts1.name"))]
  } else {
    data_sf <-
      data_sf[, unique(c(colnames(df), "nuts1.code", "nuts1.name"))]
  }

  return(data_sf)
}
