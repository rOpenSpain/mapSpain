#' Municipalities of Spain - SIANE
#'
#' @encoding UTF-8
#' @family political
#' @family siane
#' @family municipalities
#' @inheritParams esp_get_ccaa_siane
#' @inheritParams esp_get_capimun
#' @inheritParams esp_get_nuts
#' @inherit esp_get_munic description
#' @inherit esp_get_capimun details return source
#' @export
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' # Municipalities that have changed in the past: three cuts
#' munis2005 <- esp_get_munic_siane(year = 2005, rawcols = TRUE)
#' munis2015 <- esp_get_munic_siane(year = 2015, rawcols = TRUE)
#' munis2024 <- esp_get_munic_siane(year = 2024, rawcols = TRUE)
#'
#' # manipulate
#' library(dplyr)
#' allmunis_unique <- bind_rows(munis2005, munis2015, munis2024) |>
#'   distinct()
#'
#' id_all <- allmunis_unique |>
#'   sf::st_drop_geometry() |>
#'   group_by(id_ine, name) |>
#'   count() |>
#'   ungroup() |>
#'   arrange(desc(n)) |>
#'   slice_head(n = 1) |>
#'   glimpse()
#'
#' library(ggplot2)
#' allmunis_unique |>
#'   filter(id_ine == id_all$id_ine) |>
#'   ggplot() +
#'   geom_sf(aes(fill = as.factor(fecha_alta)),
#'     alpha = 0.7,
#'     show.legend = FALSE
#'   ) +
#'   scale_fill_viridis_d() +
#'   facet_wrap(~fecha_alta) +
#'   labs(
#'     title = id_all$name,
#'     subtitle = "Changes on boundaries over time",
#'     fill = ""
#'   )
#' }
esp_get_munic_siane <- function(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = c(3, 6.5, 10),
  region = NULL,
  munic = NULL,
  moveCAN = TRUE,
  rawcols = FALSE
) {
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))
  res <- match_arg_pretty(resolution)
  res <- gsub("6.5", "6m5", res)

  url_penin <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_",
    res,
    "_admin_muni_a_x.gpkg"
  )

  url_can <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_",
    res,
    "_admin_muni_a_y.gpkg"
  )

  # Not cached are read from url
  if (!cache) {
    msg <- paste0("{.url ", url_penin, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_penin <- read_geo_file_sf(url_penin)

    msg <- paste0("{.url ", url_can, "}.")
    make_msg("info", verbose, "Reading from", msg)

    data_sf_can <- read_geo_file_sf(url_can)

    data_sf <- rbind_fill(list(data_sf_penin, data_sf_can))
  } else {
    file_local_penin <- download_url(
      url_penin,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    file_local_can <- download_url(
      url_can,
      cache_dir = cache_dir,
      subdir = "siane",
      update_cache = update_cache,
      verbose = verbose
    )

    # Download
    data_sf <- lapply(c(file_local_penin, file_local_can), read_geo_file_sf)

    data_sf <- rbind_fill(data_sf)
    if (is.null(data_sf)) {
      return(NULL)
    }
  }
  data_sf <- sf::st_transform(data_sf, as.double(init_epsg))

  data_sf <- siane_filter_year(data_sf = data_sf, year = year)
  # Name management
  data_sf$LAU_CODE <- data_sf$id_ine
  data_sf$name <- data_sf$rotulo
  data_sf$cpro <- substr(data_sf$id_ine, 1, 2)

  idprov <- sort(unique(mapSpain::esp_codelist$cpro))
  data_sf$cmun <- ifelse(
    substr(data_sf$LAU_CODE, 1, 2) %in% idprov,
    substr(data_sf$LAU_CODE, 3, 8),
    NA
  )

  cod <- unique(
    mapSpain::esp_codelist[
      ,
      c("codauto", "ine.ccaa.name", "cpro", "ine.prov.name")
    ]
  )

  data_sf <- merge(data_sf, cod, by = "cpro", all.x = TRUE, no.dups = TRUE)

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
  if (isFALSE(rawcols)) {
    data_sf <- data_sf[, c(
      "codauto",
      "ine.ccaa.name",
      "cpro",
      "ine.prov.name",
      "cmun",
      "name",
      "LAU_CODE"
    )]
  }
  data_sf <- sanitize_sf(data_sf)

  data_sf
}
