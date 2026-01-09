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

  if (!any(grepl("service=WM", split))) {
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

  if (guess_provider_type(urlsplit) == "WMTS") {
    # Ensure these parameters

    urlsplit$tilematrixset <- "GoogleMapsCompatible"
    urlsplit$tilematrix <- "{z}"
    urlsplit$tilerow <- "{y}"
    urlsplit$tilecol <- "{x}"
  }

  urlsplit
}

guess_provider_type <- function(prov_list) {
  serv <- unlist(prov_list[tolower(names(prov_list)) == "service"])

  serv <- ensure_null(serv)
  # Asumming WMTS: e.g.
  # https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png
  if (is.null(serv)) {
    return("WMTS")
  }
  toupper(serv)
  serv <- unname(unlist(serv))
  serv
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
  crs <- unname(toupper(crs))

  crs
}

modify_provider_list <- function(prov_list, options = NULL) {
  options <- ensure_null(options)
  if (is.null(options)) {
    return(prov_list)
  }

  names(options) <- tolower(names(options))
  type_prov <- guess_provider_type(prov_list)

  if (type_prov == "WMS" && "version" %in% names(options)) {
    # Exception: need to change names depending on the version of WMS

    v_wms <- unlist(modifyList(
      list(v = prov_list$version),
      list(v = options$version)
    ))

    if (v_wms >= "1.3.0") {
      names(prov_list) <- gsub("srs", "crs", names(prov_list))
      names(options) <- gsub("srs", "crs", names(options))
    } else {
      names(prov_list) <- gsub("crs", "srs", names(prov_list))
      names(options) <- gsub("crs", "srs", names(options))
    }
  }

  # Ignore TileMatrix fields in WMTS
  if (type_prov == "WMTS") {
    options <- options[names(options) != "tilematrix"]
  }

  prov_list <- modifyList(prov_list, options)

  # Modify id
  newdir <- paste0(names(options), "=", options, collapse = "&")
  new_id <- file.path(prov_list$id, cli::hash_raw_md5(charToRaw(newdir)))

  prov_list$id <- new_id
  prov_list
}

get_tile_ext <- function(prov_list) {
  # Special case for MapBox
  if (grepl("mapbox", prov_list$q)) {
    return("png")
  }

  fmt <- ensure_null(prov_list$format)

  # Caso of non OGC WMTS
  if (is.null(fmt)) {
    # Maybe ?
    if (grepl("?", prov_list$q, fixed = TRUE)) {
      no_api_key <- unlist(strsplit(prov_list$q, "?", fixed = TRUE))[1]
      ext <- tools::file_ext(no_api_key)
      return(ext)
    }

    ext <- tools::file_ext(prov_list$q)
    return(ext)
  }
  ext <- basename(fmt)

  ext
}
get_tile_bbox <- function(geom, bbox_expand = 0.05, prov_type = "WMS") {
  bbox <- as.double(sf::st_bbox(geom))

  # Expand in planar coordinates
  dimx <- (bbox[3] - bbox[1])
  dimy <- (bbox[4] - bbox[2])
  center <- c(bbox[1] + dimx / 2, bbox[2] + dimy / 2)

  bbox_expand <- 1 + bbox_expand

  if (prov_type == "WMS") {
    maxdist <- max(dimx, dimy)
    dimy <- maxdist
    dimx <- dimy
  }

  newbbox <- c(
    center[1] - bbox_expand * dimx / 2,
    center[2] - bbox_expand * dimy / 2,
    center[1] + bbox_expand * dimx / 2,
    center[2] + bbox_expand * dimy / 2
  )

  class(newbbox) <- "bbox"

  newbbox <- sf::st_as_sfc(newbbox)

  sf::st_crs(newbbox) <- sf::st_crs(geom)

  newbbox
}
