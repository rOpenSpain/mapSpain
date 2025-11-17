#' Get Provinces of Spain as [`sf`][sf::st_sf] `POLYGON` or `POINT`
#'
#' @description
#' Returns
#' [provinces of Spain](https://en.wikipedia.org/wiki/Provinces_of_Spain)
#' as `POLYGON` or `POINT` at a specified scale.
#'
#' - [esp_get_prov()] uses GISCO (Eurostat) as source. Please use
#'   [giscoR::gisco_attributions()]
#'
#'
#' @family political
#'
#' @rdname esp_get_prov
#' @name esp_get_prov
#'
#' @return A [`sf`][sf::st_sf] object specified by `spatialtype`.
#'
#'
#' @export
#'
#' @param prov A vector of names and/or codes for provinces or `NULL` to get all
#'   the provinces. See **Details**.
#'
#' @inheritDotParams esp_get_nuts -nuts_level -region
#'
#' @details
#' When using `prov` you can use and mix names and NUTS codes (levels 1, 2 or
#' 3), ISO codes (corresponding to level 2 or 3) or "cpro" (see
#' [esp_codelist]).
#'
#' Ceuta and Melilla are considered as provinces on this dataset.
#'
#' When calling a higher level (Autonomous Community or NUTS1), all the
#' provinces of that level would be added.
#'
#' @inheritSection  esp_get_nuts  About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @examples
#' prov <- esp_get_prov()
#'
#' library(ggplot2)
#'
#' ggplot(prov) +
#'   geom_sf() +
#'   theme_void()
#'
#' \donttest{
#' # Random Provinces
#'
#' Random <- esp_get_prov(prov = c(
#'   "Zamora", "Palencia", "ES-GR",
#'   "ES521", "01"
#' ))
#'
#'
#' ggplot(Random) +
#'   geom_sf(aes(fill = codauto), show.legend = FALSE, alpha = 0.5) +
#'   scale_fill_manual(values = hcl.colors(
#'     nrow(Random), "Spectral"
#'   )) +
#'   theme_minimal()
#'
#'
#' # All Provinces of a Zone plus an addition
#'
#' Mix <- esp_get_prov(prov = c(
#'   "Noroeste",
#'   "Castilla y Leon", "La Rioja"
#' ))
#'
#' Mix$CCAA <- esp_dict_region_code(
#'   Mix$codauto,
#'   origin = "codauto"
#' )
#'
#' ggplot(Mix) +
#'   geom_sf(aes(fill = CCAA), alpha = 0.5) +
#'   scale_fill_discrete(type = hcl.colors(5, "Temps")) +
#'   theme_classic()
#'
#' # ISO codes available
#'
#' allprovs <- esp_get_prov()
#'
#' ggplot(allprovs) +
#'   geom_sf(fill = NA) +
#'   geom_sf_text(aes(label = iso2.prov.code),
#'     check_overlap = TRUE,
#'     fontface = "bold"
#'   ) +
#'   theme_void()
#' }
esp_get_prov <- function(prov = NULL, moveCAN = TRUE, ...) {
  params <- list(...)

  # Get region id

  prov <- prov[!is.na(prov)]


  region <- prov
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2prov(region)

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
  params$nuts_level <- 3
  params$moveCAN <- moveCAN

  data_sf <- do.call(mapSpain::esp_get_nuts, params)

  # Avoid warning on union
  initcrs <- sf::st_crs(data_sf)
  data_sf <- sf::st_transform(data_sf, 3035)


  data_sf$nuts3.code <- data_sf$NUTS_ID
  data_sf <- data_sf[, "nuts3.code"]

  # Get cpro

  df <- mapSpain::esp_codelist
  df <- unique(df[, c("nuts3.code", "cpro")])
  data_sf <- merge(data_sf, df, all.x = TRUE)
  data_sf <- data_sf[, "cpro"]

  # Merge Islands

  # Extract geom column
  names <- names(data_sf)

  which.geom <-
    which(vapply(data_sf, function(f) {
      inherits(f, "sfc")
    }, TRUE))

  nm <- names(which.geom)

  # Baleares

  if (any(data_sf$cpro %in% "07")) {
    clean <- data_sf[data_sf$cpro != "07", ]
    island <- data_sf[data_sf$cpro == "07", ]
    g <- sf::st_union(island)
    df <- unique(sf::st_drop_geometry(island))
    # Generate sf object
    new <- sf::st_as_sf(df, g)
    # Rename geometry to original value
    newnames <- names(new)
    newnames[newnames == "g"] <- nm
    colnames(new) <- newnames
    new <- sf::st_set_geometry(new, nm)
    data_sf <- rbind(clean, new)
  }

  # Las Palmas

  if (any(data_sf$cpro %in% "35")) {
    clean <- data_sf[data_sf$cpro != "35", ]
    island <- data_sf[data_sf$cpro == "35", ]
    g <- sf::st_union(island)
    df <- unique(sf::st_drop_geometry(island))
    # Generate sf object
    new <- sf::st_as_sf(df, g)
    # Rename geometry to original value
    newnames <- names(new)
    newnames[newnames == "g"] <- nm
    colnames(new) <- newnames
    new <- sf::st_set_geometry(new, nm)
    data_sf <- rbind(clean, new)
  }

  # Sta Cruz Tfe
  if (any(data_sf$cpro %in% "38")) {
    clean <- data_sf[data_sf$cpro != "38", ]
    island <- data_sf[data_sf$cpro == "38", ]
    g <- sf::st_union(island)
    df <- unique(sf::st_drop_geometry(island))
    # Generate sf object
    new <- sf::st_as_sf(df, g)
    # Rename geometry to original value
    newnames <- names(new)
    newnames[newnames == "g"] <- nm
    colnames(new) <- newnames
    new <- sf::st_set_geometry(new, nm)
    data_sf <- rbind(clean, new)
  }


  # Get df
  df <- dict_prov
  df <- df[, names(df) != "key"]

  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts2
  dfnuts <- mapSpain::esp_codelist
  dfnuts <-
    unique(dfnuts[, c(
      "cpro",
      "nuts2.code",
      "nuts2.name",
      "nuts1.code",
      "nuts1.name"
    )])
  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)
  data_sf <- data_sf[, c(
    colnames(df), "nuts2.code", "nuts2.name",
    "nuts1.code", "nuts1.name"
  )]

  # Order
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]

  # Transform

  data_sf <- sf::st_transform(data_sf, initcrs)

  return(data_sf)
}


