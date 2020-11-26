#' @title Get Autonomous Communities boundaries of Spain
#' @name esp_get_ccaa
#' @description Loads a simple feature (\code{sf}) object containing the
#' autonomous communities boundaries of Spain.
#' @return A \code{POLYGON/POINT} object.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @seealso \link{esp_get_hex_ccaa}, \link{esp_get_nuts}, \link{esp_get_prov},
#' \link{esp_get_munic}, \link{esp_codelist}
#' @export
#'
#'
#'
#' @param ccaa A vector of names and/or codes for autonomous communities
#'  or \code{NULL} to get all the autonomous communities. See Details.
#' @param ... Additional parameters from \link{esp_get_nuts}.
#' @details When using \code{ccaa} you can use and mix names and NUTS codes
#' (levels 1 or 2), ISO codes (corresponding to level 2) or \code{codauto}.
#' Ceuta and Melilla are considered as Autonomous Communities on this dataset.
#'
#' When calling a NUTS1 level, all the Autonomous Communities of that level
#' would be added.
#' @examples
#'
#' library(sf)
#'
#' # Random CCAA
#'
#' Random <-
#'   esp_get_ccaa(ccaa = c("Euskadi",
#'                         "Catalunya",
#'                         "ES-EX",
#'                         "Canarias",
#'                         "ES52",
#'                         "01"))
#' plot(st_geometry(Random), col = hcl.colors(6))
#'
#' # All CCAA of a Zone plus an addition
#'
#' Mix <-
#'   esp_get_ccaa(ccaa = c("La Rioja", "Noroeste"),
#'                resolution = "20")
#' plot(
#'   Mix[, "nuts1.code"],
#'   pal = hcl.colors(2),
#'   key.pos = NULL,
#'   main = NULL,
#'   border = "white"
#' )

esp_get_ccaa <- function(ccaa = NULL, ...) {
  params <- list(...)

  # Get region id

  ccaa <- ccaa[!is.na(ccaa)]


  region <- ccaa
  if (is.null(region)) {
    nuts_id <- NULL
  } else {
    nuts_id <- esp_hlp_all2ccaa(region)

    nuts_id <- unique(nuts_id)
    if (length(nuts_id) == 0)
      stop("region ",
           paste0("'", region, "'", collapse = ", "),
           " is not a valid name")
  }

  params$region <- nuts_id
  params$nuts_level <- 2


  data.sf <- do.call(mapSpain::esp_get_nuts,  params)

  data.sf$nuts2.code <- data.sf$NUTS_ID
  data.sf <- data.sf[, "nuts2.code"]

  # Get df
  df <- dict_ccaa
  df <- df[, names(df) != "key"]

  data.sf <- merge(data.sf, df, all.x = TRUE)

  # Paste nuts1
  dfnuts <- mapSpain::esp_codelist
  dfnuts <-
    unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])
  data.sf <- merge(data.sf, dfnuts, all.x = TRUE)
  data.sf <- data.sf[, c(colnames(df), "nuts1.code", "nuts1.name")]

  # Order
  data.sf <- data.sf[order(data.sf$codauto), ]

  return(data.sf)
}
