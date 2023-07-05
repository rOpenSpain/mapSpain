# Leaflet plugin version
leafletprovidersESP_v <- "v1.3.3"


#' Include base tiles of Spanish public administrations on a \pkg{leaflet} map
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
#'  **`r leafletprovidersESP_v`**.
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
#' @param provider Name of the provider, see [esp_tiles_providers] for
#'   values available.
#' @param ... Arguments passed on to [leaflet::providerTileOptions()].
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
  prov_list <- mapSpain::esp_tiles_providers

  allprovs <- names(prov_list)


  if (!provider %in% allprovs) {
    stop(
      "No match for provider = '",
      provider,
      "' found.\n\nCheck available providers in mapSpain::esp_tiles_providers."
    )
  }

  # Check type of provider
  thisprov <- prov_list[[provider]]

  # Get url
  # Special case for IDErioja
  if (grepl("rioja", provider, ignore.case = TRUE)) {
    iswmts <- TRUE
  } else {
    type_prov <- tolower(thisprov$static$service)
    iswmts <- type_prov == "wmts"
  }

  # Prepare each provider
  if (iswmts) {
    # Build template
    # Get requested options and merge with the current ones
    def_opts <- thisprov$leaflet

    # Extract attribution
    attribution <- def_opts$attribution
    # Remove
    def_opts <- modifyList(def_opts, list(attribution = NULL))

    # Normalize names
    names(def_opts) <- tolower(names(def_opts))
    names(options) <- tolower(names(options))


    optionend <- modifyList(def_opts, options)

    # Build template url
    temp_pieces <- thisprov$static
    q <- temp_pieces$q
    # Remove
    rest <- modifyList(
      temp_pieces, list(
        attribution = NULL,
        q = NULL
      )
    )

    rest_temp <- paste0(names(rest), "=", rest, collapse = "&")

    templurl <- paste0(q, rest_temp)

    # Special case for IDErioja
    if (grepl("rioja", provider, ignore.case = TRUE)) {
      templurl <- q
    }

    # Modify default leaflet::tileOptions() with our options
    # Normalize names
    tileops <- leaflet::tileOptions()
    names(tileops) <- tolower(names(tileops))


    optionend <- modifyList(
      tileops,
      optionend
    )

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
    # Build template
    # Get requested options and merge with the current ones
    def_opts <- thisprov$leaflet

    # Extract attribution
    attribution <- def_opts$attribution
    # Remove
    def_opts <- modifyList(def_opts, list(attribution = NULL))

    # Get important params
    temp_pieces <- thisprov$static
    names(temp_pieces) <- tolower(names(temp_pieces))


    templurl <- gsub("\\?$", "", temp_pieces$q)
    layers <- temp_pieces$layers

    # Remove parameters only affecting static urls
    todel <- names(temp_pieces) %in% c(
      "attribution", "q", "service",
      "request", "layers", "srs", "width",
      "height", "bbox"
    )

    names(def_opts) <- tolower(names(def_opts))

    def_opts <- modifyList(
      def_opts,
      temp_pieces[!todel]
    )

    # Add custom options
    names(options) <- tolower(names(options))
    optionend <- modifyList(def_opts, options)

    # Modify default leaflet::WMSTileOptions() with our options
    wmsopts <- leaflet::WMSTileOptions()
    names(wmsopts) <- tolower(names(wmsopts))


    optionend <- modifyList(
      wmsopts,
      optionend
    )

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
