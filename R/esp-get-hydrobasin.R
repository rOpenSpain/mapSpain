#' River basin districts of Spain - SIANE
#'
#' @description
#' River basin districts are the areas of land and sea, made up of one or more
#' neighbouring river basins together with their associated groundwaters and
#' coastal waters.
#'
#' @encoding UTF-8
#' @family natural
#' @inheritParams esp_get_ccaa_siane
#' @inherit esp_get_ccaa_siane
#' @export
#'
#' @param domain character string. Type of river basin district. Possible
#'   values are `"land"`, including only the groundwaters area or `"landsea"`,
#'   groundwaters and coastal waters.
#'
#' @details
#' Metadata available on
#' <https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.
#'
#' @examplesIf esp_check_access()
#' \donttest{
#' hydroland <- esp_get_hydrobasin(domain = "land")
#' hydrolandsea <- esp_get_hydrobasin(domain = "landsea")
#'
#' library(ggplot2)
#'
#'
#' ggplot(hydroland) +
#'   geom_sf(data = hydrolandsea, fill = "skyblue4", alpha = .4) +
#'   geom_sf(fill = "skyblue", alpha = .5) +
#'   geom_sf_text(aes(label = rotulo),
#'     size = 2, check_overlap = TRUE,
#'     fontface = "bold",
#'     family = "serif"
#'   ) +
#'   coord_sf(
#'     crs = 3857,
#'     xlim = c(-9.5, 4.5),
#'     ylim = c(35, 44)
#'   ) +
#'   theme_void()
#' }
esp_get_hydrobasin <- function(
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = c(3, 6.5, 10),
  domain = c("land", "landsea")
) {
  init_epsg <- match_arg_pretty(epsg, c("4326", "4258", "3035", "3857"))
  domain <- match_arg_pretty(domain)
  res <- match_arg_pretty(resolution)
  res <- gsub("6.5", "6m5", res)

  if (domain == "land") {
    url_penin <- paste0(
      "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
      "se89_",
      res,
      "_hidro_demt_a_x.gpkg"
    )

    url_can <- paste0(
      "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
      "se89_",
      res,
      "_hidro_demt_a_y.gpkg"
    )
  } else {
    url_penin <- paste0(
      "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
      "se89_",
      res,
      "_hidro_demc_a_x.gpkg"
    )

    url_can <- paste0(
      "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
      "se89_",
      res,
      "_hidro_demc_a_y.gpkg"
    )
  }

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

  data_sf
}
