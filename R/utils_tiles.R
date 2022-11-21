#' Get tiles from WMS
#'
#' @param transparent Transparency
#'
#' @param bbox_expand Expansion of the bbox
#'
#' @param url_pieces Provider
#'
#' @inheritParams esp_getTiles
#'
#' @noRd
getwms <- function(x,
                   url_pieces,
                   update_cache,
                   cache_dir,
                   verbose,
                   res,
                   transparent,
                   options) {

  # Get squared bbox
  bbox <- as.double(sf::st_bbox(x))
  dimx <- (bbox[3] - bbox[1])
  dimy <- (bbox[4] - bbox[2])
  maxdist <- max(dimx, dimy)
  center <- c(bbox[1] + dimx / 2, bbox[2] + dimy / 2)

  bboxsquare <- c(
    center[1] - maxdist / 2,
    center[2] - maxdist / 2,
    center[1] + maxdist / 2,
    center[2] + maxdist / 2
  )


  class(bboxsquare) <- "bbox"


  # Compose params
  q <- provs[provs$field == "url_static", "value"]

  q <-
    gsub("{bbox}", paste0(bboxsquare, collapse = ","),
      q,
      fixed = TRUE
    )

  q <- gsub("512", as.character(res), q)


  # Add options
  withopt <- tile_handle_options(q, options, cache_dir)

  q <- withopt$q
  cache_dir <- withopt$cache_dir


  src <- unique(provs$provider)


  ext <- "jpeg"
  if (length(grep("png", q)) > 0) {
    ext <- "png"
  } else if (length(grep("jpg", q)) > 0) {
    ext <- "jpg"
  }

  filename <-
    paste0(
      src,
      "_bbox3857_res",
      res,
      "_",
      paste0(bboxsquare, collapse = "_"),
      ".",
      ext
    )

  filename <- file.path(cache_dir, filename)

  if (isFALSE(file.exists(filename)) | isTRUE(update_cache)) {
    if (verbose) {
      message("Downloading from \n", q, "\n to cache dir \n", cache_dir)
    }


    download.file(
      url = q,
      destfile = filename,
      mode = "wb",
      quiet = !verbose
    )
  } else {
    if (verbose) {
      message("Requested tile already cached on \n", cache_dir)
    }
  }

  # Read png and geotag

  # Only png
  if (ext == "png") {
    img <- png::readPNG(filename) * 255
    # Give transparency if available
    if (dim(img)[3] == 4 && transparent) {
      nrow <- dim(img)[1]

      for (i in seq_len(nrow)) {
        row <- img[i, , ]
        alpha <- row[, 4] == 0
        row[alpha, ] <- NA
        img[i, , ] <- row
      }
    }
  } else {
    img <- filename
  }


  # compose brick raster
  r_img <- suppressWarnings(terra::rast(img))


  if (is.null(terra::RGB(r_img))) {
    terra::RGB(r_img) <- c(1, 2, 3)
  }

  terra::ext(r_img) <- terra::ext(bboxsquare[c(1, 3, 2, 4)])


  terra::crs(r_img) <- "epsg:3857"
  # End WMS

  return(r_img)
}

#' Get tiles from WMTS
#'
#' @inheritParams esp_getTiles
#'
#' @inheritParams getWMS
#'
#' @noRd
getwmts <- function(x,
                    provs,
                    update_cache,
                    cache_dir,
                    verbose,
                    res,
                    zoom,
                    zoommin,
                    type,
                    transparent,
                    options) {
  # New fun

  x <- sf::st_transform(x, 4326)
  bbx <- sf::st_bbox(x)

  # select a default zoom level
  if (is.null(zoom)) {
    gz <- slippymath::bbox_tile_query(bbx)
    zoom <- min(gz[gz$total_tiles %in% 4:10, "zoom"]) + zoommin

    if (verbose) {
      message("Auto zoom level: ", zoom)
    }
  }

  # Check zoom
  if ("minZoom" %in% provs$field) {
    minZoom <- as.numeric(provs[provs$field == "minZoom", "value"])

    if (zoom < minZoom) {
      zoom <- max(zoom, minZoom)
      if (verbose) {
        message(
          "\nSwitching. Minimum zoom for this provider is ",
          zoom,
          "\n"
        )
      }
    }
  }

  # get tile list
  tile_grid <-
    slippymath::bbox_to_tile_grid(bbox = bbx, zoom = zoom)

  # Compose params
  q <- provs[provs$field == "url_static", "value"]

  # Add options
  withopt <- tile_handle_options(q, options, cache_dir)

  q <- withopt$q
  cache_dir <- withopt$cache_dir

  ext <- "jpeg"
  if (length(grep("png", q)) > 0) {
    ext <- "png"
  } else if (length(grep("jpg", q)) > 0) {
    ext <- "jpg"
  }

  if (verbose) {
    message("Caching tiles on ", cache_dir)
  }

  # download images
  images <- apply(
    X = tile_grid$tiles,
    MARGIN = 1,
    FUN = dl_t,
    z = tile_grid$zoom,
    ext = ext,
    src = type,
    q = q,
    verbose = verbose,
    cache_dir = cache_dir,
    update_cache = update_cache
  )

  rout <- compose_tile_grid(tile_grid, ext, images, transparent)
  return(rout)
}


