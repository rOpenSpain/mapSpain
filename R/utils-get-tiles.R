validate_provider <- function(type = "PNOA") {
  if (!any(is.list(type), is.character(type))) {
    cli::cli_abort(
      paste0(
        "{.arg type} should be a named list (see ",
        "{.fn mapSpain::esp_make_provider} or the name of a provider (see ",
        "{.fn mapSpain::esp_tiles_providers}, not {.obj_class_friendly {type}}."
      )
    )
  }

  # Validate list
  if (is.list(type)) {
    # Need to have at least id and q
    valid <- c("id", "q")
    has_valid <- valid %in% names(type)
    if (!all(has_valid)) {
      cli::cli_abort(
        paste0(
          "A custom provider must be a named list with elements {.str {valid}}",
          ", missing {.str {valid[!has_valid]}} element{?/s}. See ",
          "{.fn mapSpain::esp_make_provider}."
        )
      )
    }

    formatted_type <- provider_to_list(type)
    return(formatted_type)
  }
  # Check providers

  # These are already split, just add some additional info
  prov_list <- mapSpain::esp_tiles_providers
  type <- match_arg_pretty(type, names(prov_list))

  db_prov <- prov_list[type][[1]]$static
  db_prov$id <- type

  min_zoom <- ensure_null(prov_list[type][[1]]$leaflet$minZoom)
  db_prov$min_zoom <- min_zoom

  # Order
  ord <- unique(c(c("attribution", "id", "q"), names(db_prov)))
  db_prov <- db_prov[ord]
  # Remove NULLs/NAs
  db_prov <- lapply(db_prov, ensure_null)
  db_prov <- db_prov[lengths(db_prov) > 0]
  db_prov
}


provider_to_list <- function(type) {
  id <- type$id

  q <- type$q

  split <- unlist(strsplit(q, "?", fixed = TRUE))

  if (length(split) == 1) {
    return(type)
  }

  urlsplit <- list(id = id)
  urlsplit$q <- paste0(split[1], "?")

  opts <- unlist(strsplit(split[2], "&"))

  parts <- lapply(opts, function(x) {
    split_part <- unlist(strsplit(x, "=", fixed = TRUE))
    if (length(split_part) < 2) {
      return(NULL)
    }

    l <- list(split_part[[2]])
    names(l) <- split_part[[1]]
    l
  })

  parts <- do.call("c", parts)

  urlsplit <- modifyList(urlsplit, parts)

  urlsplit
}

guess_provider_type <- function(prov_list) {
  serv <- unlist(prov_list[tolower(names(prov_list)) == "service"])

  serv <- ensure_null(serv)
  # Asumming WMTS: e.g.
  # "https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png"
  if (is.null(serv)) {
    return("WMTS")
  }
  toupper(serv)
}

get_tile_crs <- function(prov_list) {
  # Get CRS of Tile
  crs <- unlist(
    prov_list[tolower(names(prov_list)) %in% c("crs", "srs", "tilematrixset")]
  )
  crs <- ensure_null(crs)
  # Caso some WMTS
  if (is.null(crs)) {
    crs <- "EPSG:3857"
  }

  if (tolower(crs) == tolower("GoogleMapsCompatible")) {
    crs <- "EPSG:3857"
  }
  crs <- toupper(crs)

  sf::st_crs(crs)
}
