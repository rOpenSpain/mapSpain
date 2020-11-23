#' @title Get Provinces boundaries of Spain
#' @name esp_get_prov
#' @description Loads a simple feature (\code{sf}) object containing the
#' province boundaries of Spain.
#' @return A \code{POLYGON/POINT} object.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @seealso \link{esp_get_hex_prov}, \link{esp_get_nuts}, \link{esp_get_ccaa},
#' \link{esp_get_munic}, \link{esp_codelist}
#' @export
#'
#'
#'
#' @param prov A vector of names and/or codes for provinces
#'  or \code{NULL} to get all the provinces. See Details.
#' @param ... Additional parameters from \link{esp_get_nuts}.
#' @details When using \code{prov} you can use and mix names and NUTS codes
#' (levels 1, 2 or 3), ISO codes (corresponding to level 2 or 3) or
#' \code{cpro}.
#'
#' Ceuta and Melilla are considered as provinces on this dataset.
#'
#' When calling a superior level (Autonomous Community or NUTS1) , all the
#'  provinces of that level would be added.
#' @examples
#'
#' library(sf)
#'
#' # Random Provinces
#'
#' Random <-
#'   esp_get_prov(prov = c("Zamora",
#'                         "Palencia",
#'                         "ES-GR",
#'                         "ES521",
#'                         "01"))
#' plot(st_geometry(Random), col = hcl.colors(6))
#'
#' # All Provinces of a Zone plus an addition
#'
#' Mix <-
#'   esp_get_prov(prov = c("Noroeste",
#'                         "Castilla y Leon", "La Rioja"),
#'                resolution = "20")
#' plot(
#'   Mix[, "nuts1.code"],
#'   pal = hcl.colors(3),
#'   key.pos = NULL,
#'   main = NULL,
#'   border = "white"
#' )

esp_get_prov <- function(prov = NULL, ...) {
  params <- list(...)

  # Get region id

  prov <- prov[!is.na(prov)]


  region <- prov
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2prov(region)

    nuts_id <- unique(nuts_id)
    if (length(nuts_id) == 0)
      stop("region ",
           paste0("'", region, "'", collapse = ", "),
           " is not a valid name")
  }

  params$region <- nuts_id
  params$nuts_level <- 3


  data.sf <- do.call(mapSpain::esp_get_nuts,  params)

  data.sf$nuts3.code <- data.sf$NUTS_ID
  data.sf <- data.sf[, "nuts3.code"]

  # Get cpro

  df <- mapSpain::esp_codelist
  df <- unique(df[, c("nuts3.code", "cpro")])
  data.sf <- merge(data.sf, df, all.x = TRUE)
  data.sf <- data.sf[, "cpro"]

  # Merge Islands

  # Extract geom column
  names <- names(data.sf)

  which.geom <-
    which(vapply(data.sf, function(f)
      inherits(f, "sfc"), TRUE))

  nm <- names(which.geom)

  # Baleares

  if (any(data.sf$cpro %in% "07")) {
    clean <- data.sf[data.sf$cpro != "07", ]
    island <- data.sf[data.sf$cpro == "07", ]
    g <- sf::st_union(island)
    df <- unique(sf::st_drop_geometry(island))
    # Generate sf object
    new <- sf::st_as_sf(df, g)
    # Rename geometry to original value
    newnames <- names(new)
    newnames[newnames == "g"] <- nm
    colnames(new) <- newnames
    new <- sf::st_set_geometry(new, nm)
    data.sf <- rbind(clean, new)
  }

  # Las Palmas

  if (any(data.sf$cpro %in% "35")) {
    clean <- data.sf[data.sf$cpro != "35", ]
    island <- data.sf[data.sf$cpro == "35", ]
    g <- sf::st_union(island)
    df <- unique(sf::st_drop_geometry(island))
    # Generate sf object
    new <- sf::st_as_sf(df, g)
    # Rename geometry to original value
    newnames <- names(new)
    newnames[newnames == "g"] <- nm
    colnames(new) <- newnames
    new <- sf::st_set_geometry(new, nm)
    data.sf <- rbind(clean, new)
  }

  # Sta Cruz Tfe
  if (any(data.sf$cpro %in% "38")) {
    clean <- data.sf[data.sf$cpro != "38", ]
    island <- data.sf[data.sf$cpro == "38", ]
    g <- sf::st_union(island)
    df <- unique(sf::st_drop_geometry(island))
    # Generate sf object
    new <- sf::st_as_sf(df, g)
    # Rename geometry to original value
    newnames <- names(new)
    newnames[newnames == "g"] <- nm
    colnames(new) <- newnames
    new <- sf::st_set_geometry(new, nm)
    data.sf <- rbind(clean, new)
  }



  # Get df
  df <- dict_prov
  df <- df[, names(df) != "key"]

  data.sf <- merge(data.sf, df, all.x = TRUE)

  # Paste nuts2
  dfnuts <- mapSpain::esp_codelist
  dfnuts <-
    unique(dfnuts[, c("cpro",
                      "nuts2.code",
                      "nuts2.name",
                      "nuts1.code",
                      "nuts1.name")])
  data.sf <- merge(data.sf, dfnuts, all.x = TRUE)
  data.sf <-
    data.sf[, c(colnames(df),
                "nuts2.code",
                "nuts2.name",
                "nuts1.code",
                "nuts1.name")]

  # Order
  data.sf <- data.sf[order(data.sf$codauto, data.sf$cpro), ]

  return(data.sf)
}
