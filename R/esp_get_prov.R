#' Provinces of Spain - GISCO
#'
#' @description
#' Returns
#' [provinces of Spain](https://en.wikipedia.org/wiki/Provinces_of_Spain)
#' as `POLYGON` or `POINT` at a specified scale.
#'
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
    nuts_id <- nuts_id[!is.na(nuts_id)]
    if (length(nuts_id) == 0) {
      cli::cli_abort(
        "{.arg prov = {prov}} {?is/are} not valid."
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
    which(vapply(
      data_sf,
      function(f) {
        inherits(f, "sfc")
      },
      TRUE
    ))

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
    colnames(df),
    "nuts2.code",
    "nuts2.name",
    "nuts1.code",
    "nuts1.name"
  )]

  # Order
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]

  # Transform

  data_sf <- sf::st_transform(data_sf, initcrs)

  data_sf
}