#' @rdname esp_get_prov
#' @name esp_get_prov_siane
#'
#'
#' @description
#' - [esp_get_prov_siane()] uses CartoBase ANE as source, provided by Instituto
#'   Geografico Nacional (IGN), <http://www.ign.es/web/ign/portal>. Years
#'   available are 2005 up to today.
#'
#' @source
#' IGN data via a custom CDN (see
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata>).
#'
#' @export
#'
#' @param year Release year. See [esp_get_nuts()] for [esp_get_prov()] and
#'   **Details** for [esp_get_prov_siane()].
#'
#' @inheritParams esp_get_ccaa
#'
#' @details
#' On [esp_get_prov_siane()], `year` could be passed as a single year ("YYYY"
#' format, as end of year) or as a specific date ("YYYY-MM-DD" format).
#' Historical information starts as of 2005.
esp_get_prov_siane <- function(prov = NULL, year = Sys.Date(), epsg = "4258",
                               cache = TRUE, update_cache = FALSE,
                               cache_dir = NULL, verbose = FALSE,
                               resolution = "3", moveCAN = TRUE,
                               rawcols = FALSE) {
  init_epsg <- as.character(epsg)
  year <- as.character(year)


  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }

  # Get Data from SIANE
  data_sf <- esp_hlp_get_siane(
    "prov", resolution, cache, cache_dir,
    update_cache, verbose, year
  )


  colnames_init <- colnames(sf::st_drop_geometry(data_sf))


  data_sf$cpro <- data_sf$id_prov

  if (!is.null(prov)) {
    tonuts <- esp_hlp_all2prov(prov)
    # toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)
    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  if (nrow(data_sf) == 0) {
    stop(
      "provs '",
      paste0(prov, collapse = "', "),
      "' does not return any result"
    )
  }

  # Get df
  df <- dict_prov
  df <- df[, names(df) != "key"]

  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts2
  dfnuts <- mapSpain::esp_codelist
  dfnuts <- unique(dfnuts[, c(
    "cpro", "nuts2.code", "nuts2.name", "nuts1.code",
    "nuts1.name"
  )])
  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)


  # Move can

  # Checks
  moving <- FALSE
  moving <- isTRUE(moveCAN) | length(moveCAN) > 1

  if (moving) {
    if (length(grep("05", data_sf$codauto)) > 0) {
      penin <- data_sf[-grep("05", data_sf$codauto), ]
      can <- data_sf[grep("05", data_sf$codauto), ]

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


  # Order
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]

  namesend <- unique(c(
    colnames_init,
    colnames(esp_get_prov())
  ))

  # Review this error, can't fully reproduce

  namesend <- namesend[namesend %in% names(data_sf)]

  data_sf <- data_sf[, namesend]


  if (isFALSE(rawcols)) {
    nm <- colnames(esp_get_prov())
    nm <- nm[nm %in% colnames(data_sf)]

    data_sf <- data_sf[, nm]
  }

  return(data_sf)
}
