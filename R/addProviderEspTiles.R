#' Include base tiles of Spanish public administrations on a **leaflet** map
#'
#' @description
#' Include tiles of public Spanish organisms to a
#' [leaflet::leaflet()] map.
#'
#' @family imagery utilities
#' @seealso [leaflet::leaflet()], [leaflet::addTiles()]
#'
#' @rdname addProviderEspTiles
#' @name addProviderEspTiles
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#'  **v1.2.0**.
#'
#' @return A map object generated with [leaflet::leaflet()].
#'
#'
#'
#' @export
#'
#' @param map A map widget created from [leaflet::leaflet()].
#' @param group The name of the group the newly created layers should belong to
#'   Human-friendly group names are permitted–they need not be short,
#'   identifier-style names. Any number of layers and even different types of
#'   layers (e.g. markers and polygons) can share the same group name. See
#'   [leaflet::addTiles()].
#' @param provider Name of the provider, see [leaflet.providersESP.df] for
#'   values available.
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
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    stop("leaflet package required for using this function")
  }

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

  iswmts <- provs[provs$field == "type", "value"] == "WMTS"

  # Work with options
  if (isFALSE(iswmts)) {
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



  if (iswmts) {
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
#' @name providerEspTileOptions
#'
#' @details
#' [providerEspTileOptions()] is a wrapper of
#' [leaflet::providerTileOptions()].
#'
#' @inheritDotParams leaflet::providerTileOptions
#'
#' @seealso [leaflet::providerTileOptions()], [leaflet::tileOptions()]
#'
#' @export
providerEspTileOptions <- function(...) {
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    stop("leaflet package required for using this function")
  }

  ops <- leaflet::providerTileOptions(...)
  return(ops)
}
