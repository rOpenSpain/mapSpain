#' Leaflet plugin - Spanish providers
#'
#' @concept imagery
#'
#' @rdname addProviderEspTiles
#'
#' @description
#' Add tiles of <https://dieghernan.github.io/leaflet-providersESP/> to a
#' **R** [leaflet::leaflet()] map.
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#'  **v1.2.0**.
#'
#' @return Modified `map` object.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @seealso [leaflet.providersESP.df], [esp_getTiles()]
#'
#' @export
#'
#' @param provider Name of the provider, see [leaflet.providersESP.df].
#'
#' @inheritParams leaflet::addTiles
#'
#' @examples
#' library(leaflet)
#' PuertadelSol <-
#'   leaflet() %>%
#'   setView(
#'     lat = 40.4166,
#'     lng = -3.7038400,
#'     zoom = 18
#'   ) %>%
#'   addProviderEspTiles(provider = "IGNBase.Gris") %>%
#'   addProviderEspTiles(provider = "RedTransporte.Carreteras")
#'
#' PuertadelSol
addProviderEspTiles <- function(map,
                                provider,
                                layerId = NULL,
                                group = NULL,
                                options = providerEspTileOptions()) {
  # A. Check providers
  providers_df <-
    as.data.frame(mapSpain::leaflet.providersESP.df)
  provs <-
    providers_df[providers_df$provider == provider, ]

  if (nrow(provs) == 0) {
    stop(
      "No match for provider = '",
      provider,
      "' found. Available providers are:\n\n",
      paste0("'",
        unique(providers_df$provider), "'",
        collapse = ", "
      )
    )
  }

  # Get url

  templurl <- provs[provs$field == "url", "value"]
  attribution <- provs[provs$field == "attribution", "value"]

  isWMTS <- provs[provs$field == "type", "value"] == "WMTS"

  # Work with options
  if (isFALSE(isWMTS)) {
    layers <- provs[provs$field == "layers", "value"]
  }

  opts <-
    provs[!(
      provs$field %in% c(
        "url",
        "type",
        "url_static",
        "attribution",
        "attribution_static",
        "bounds",
        "layers"
      )
    ), c(2, 3)]



  # Clean if the option was already set
  opts <- opts[!(opts$field %in% names(options)), ]

  # Pass to list

  opinit <- list()

  for (j in seq_len(nrow(opts))) {
    name <- paste(opts[j, 1])
    value <- paste(opts[j, 2])

    opinit[[name]] <- value
  }

  options <- c(options, opinit)
  rm(opts, provs, providers_df, opinit)

  # Replace on template

  optionend <- list()

  for (i in seq_len(length(options))) {
    n <- names(options[i])
    v <- options[i][[1]]

    needreplace <-
      grepl(paste0("{", n, "}"), templurl, fixed = TRUE)

    if (needreplace) {
      templurl <- gsub(paste0("{", n, "}"), v, templurl, fixed = TRUE)
    } else {
      optionend <- c(optionend, options[i])
    }
  }



  if (isWMTS) {
    optionend <- do.call(leaflet::tileOptions, optionend)

    leaflet::addTiles(
      map,
      urlTemplate = templurl,
      attribution = attribution,
      layerId = layerId,
      group = group,
      options = optionend
    )
  } else {
    optionend <- do.call(leaflet::WMSTileOptions, optionend)

    leaflet::addWMSTiles(
      map,
      baseUrl = templurl,
      layers = layers,
      attribution = attribution,
      layerId = layerId,
      group = group,
      options = optionend
    )
  }
}

#' @rdname addProviderEspTiles
#'
#' @concept imagery
#'
#' @details Wrapper of [leaflet::providerTileOptions()]
#'
#' @inheritDotParams leaflet::providerTileOptions
#'
#' @seealso [leaflet::providerTileOptions()], [leaflet::tileOptions()]
#'
#' @export
providerEspTileOptions <- function(...) {
  ops <- leaflet::providerTileOptions(...)
  return(ops)
}
