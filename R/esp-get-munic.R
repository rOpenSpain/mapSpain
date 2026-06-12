#' Municipalities of Spain from GISCO
#'
#' @description
#' Get boundaries of municipalities in Spain.
#'
#' @details
#' When using `region` you can use and mix names and NUTS codes (levels 1, 2 or
#' 3), ISO codes (corresponding to level 2 or 3) or `"cpro"`
#' (see [esp_codelist]).
#'
#' When calling a higher level (province, Autonomous Community or NUTS1), all
#' the municipalities of that level will be added.
#'
#' @param year Year character string or number. Release year of the file. See
#'   [giscoR::gisco_get_lau()] and [giscoR::gisco_get_communes()] for valid
#'   values.
#' @param munic Character string. A name or [`regex`][base::grep()] expression
#'   with the names of the required municipalities. Use `NULL` to return all
#'   municipalities.
#' @param cache `r lifecycle::badge("deprecated")`. This argument is
#'   deprecated, the dataset will always be downloaded to the `cache_dir`.
#' @inheritParams esp_get_nuts
#' @inherit giscoR::gisco_get_lau return source
#'
#' @note
#' Please check the download and usage provisions on
#' [giscoR::gisco_attributions()].
#'
#' @seealso
#' - [giscoR::gisco_get_lau()].
#' - [giscoR::gisco_get_communes()].
#'
#' @family political
#' @family municipalities
#' @family gisco
#' @encoding UTF-8
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # The Spanish Lapland:
#' # https://en.wikipedia.org/wiki/Celtiberian_Range
#'
#' # Get municipalities.
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
  # Dispatch to giscoR and handle the package-specific EPSG value locally.
  init_epsg <- validate_epsg(epsg, c("4258", "4326", "3035", "3857"))
  gisco_epsg <- ifelse(epsg == "4258", "4326", init_epsg)
  cache_dir <- create_cache_dir(cache_dir)

  if (as.character(year) >= "2011") {
    data_sf <- giscor_get_lau(
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
  # Some files do not provide a CRS.
  file_epsg <- ensure_null(sf::st_crs(data_sf)$wkt)

  if (is.null(file_epsg)) {
    data_sf <- sf::st_set_crs(data_sf, sf::st_crs(as.numeric(gisco_epsg)))
  }

  id_col <- intersect(c("GISCO_ID", "LAU_ID", "NSI_CODE"), names(data_sf))[1]
  id_name <- intersect(c("LAU_NAME", "COMM_NAME", "SABE_NAME"), names(data_sf))[
    1
  ]

  data_sf <- add_municipal_metadata(
    data_sf,
    id_col,
    id_name,
    clean_id = TRUE,
    validate_cpro = FALSE
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

  data_sf <- filter_by_name_pattern(data_sf, munic, "name")
  data_sf <- filter_by_cpro_region(data_sf, region)

  if (nrow(data_sf) == 0) {
    return(return_empty_combination_sf(data_sf, "munic"))
  }

  # Move the Canary Islands.
  data_sf <- move_can(data_sf, moveCAN)

  # Restore and finish geometries.
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro, data_sf$cmun), ]
  data_sf <- sanitize_sf(data_sf)
  data_sf
}

#' Wrap for mocking
#' @noRd
giscor_get_lau <- function(...) {
  giscoR::gisco_get_lau(...)
}