#' @name compose_tile_grid
#' @noRd
compose_tile_grid <- function(tile_grid, ext, images, transparent) {
  # Based on https://github.com/riatelab/maptiles/blob/main/R/get_tiles.R

  bricks <- vector("list", nrow(tile_grid$tiles))


  for (i in seq_along(bricks)) {
    bbox <- slippymath::tile_bbox(
      tile_grid$tiles$x[i], tile_grid$tiles$y[i],
      tile_grid$zoom
    )
    img <- images[i]
    # special for png tiles
    if (ext == "png") {
      img <- png::readPNG(img) * 255

      # Give transparency
      if (dim(img)[3] == 4 && transparent) {
        nrow <- dim(img)[1]
        for (j in seq_len(nrow)) {
          row <- img[j, , ]
          alpha <- row[, 4] == 0
          row[alpha, ] <- NA
          img[j, , ] <- row
        }
      }
    }

    # compose brick raster
    r_img <- suppressWarnings(terra::rast(img))

    # compose brick raster
    r_img <- suppressWarnings(terra::rast(img))

    if (is.null(terra::RGB(r_img))) {
      terra::RGB(r_img) <- c(1, 2, 3)
    }

    terra::ext(r_img) <- terra::ext(bbox[c(
      "xmin", "xmax",
      "ymin", "ymax"
    )])
    bricks[[i]] <- r_img
  }

  # if only one tile is needed
  if (length(bricks) == 1) {
    rout <- bricks[[1]]
    rout <- terra::merge(rout, rout)
  } else {
    # all tiles together
    rout <- do.call(terra::merge, bricks)
  }

  terra::RGB(rout) <- c(1, 2, 3)
  terra::crs(rout) <- "epsg:3857"

  return(rout)
}


#' @name dl_t
#' @noRd
dl_t <-
  function(x,
           z,
           ext,
           src,
           q,
           verbose,
           cache_dir,
           update_cache) {
    outfile <-
      paste0(cache_dir, "/", src, "_", z, "_", x[1], "_", x[2], ".", ext)

    if (!file.exists(outfile) |
      isTRUE(update_cache)) {
      q <-
        gsub(
          pattern = "{x}",
          replacement = x[1],
          x = q,
          fixed = TRUE
        )
      q <-
        gsub(
          pattern = "{y}",
          replacement = x[2],
          x = q,
          fixed = TRUE
        )
      q <- gsub(
        pattern = "{z}",
        replacement = z,
        x = q,
        fixed = TRUE
      )
      if (verbose) {
        message("Downloading ", q, "\n")
      }
      download.file(
        url = q,
        destfile = outfile,
        quiet = TRUE,
        mode = "wb"
      )
    } else if (verbose) {
      message("Tile cached on ", outfile)
    }
    return(outfile)
  }


tile_handle_options <- function(q, options, cache_dir) {
  if (is.null(options)) {
    res <- list(
      q = q,
      cache_dir = cache_dir
    )
    return(res)
  }

  # Get params from root q
  root <- paste0(unlist(strsplit(q, "?", fixed = TRUE))[1], "?")
  getparams <- gsub(root, "", q, fixed = TRUE)
  getparams <- unlist(strsplit(getparams, "&"))
  getparams <- as.list(getparams)

  initnames <- vapply(getparams, function(x) {
    unlist(strsplit(x, "="))[1]
  },
  FUN.VALUE = character(1)
  )

  initvalues <- vapply(getparams, function(x) {
    a <- unlist(strsplit(x, "="))[-1]
    a <- paste0(a, collapse = "=")
  },
  FUN.VALUE = character(1)
  )

  names(initvalues) <- tolower(initnames)

  initparams <- as.list(initvalues)

  # Handle options and replace if needed
  names(options) <- tolower(names(options))

  # Modify list
  endopts <- utils::modifyList(
    initparams,
    options
  )

  # Restore casing on original values
  restnames <- names(endopts)
  restnames[seq_len(length(initnames))] <- initnames

  names(endopts) <- restnames

  # Create new url
  newopts <- paste0(names(endopts), "=", endopts, collapse = "&")

  endurl <- paste0(root, newopts)


  # Modify cache dir
  newdir <- tolower(paste0(names(options), "_", options,
    collapse = .Platform$file.sep
  ))
  cache_dir <- file.path(cache_dir, newdir)
  cache_dir <- esp_hlp_cachedir(cache_dir)

  # Final object
  res <- list(
    q = endurl,
    cache_dir = cache_dir
  )
  return(res)
}
