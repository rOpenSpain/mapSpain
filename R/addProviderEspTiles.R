# Plugin version for leaflet.
leaf_providers_esp_v <- "v1.3.3"

#' Add a tile layer from Spanish public administrations to a \CRANpkg{leaflet}
#' map
#'
#' @param provider The name of the provider, see [esp_tiles_providers] or
#'   <https://dieghernan.github.io/leaflet-providersESP/preview/>.
#'
#' @inheritParams leaflet::addProviderTiles
#' @inherit leaflet::addProviderTiles return
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/>, a plugin for
#' \CRANpkg{leaflet}, **`r leaf_providers_esp_v`**.
#'
#' @seealso
#' - [leaflet::leaflet()].
#' - [leaflet::addTiles()].
#' - [leaflet::addWMSTiles()].
#' - [esp_tiles_providers].
#'
#' @family images
#' @encoding UTF-8
#' @export
#'
#' @examples
#' library(leaflet)
#' leafmap <- leaflet(width = "100%", height = "60vh") |>
#'   setView(lat = 40.4166, lng = -3.7038400, zoom = 10) |>
#'   addTiles(group = "Default (OSM)") |>
#'   addProviderEspTiles(
#'     provider = "IDErioja.Claro",
#'     group = "IDErioja Claro"
#'   ) |>
#'   addProviderEspTiles(
#'     provider = "RedTransporte.Carreteras",
#'     group = "Carreteras"
#'   ) |>
#'   addLayersControl(
#'     baseGroups = c("IDErioja Claro", "Default (OSM)"),
#'     overlayGroups = "Carreteras",
#'     options = layersControlOptions(collapsed = FALSE)
#'   )
#'
#' leafmap
addProviderEspTiles <- function(
  map,
  provider,
  layerId = NULL,
  group = NULL,
  options = leaflet::providerTileOptions()
) {
  map <- validate_non_empty_arg(map)
  provider <- validate_non_empty_arg(provider)

  # Check providers.
  prov_list <- mapSpain::esp_tiles_providers

  allprovs <- names(prov_list)

  provider <- match_arg_pretty(provider, allprovs)

  # Check provider type.
  prov_pieces <- validate_provider(provider)
  iswmts <- guess_provider_type(prov_pieces) == "WMTS"
  thisprov <- prov_list[[provider]]

  # Get URL.

  # Prepare each provider.
  if (iswmts) {
    # Build the template.
    # Get requested options and merge with the current ones.
    def_opts <- thisprov$leaflet

    # Extract attribution.
    attribution <- def_opts$attribution
    # Remove fields handled separately.
    def_opts <- modifyList(def_opts, list(attribution = NULL))

    # Normalize names.
    names(def_opts) <- tolower(names(def_opts))
    names(options) <- tolower(names(options))

    optionend <- modifyList(def_opts, options)

    # Build the template URL.
    temp_pieces <- thisprov$static
    q <- temp_pieces$q
    # Remove fields handled separately.
    rest <- modifyList(temp_pieces, list(attribution = NULL, q = NULL))

    rest_temp <- paste0(names(rest), "=", rest, collapse = "&")

    templurl <- paste0(q, rest_temp)

    # Handle IDErioja as a special case.
    if (grepl("rioja", provider, ignore.case = TRUE)) {
      templurl <- q
    }

    # Modify default leaflet::tileOptions() with our options.
    # Normalize names.
    tileops <- leaflet::tileOptions()
    names(tileops) <- tolower(names(tileops))

    optionend <- modifyList(tileops, optionend)
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
    # Build the template.
    # Get requested options and merge with the current ones.
    def_opts <- thisprov$leaflet

    # Extract attribution.
    attribution <- def_opts$attribution
    # Remove fields handled separately.
    def_opts <- modifyList(def_opts, list(attribution = NULL))

    # Get important parameters.
    temp_pieces <- thisprov$static
    names(temp_pieces) <- tolower(names(temp_pieces))

    templurl <- gsub("\\?$", "", temp_pieces$q)
    layers <- temp_pieces$layers

    # Remove arguments only affecting static URLs.
    todel <- names(temp_pieces) %in%
      c(
        "attribution",
        "q",
        "service",
        "request",
        "layers",
        "srs",
        "width",
        "height",
        "bbox"
      )

    names(def_opts) <- tolower(names(def_opts))

    def_opts <- modifyList(def_opts, temp_pieces[!todel])

    # Add custom options.
    names(options) <- tolower(names(options))
    optionend <- modifyList(def_opts, options)

    # Modify default leaflet::WMSTileOptions() with our options.
    wmsopts <- leaflet::WMSTileOptions()
    names(wmsopts) <- tolower(names(wmsopts))

    optionend <- modifyList(wmsopts, optionend)

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
