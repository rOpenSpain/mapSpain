#' Municipalities of Spain - GISCO
#'
#' @description
#' This dataset shows boundaries of municipalities in Spain.
#'
#' @encoding UTF-8
#' @family political
#' @family municipalities
#' @family gisco
#' @inheritParams esp_get_nuts
#' @inherit giscoR::gisco_get_lau
#' @export
#'
#' @param year year character string or number. Release year of the file. See
#'   [giscoR::gisco_get_lau()] and [giscoR::gisco_get_communes()] for valid
#'   values.
#' @param munic character string. A name or [`regex`][base::grep()] expression
#'   with the names of the required municipalities. `NULL` would return all
#'   municipalities.
#' @param cache `r lifecycle::badge("deprecated")`. This argument is
#'   deprecated, the dataset would be always downloaded to the `cache_dir`.
#' @seealso [giscoR::gisco_get_lau()], [giscoR::gisco_get_communes()].
#'
#' @details
#' When using `region` you can use and mix names and NUTS codes (levels 1, 2 or
#' 3), ISO codes (corresponding to level 2 or 3) or `"cpro"`
#' (see [esp_codelist]).
#'
#' When calling a higher level (province, CCAA or NUTS1), all the municipalities
#' of that level would be added.
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # The Spanish Lapland:
#' # https://en.wikipedia.org/wiki/Celtiberian_Range
#'
#' # Get munics
#' spanish_laplad <- esp_get_munic(
#'   year = 2023,
#'   region = c(
#'     "Cuenca", "Teruel",
#'     "Zaragoza", "Guadalajara",
#'     "Soria", "Burgos",
#'     "La Rioja"
#'   )
#' )
#'
#' breaks <- sort(c(0, 5, 10, 50, 100, 200, 500, 1000, Inf))
#' spanish_laplad$dens_breaks <- cut(spanish_laplad$POP_DENS_2023, breaks,
#'   dig.lab = 20
#' )
#'
#' cut_labs <- prettyNum(breaks, big.mark = " ")[-1]
#' cut_labs[length(breaks)] <- "> 1000"
#'
#' library(ggplot2)
#' ggplot(spanish_laplad) +
#'   geom_sf(aes(fill = dens_breaks), color = "grey30", linewidth = 0.1) +
#'   scale_fill_manual(
#'     values = hcl.colors(length(breaks) - 1, "Spectral"), na.value = "black",
#'     name = "people per sq. kilometer",
#'     labels = cut_labs,
#'     guide = guide_legend(
#'       direction = "horizontal",
#'       nrow = 1
#'     )
#'   ) +
#'   theme_void() +
#'   labs(
#'     title = "The Spanish Lapland",
#'     caption = giscoR::gisco_attributions()
#'   ) +
#'   theme(
#'     text = element_text(colour = "white"),
#'     plot.background = element_rect(fill = "grey2"),
#'     plot.title = element_text(hjust = 0.5),
#'     plot.subtitle = element_text(hjust = 0.5, face = "bold"),
#'     plot.caption = element_text(
#'       color = "grey60", hjust = 0.5, vjust = 0,
#'       margin = margin(t = 5, b = 10)
#'     ),
#'     legend.position = "bottom",
#'     legend.title.position = "top",
#'     legend.text.position = "bottom",
#'     legend.key.height = unit(0.5, "lines"),
#'     legend.key.width = unit(1, "lines")
#'   )
#' }
esp_get_munic <- function(
  year = 2024,
  epsg = 4258,
  cache = deprecated(),
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  region = NULL,
  munic = NULL,
  moveCAN = TRUE,
  ext = "gpkg"
) {
  # Dispatch everything to giscoR except EPSG, that is specific
  init_epsg <- match_arg_pretty(epsg, c("4258", "4326", "3035", "3857"))
  gisco_epsg <- ifelse(epsg == "4258", "4326", init_epsg)
  cache_dir <- create_cache_dir(cache_dir)

  if (as.character(year) >= "2011") {
    data_sf <- giscoR::gisco_get_lau(
      year = year,
      epsg = gisco_epsg,
      cache = cache, # Deprecated...
      update_cache = update_cache,
      cache_dir = cache_dir,
      verbose = verbose,
      country = "ES",
      ext = ext
    )
  } else {
    data_sf <- giscoR::gisco_get_communes(
      year = year,
      epsg = gisco_epsg,
      cache = cache, # Deprecated...
      update_cache = update_cache,
      cache_dir = cache_dir,
      verbose = verbose,
      country = "ES",
      spatialtype = "RG",
      ext = ext
    )
  }

  if (is.null(data_sf)) {
    return(NULL)
  }
  # Some files does not have crs (??)
  file_epsg <- ensure_null(sf::st_crs(data_sf)$wkt)

  if (is.null(file_epsg)) {
    data_sf <- sf::st_set_crs(data_sf, sf::st_crs(as.numeric(gisco_epsg)))
  }

  # Id management
  id_col <- intersect(c("GISCO_ID", "LAU_ID", "NSI_CODE"), names(data_sf))[1]
  data_sf$LAU_CODE <- gsub("\\D+", "", data_sf[[id_col]])

  # Name management
  id_name <- intersect(c("LAU_NAME", "COMM_NAME", "SABE_NAME"), names(data_sf))[
    1
  ]
  data_sf$name <- data_sf[[id_name]]

  data_sf$cpro <- substr(data_sf$LAU_CODE, 1, 2)
  data_sf$cmun <- substr(data_sf$LAU_CODE, 3, 8)

  add_codes <- unique(mapSpain::esp_codelist[, c(
    "codauto",
    "ine.ccaa.name",
    "cpro",
    "ine.prov.name"
  )])

  data_sf <- merge(
    data_sf,
    add_codes,
    by = "cpro",
    all.x = TRUE,
    no.dups = TRUE
  )

  init_nm <- names(data_sf)
  first_names <- c(
    "codauto",
    "ine.ccaa.name",
    "cpro",
    "ine.prov.name",
    "cmun",
    "name",
    "LAU_CODE"
  )
  keep_n <- unique(c(first_names, init_nm))
  data_sf <- data_sf[, keep_n]

  # Filter munics
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  munic <- ensure_null(munic)

  if (!is.null(munic)) {
    munic <- paste(munic, collapse = "|")
    data_sf <- data_sf[grep(munic, data_sf$name, ignore.case = TRUE), ]
  }
  region <- ensure_null(region)

  if (!is.null(region)) {
    tonuts <- convert_to_nuts_prov(region)
    # toprov
    df <- unique(mapSpain::esp_codelist[, c("nuts3.code", "cpro")])
    df <- df[df$nuts3.code %in% tonuts, "cpro"]
    toprov <- unique(df$cpro)
    data_sf <- data_sf[data_sf$cpro %in% toprov, ]
  }

  if (nrow(data_sf) == 0) {
    cli::cli_alert_warning(
      paste0(
        "The combination of {.arg region} and/or {.arg munic} does not ",
        "return any result"
      )
    )
    cli::cli_alert_info("Returning empty {.cls sf} object.")
    return(data_sf)
  }

  # Move CAN
  data_sf <- move_can(data_sf, moveCAN)

  # Back and finish
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$cmun), ]
  data_sf <- sanitize_sf(data_sf)
  data_sf
}
