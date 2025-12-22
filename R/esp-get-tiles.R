# nocov start
esp_get_tiles2 <- function(
  x,
  type = "IDErioja",
  zoom = NULL,
  zoommin = 0,
  crop = TRUE,
  res = 512,
  bbox_expand = 0.05,
  transparent = TRUE,
  mask = FALSE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  options = NULL
) {
  x <- validate_non_empty_arg(x)

  # Only sf and sfc allowed

  if (!any(inherits(x, "sf"), inherits(x, "sfc"))) {
    cli::cli_abort(
      paste0(
        "{.arg x} should be an {.cls sf} ",
        "or {.cls sfc} object, not {.obj_type_friendly {x}}."
      )
    )
  }

  geom <- sf::st_geometry(x)

  zoom <- ensure_null(zoom)

  # Single point would be buffered
  if (all(length(geom) == 1, sf::st_geometry_type(geom) == "POINT")) {
    message("Remove: I am a single point")
    geom_buff <- sf::st_buffer(sf::st_transform(geom, 3857), 50)
    geom <- sf::st_transform(geom_buff, sf::st_crs(geom))

    # Modify some defaults
    crop <- FALSE
    if (is.null(zoom)) {
      zoom <- 15
      make_msg(
        "info",
        verbose,
        "Autozoom in single {.str POINT} set to {.val 15}"
      )
    }
  }
  # Buffer if single point
  if (length(x) == 1 && "POINT" %in% sf::st_geometry_type(x)) {
    xmod <- sf::st_transform(sf::st_geometry(x), 3857)
    xmod <- sf::st_buffer(xmod, 50)
    x <- sf::st_transform(xmod, sf::st_crs(x))
    crop <- FALSE
    # Auto zoom = 15 if not set
    if (is.null(zoom)) {
      zoom <- 15
      if (verbose) message("Auto zoom on point set to 15")
    }
  }

  # WIP
}

# nocov end
