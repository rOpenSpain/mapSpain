#' @title Leaflet plugin - Spanish providers
#' @name addProviderEspTiles
#' @description Add tiles of
#' \href{https://dieghernan.github.io/leaflet-providersESP/}{leaflet-providersESP}
#' to a \strong{R} \link[leaflet]{leaflet} map.
#' @source \href{https://dieghernan.github.io/leaflet-providersESP/}{leaflet-providersESP}
#' leaflet plugin, \strong{v1.2.0}.
#' @return Modified \code{map} object.
#' @author dieghernan, \url{https://github.com/dieghernan/}
#' @seealso \link{leaflet.providersESP.df}, \link{esp_getTiles}
#' @export
#'
#' @param provider Name of the provider, see \link{leaflet.providersESP.df}.
#' @param map,layerId,group,options See \link[leaflet]{addTiles}
#' @examples
#' library(leaflet)
#'   PuertadelSol <-
#'     leaflet() %>% setView(lat = 40.4166,
#'                           lng = -3.7038400,
#'                           zoom = 18) %>%
#'     addProviderEspTiles(provider = "IGNBase.Gris") %>%
#'     addProviderEspTiles(provider = "RedTransporte.Carreteras")
#'
#'     PuertadelSol
#'
#'
#'
addProviderEspTiles <- function(map,
                                provider,
                                layerId = NULL,
                                group = NULL,
                                options = providerEspTileOptions()) {
  # A. Check providers
  leafletProvidersESP <-
    as.data.frame(mapSpain::leaflet.providersESP.df)
  provs <-
    leafletProvidersESP[leafletProvidersESP$provider == provider, ]

  if (nrow(provs) == 0) {
    stop(
      "No match for provider = '",
      provider,
      "' found. Available providers are:\n\n",
      paste0("'",
             unique(leafletProvidersESP$provider), "'",
             collapse = ", ")
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
  opts <- opts[!(opts$field %in% names(options)),]

  # Pass to list

  opinit <- list()

  for (j in seq_len(nrow(opts))) {
    name <- paste(opts[j, 1])
    value <- paste(opts[j, 2])

    opinit[[name]] <- value

  }

  options <- c(options, opinit)
  rm(opts, provs, leafletProvidersESP, opinit)

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
    options <- do.call(leaflet::tileOptions, options)

    leaflet::addTiles(
      map,
      urlTemplate = templurl,
      attribution = attribution,
      layerId = layerId,
      group = group,
      options = optionend
    )
  } else {
    options <- do.call(leaflet::WMSTileOptions, options)

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
#' @details \code{providerEspTileOptions} is a wrapper of
#' \code{leaflet::providerTileOptions}
#' @param ...  Additional options. See \link[leaflet]{providerTileOptions}.
#' @seealso \link[leaflet]{tileOptions}, \link[leaflet]{providerTileOptions}
#' @export
providerEspTileOptions <- function(...) {
  ops <- leaflet::providerTileOptions(...)
  return(ops)
}
