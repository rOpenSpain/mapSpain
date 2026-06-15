#' Rivers and wetlands of Spain from SIANE
#'
#' @description
#' Object representing rivers, lagoons, reservoirs and wetlands of Spain.
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.
#'
#' @param resolution `r lifecycle::badge("deprecated")` character string.
#'   Ignored, resolution `3` (the most detailed) will always be provided.
#' @param spatialtype `r lifecycle::badge("deprecated")` character string.
#'   Use [esp_get_wetlands()] instead of `"spatialtype"` for wetlands.
#' @param name Character string or [`regex`][base::grep()] expression. Name of
#'   the element(s) to be extracted.
#' @inheritParams esp_get_ccaa_siane
#' @inherit esp_get_ccaa_siane return source
#' @family natural
#' @encoding UTF-8
#' @rdname esp_get_landwater
#' @name esp_get_landwater
#'
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # Use of regex
#'
#' regex1 <- esp_get_rivers(name = "Tajo|Segura")
#' unique(regex1$rotulo)
#'
#' regex2 <- esp_get_rivers(name = "Tajo$| Segura")
#' unique(regex2$rotulo)
#'
#' # See the difference
#'
#' # Rivers in Spain
#' iberian <- giscoR::gisco_get_countries(
#'   country = c("ES", "PT", "FR"), resolution = 3
#' )
#'
#' main_rivers <- esp_get_rivers() |>
#'   dplyr::filter(t_rio == 1)
#'
#' library(ggplot2)
#'
#' ggplot(iberian) +
#'   geom_sf() +
#'   geom_sf(data = main_rivers, color = "skyblue", linewidth = 2) +
#'   coord_sf(
#'     xlim = c(-10, 5),
#'     ylim = c(35, 44)
#'   )
#'
#' # Wetlands in South-West Andalucia
#' and <- esp_get_prov(c("Huelva", "Sevilla", "Cadiz"))
#' wetlands <- esp_get_wetlands()
#' wetlands_south <- sf::st_filter(wetlands, and)
#'
#' ggplot(and) +
#'   geom_sf() +
#'   geom_sf(
#'     data = wetlands_south, fill = "skyblue",
#'     color = "skyblue", alpha = 0.5
#'   )
#' }
esp_get_rivers <- function(
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = deprecated(),
  spatialtype = c("line", "area"),
  moveCAN = TRUE,
  name = NULL
) {
  init_epsg <- validate_epsg(epsg)
  spatialtype <- match_arg_pretty(spatialtype)

  if (lifecycle::is_present(resolution)) {
    lifecycle::deprecate_soft(
      when = "1.0.0",
      what = "mapSpain::esp_get_rivers(resolution)",
      details = "Resolution `3` (most detailed) will always be used."
    )
  }

  if (spatialtype == "area") {
    lifecycle::deprecate_soft(
      when = "1.0.0",
      what = "mapSpain::esp_get_rivers(spatialtype)",
      details = "Please use `esp_get_wetlands()` instead."
    )

    cli::cli_alert_info(
      "Redirecting the arguments to {.fn mapSpain::esp_get_wetlands}."
    )

    data_sf <- esp_get_wetlands(
      epsg = epsg,
      cache = cache,
      update_cache = update_cache,
      cache_dir = cache_dir,
      verbose = verbose,
      moveCAN = moveCAN,
      name = name
    )
    return(data_sf)
  }

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_hidro_rio_l_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_hidro_rio_l_y.gpkg"
  )

  data_sf <- read_siane_files(
    c(url_penin, url_can),
    cache = cache,
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose,
    codauto = c("XX", "05")
  )
  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf <- merge_db_value_desc(
    data_sf,
    "persistenciahidrologica",
    c(
      "pers_hidro",
      "pers_hidro_desc"
    )
  )
  data_sf <- merge_db_value_desc(
    data_sf,
    "origenhidrografico",
    c(
      "orig_hidro",
      "orig_hidro_desc"
    )
  )

  # Move the Canary Islands.
  data_sf <- move_can(data_sf, moveCAN)
  data_sf <- data_sf[, setdiff(names(data_sf), "codauto")]

  # Merge names
  river_names <- get_river_names(
    update_cache = update_cache,
    cache_dir = cache_dir
  )
  river_names$id_rio <- river_names$PFAFRIO
  river_names <- river_names[, c("id_rio", "NOM_RIO")]

  data_sf <- merge(data_sf, river_names, all.x = TRUE)
  data_sf <- sanitize_transform_sf(data_sf, init_epsg)

  name <- ensure_null(name)
  if (!is.null(name)) {
    getrows1 <- grep(name, data_sf$rotulo)
    getrows2 <- grep(name, data_sf$NOM_RIO)
    getrows <- unique(c(getrows1, getrows2))
    data_sf <- data_sf[getrows, ]

    if (nrow(data_sf) == 0) {
      return(return_empty_name_sf(data_sf, name))
    }
  }

  # Names and order
  name_order <- c("id_rio", "rotulo", "NOM_RIO")
  data_sf <- data_sf[, unique(c(name_order, colnames(data_sf)))]

  data_sf <- data_sf[order(data_sf$t_rio, data_sf$id_rio), ]
  data_sf
}

#' @rdname esp_get_landwater
#' @export
esp_get_wetlands <- function(
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  moveCAN = TRUE,
  name = NULL
) {
  init_epsg <- validate_epsg(epsg)

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_hidro_rio_a_x.gpkg"
  )

  data_sf <- read_siane_files(
    url_penin,
    cache = cache,
    update_cache = update_cache,
    cache_dir = cache_dir,
    verbose = verbose
  )
  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf <- merge_db_value_desc(
    data_sf,
    "persistenciahidrologica",
    c(
      "pers_hidro",
      "pers_hidro_desc"
    )
  )
  data_sf <- merge_db_value_desc(
    data_sf,
    "tiporioa",
    c(
      "t_rio",
      "t_rio_desc"
    )
  )

  name <- ensure_null(name)
  if (!is.null(name)) {
    data_sf <- data_sf[grepl(name, data_sf$rotulo), ]

    if (nrow(data_sf) == 0) {
      return(return_empty_name_sf(data_sf, name))
    }
  }

  data_sf <- data_sf[order(data_sf$id_ipe), ]

  data_sf <- sanitize_transform_sf(data_sf, init_epsg)
  data_sf
}

#' Helper function to get river names
#' @noRd
get_river_names <- function(update_cache = FALSE, cache_dir = NULL) {
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/",
    "data-raw/rivernames.rda"
  )

  db <- download_rds(
    url,
    subdir = "siane",
    update_cache = update_cache,
    cache_dir = cache_dir
  )
  if (is.null(db)) {
    return(NULL)
  }

  tibble::as_tibble(db)
}
