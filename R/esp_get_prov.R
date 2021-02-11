#' @title Get Provinces boundaries of Spain
#' @name esp_get_prov
#' @description Loads a simple feature (\code{sf}) object containing the
#' province boundaries of Spain.
#'
#' \code{esp_get_prov} uses GISCO (Eurostat) as source
#'
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
#' When calling a superior level (Autonomous Community or NUTS1) ,
#' all the provinces of that level would be added.
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

  # Avoid warning on union
  initcrs <- sf::st_crs(data.sf)
  data.sf <- sf::st_transform(data.sf, 3035)


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

  # Transform

  data.sf <- sf::st_transform(data.sf, initcrs)

  return(data.sf)
}


#' @rdname esp_get_prov
#' @description \code{esp_get_prov_siane} use CartoBase ANE as source,
#' provided by Instituto Geografico Nacional (IGN),
#' \href{http://www.ign.es/web/ign/portal}{ign.es}. Years available are
#' 2005 up to today.
#' @source IGN data via a custom CDN (see
#' \url{https://github.com/rOpenSpain/mapSpain/tree/sianedata}).
#' @export
#'
#'
#' @param resolution Resolution of the polygon. Values available are
#' \code{"3", "6.5"} or  \code{"10"}.
#' @param rawcols Logical. Setting this to \code{TRUE} would add the raw
#' columns of the dataset provided by IGN.
#' @param year,epsg,cache,update_cache,cache_dir,verbose,moveCAN
#' See \code{\link{esp_get_nuts}}. See Details for \code{year}.
#'
#' @details
#' On \code{esp_get_prov_siane}, \code{year} could be passed as a single
#' year ("YYYY" format, as end of year) or as a specific
#' date ("YYYY-MM-DD" format). Historical information starts as of 2005.

esp_get_prov_siane <- function(prov = NULL,
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
  data.sf <- esp_hlp_get_siane("prov",
                               resolution,
                               cache,
                               cache_dir,
                               update_cache,
                               verbose,
                               year)


  colnames_init <- colnames(sf::st_drop_geometry(data.sf))


  data.sf$cpro <- data.sf$id_prov

  if (!is.null(prov)) {
    tonuts <- esp_hlp_all2prov(prov)
    #toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df)
    data.sf <- data.sf[data.sf$cpro %in% toprov, ]
  }

  if (nrow(data.sf) == 0) {
    stop("provs '",
         paste0(prov, collapse = "', "),
         "' does not return any result")
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
      PENIN <- data.sf[-grep("05", data.sf$codauto), ]
      CAN <- data.sf[grep("05", data.sf$codauto), ]

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


  # Order
  data.sf <- data.sf[order(data.sf$codauto, data.sf$cpro), ]

  namesend <- unique(c(colnames_init,
                       colnames(esp_get_prov())))

  data.sf <- data.sf[, namesend]


  if (isFALSE(rawcols)) {
    data.sf <- data.sf[, colnames(esp_get_prov())]
  }

  return(data.sf)
}
