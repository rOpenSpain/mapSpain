#' Get Autonomous Communities of Spain as [`sf`][sf::st_sf] `POLYGON` or `POINT`
#'
#' @description
#' Returns
#' [Autonomous Communities of
#' Spain](https://en.wikipedia.org/wiki/Autonomous_communities_of_Spain) as
#' `sf` `POLYGON` or `POINT` at a specified scale.
#'
#' - [esp_get_ccaa()] uses GISCO (Eurostat) as source. Please use
#'   [giscoR::gisco_attributions()]
#'
#' @family political
#'
#' @rdname esp_get_ccaa
#'
#' @name esp_get_ccaa
#'
#' @return A [`sf`][sf::st_sf] object specified by `spatialtype`.
#'
#'
#' @export
#'
#' @param ccaa A vector of names and/or codes for autonomous communities
#'   or `NULL` to get all the autonomous communities. See **Details**.
#'
#' @inheritDotParams esp_get_nuts -nuts_level -region
#'
#' @details
#' When using `ccaa` you can use and mix names and NUTS codes (levels 1 or 2),
#' ISO codes (corresponding to level 2) or `codauto` (see [esp_codelist]).
#' Ceuta and Melilla are considered as Autonomous Communities on this function.
#'
#' When calling a NUTS1 level, all the Autonomous Communities of that level
#' would be added.
#'
#' @inheritSection  esp_get_nuts  About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @examples
#' ccaa <- esp_get_ccaa()
#'
#' library(ggplot2)
#'
#' ggplot(ccaa) +
#'   geom_sf()
#'
#' # Random CCAA
#' Random <- esp_get_ccaa(ccaa = c(
#'   "Euskadi",
#'   "Catalunya",
#'   "ES-EX",
#'   "Canarias",
#'   "ES52",
#'   "01"
#' ))
#'
#'
#' ggplot(Random) +
#'   geom_sf(aes(fill = codauto), show.legend = FALSE) +
#'   geom_sf_label(aes(label = codauto), alpha = 0.3)
#'
#' # All CCAA of a Zone plus an addition
#'
#' Mix <-
#'   esp_get_ccaa(ccaa = c("La Rioja", "Noroeste"))
#'
#' ggplot(Mix) +
#'   geom_sf()
#'
#' # Combine with giscoR to get countries
#' \donttest{
#'
#' library(giscoR)
#' library(sf)
#'
#' res <- 20 # Set same resoluion
#'
#' europe <- gisco_get_countries(resolution = res)
#' ccaa <- esp_get_ccaa(moveCAN = FALSE, resolution = res)
#'
#' # Transform to same CRS
#' europe <- st_transform(europe, 3035)
#' ccaa <- st_transform(ccaa, 3035)
#'
#' ggplot(europe) +
#'   geom_sf(fill = "#DFDFDF", color = "#656565") +
#'   geom_sf(data = ccaa, fill = "#FDFBEA", color = "#656565") +
#'   coord_sf(
#'     xlim = c(23, 74) * 10e4,
#'     ylim = c(14, 55) * 10e4
#'   ) +
#'   theme(panel.background = element_rect(fill = "#C7E7FB"))
#' }
esp_get_ccaa <- function(ccaa = NULL, moveCAN = TRUE, ...) {
  params <- list(...)

  # Get region id

  ccaa <- ccaa[!is.na(ccaa)]

  region <- ccaa
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2ccaa(region)

    nuts_id <- unique(nuts_id)
  }

  params$region <- nuts_id
  params$nuts_level <- 2
  params$moveCAN <- moveCAN

  data_sf <- do.call(mapSpain::esp_get_nuts, params)

  data_sf$nuts2.code <- data_sf$NUTS_ID
  data_sf <- data_sf[, "nuts2.code"]

  # Get df
  df <- dict_ccaa
  df <- df[, names(df) != "key"]

  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts1
  dfnuts <- mapSpain::esp_codelist
  dfnuts <- unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])

  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

  data_sf <- data_sf[, unique(c(colnames(df), "nuts1.code", "nuts1.name"))]

  # Order
  data_sf <- data_sf[order(data_sf$codauto), ]

  data_sf
}


#' @rdname esp_get_ccaa
#' @name esp_get_ccaa_siane
#'
#' @description
#' - [esp_get_ccaa_siane()] uses CartoBase ANE as source, provided by
#'   Instituto Geografico Nacional (IGN), <http://www.ign.es/web/ign/portal>.
#'   Years available are 2005 up to today.
#'
#' @source
#' IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#' @export
#'
#' @param year Release year. See [esp_get_nuts()] for [esp_get_ccaa()] and
#'   **Details** for [esp_get_ccaa_siane()].
#'
#' @param resolution Resolution of the `POLYGON`. Values available are
#'   `3`, `6.5` or `10`.
#'
#' @param rawcols Logical. Setting this to `TRUE` would add the raw columns of
#'   the resulting object as provided by IGN.
#'
#' @inheritParams esp_get_nuts
#'
#' @details
#' On [esp_get_ccaa_siane()], `year` could be passed as a single year (`YYYY`
#' format, as end of year) or as a specific date (`YYYY-MM-DD` format).
#' Historical information starts as of 2005.
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
