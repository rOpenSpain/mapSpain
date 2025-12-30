#' Provinces of Spain - GISCO
#'
#' @description
#' Returns
#' [provinces of Spain](https://en.wikipedia.org/wiki/Provinces_of_Spain)
#' at a specified scale.
#'
#' @encoding UTF-8
#' @family political
#' @family gisco
#' @inheritParams esp_get_nuts
#' @inheritDotParams esp_get_nuts -nuts_level -region
#' @inherit esp_get_nuts
#' @export
#'
#'
#' @param prov A vector of names and/or codes for provinces or `NULL` to get all
#'   the provinces. See **Details**.
#'
#' @inheritParams esp_get_nuts
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
#'   theme_minimal()
#'
#' \donttest{
#' # Random Provinces
#' random <- esp_get_prov(prov = c(
#'   "Zamora", "Palencia", "ES-GR",
#'   "ES521", "01"
#' ))
#'
#'
#' ggplot(random) +
#'   geom_sf(aes(fill = codauto), show.legend = FALSE, alpha = 0.5) +
#'   scale_fill_manual(values = hcl.colors(nrow(random), "Spectral")) +
#'   theme_minimal()
#'
#'
#' # All Provinces of a Zone plus an addition
#' mix <- esp_get_prov(prov = c(
#'   "Noroeste",
#'   "Castilla y Leon", "La Rioja"
#' ))
#'
#' mix$ccaa <- esp_dict_region_code(
#'   mix$codauto,
#'   origin = "codauto"
#' )
#'
#' ggplot(mix) +
#'   geom_sf(aes(fill = ccaa), alpha = 0.5) +
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
#'   coord_sf(crs = 3857) +
#'   theme_void()
#' }
esp_get_prov <- function(prov = NULL, moveCAN = TRUE, ...) {
  params <- list(...)

  # Get region id
  nuts_id <- ensure_null(prov)
  if (!is.null(nuts_id)) {
    nuts_id <- convert_to_nuts_prov(nuts_id)
  }

  params$region <- nuts_id
  params$nuts_level <- 3
  params$moveCAN <- moveCAN

  data_sf <- do.call(mapSpain::esp_get_nuts, params)
  if (is.null(data_sf)) {
    return(NULL)
  }

  data_sf$nuts3.code <- data_sf$NUTS_ID
  data_sf <- data_sf[, "nuts3.code"]

  # Get cpro

  df <- mapSpain::esp_codelist
  df <- unique(df[, c("nuts3.code", "cpro")])
  data_sf <- merge(data_sf, df, all.x = TRUE)
  data_sf <- data_sf[, "cpro"]
  data_sf <- data_sf[order(data_sf$cpro), ]

  # Merge Islands
  res_cpros <- unique(data_sf$cpro)
  binded_sf <- lapply(res_cpros, function(x) {
    the_geom <- data_sf[data_sf$cpro == x, ]
    if (nrow(the_geom) == 1) {
      return(the_geom)
    }
    get_g <- sf::st_geometry(data_sf[data_sf$cpro == x, ])
    g <- sf::st_union(get_g)
    sf::st_sf(cpro = x, geometry = g)
  })

  data_sf <- rbind_fill(binded_sf)

  # Get df
  df <- get_prov_codes_df()

  data_sf <- merge(data_sf, df, all.x = TRUE)

  # Paste nuts2
  dfnuts <- mapSpain::esp_codelist
  dfnuts <- dfnuts[, c(
    "cpro",
    "nuts2.code",
    "nuts2.name",
    "nuts1.code",
    "nuts1.name"
  )]
  dfnuts <- unique(dfnuts)

  data_sf <- merge(data_sf, dfnuts, all.x = TRUE)

  data_sf <- data_sf[
    ,
    c(colnames(df), "nuts2.code", "nuts2.name", "nuts1.code", "nuts1.name")
  ]

  # Order
  data_sf <- data_sf[order(data_sf$codauto, data_sf$cpro), ]

  data_sf <- sanitize_sf(data_sf)
  data_sf
}
