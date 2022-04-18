#' Get 'comarcas' of Spain as `sf` polygons
#'
#' @description
#' Returns 'comarcas' of Spain as polygons,as provided by the
#' **INE** (Instituto Nacional de Estadistica).
#'
#' @source [INE: PC_Axis files](https://www.ine.es/ss/Satellite?c=Page&p=1254735116596&pagename=ProductosYServicios%2FPYSLayout&cid=1254735116596&L=1).
#'
#' @family political
#'
#' @param region A vector of names and/or codes for provinces or `NULL` to get
#'   all the comarcas., See **Details**.
#'
#' @param comarca A name or [`regex`][base::grep()] expression with the names of
#'   the required comarcas. `NULL` would not produce any filtering.
#'
#' @inheritParams esp_get_munic
#'
#' @inheritSection  esp_get_nuts About caching
#'
#' @inheritSection  esp_get_nuts  Displacing the Canary Islands
#'
#' @export
#'
#' @details
#'
#' 'Comarcas' (English equivalent: district, county, area or zone) does not
#' always have a formal legal status. They correspond mainly to natural areas
#' (valleys, river basins etc.) or even to historical regions or ancient
#' kingdoms.
#'
#' When using `region` you can use and mix names and NUTS codes
#' (levels 1, 2 or 3), ISO codes (corresponding to level 2 or 3) or
#' "cpro" (see [esp_codelist]).
#'
#' When calling a superior level (Province, Autonomous Community or NUTS1) ,
#' all the comarcas of that level would be added.
#'
#' ## Legal Notice
#'
#' The use of the information contained on the
#' [INE website](https://www.ine.es/en/index.htm) may be carried out by users or
#' re-use agents, at their own risk, and they will be the sole liable parties
#' in the case of having to answer to third parties due to damages arising
#' from such use.
#'
#' Read the [full legal notice](https://www.ine.es/ss/Satellite?L=1&c=Page&cid=1254735849170&p=1254735849170&pagename=Ayuda%2FINELayout)
#' for more info.
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' comarcas <- esp_get_comarca(moveCAN = FALSE)
#'
#' library(ggplot2)
#'
#' ggplot(comarcas) +
#'   geom_sf()
#'
#' # Comarcas of Castille and Leon
#'
#' comarcas_cyl <- esp_get_comarca("Castilla y Leon")
#'
#' ggplot(comarcas_cyl) +
#'   geom_sf(aes(fill = ine.prov.name)) +
#'   labs(fill = "Province")
#'
#' # Comarcas with Mountains or Alt(o,a) in the name
#'
#' comarcas_alto <- esp_get_comarca(
#'   comarca = "Montaña|Monte|Sierra|Alt",
#'   epsg = 3857
#' )
#'
#' ggplot(comarcas_alto) +
#'   geom_sf(aes(fill = ine.ccaa.name)) +
#'   geom_sf_text(aes(label = name), check_overlap = TRUE) +
#'   labs(fill = "CCAA")
#' }
#'
esp_get_comarca <- function(region = NULL,
                            comarca = NULL,
                            moveCAN = TRUE,
                            epsg = "4258",
                            update_cache = FALSE,
                            cache_dir = NULL,
                            verbose = FALSE) {
  init_epsg <- as.character(epsg)

  if (!init_epsg %in% c("4326", "4258", "3035", "3857")) {
    stop("epsg value not valid. It should be one of 4326, 4258, 3035 or 3857")
  }


  # Url
  api_entry <- "https://github.com/rOpenSpain/mapSpain/raw/sianedata/INE/"
  filename <- "esp_com_99.gpkg"


  data_sf <- esp_hlp_dwnload_sianedata(
    api_entry = api_entry,
    filename = filename,
    cache_dir = cache_dir,
    verbose = verbose,
    update_cache = update_cache,
    cache = TRUE
  )


  if (!is.null(comarca)) {
    comarca <- paste(comarca, collapse = "|")
    data_sf <- data_sf[grep(comarca, data_sf$name, ignore.case = TRUE), ]
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
      "The combination of region and/or comarca does ",
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
      penin <- data_sf[-grep("05", data_sf$codauto), ]
      can <- data_sf[grep("05", data_sf$codauto), ]

      # Move CAN
      can <- sf::st_sf(
        sf::st_drop_geometry(can),
        geom = sf::st_geometry(can) + offset,
        crs = sf::st_crs(can)
      )

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
    data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$COMAGR), ]

  return(data_sf)
}
