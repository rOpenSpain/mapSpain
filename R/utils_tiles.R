#' Get tiles from WMS
#'
#' @param transparent Transparency
#'
#' @param bbox_expand Expansion of the bbox
#'
#' @param provs Provider
#'
#' @inheritParams esp_getTiles
#'
#' @noRd
getWMS <- function(x,
                   provs,
                   update_cache,
                   cache_dir,
                   verbose,
                   res,
                   transparent,
                   bbox_expand) { # nocov start

  bbox_expand <- max(1 + bbox_expand, 1.1)

  # Get squared bbox
  bbox <- as.double(sf::st_bbox(x))
  dimx <- (bbox[3] - bbox[1])
  dimy <- (bbox[4] - bbox[2])
  maxdist <- max(dimx, dimy) * bbox_expand # Expand bbox
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
    gsub("{bbox}", paste0(bboxsquare, collapse = ","), q, fixed = TRUE)

  q <- gsub("512", as.character(res), q)
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

  img <- png::readPNG(filename) * 255
  # Give transparency if available
  if (dim(img)[3] == 4 & transparent) {
    nrow <- dim(img)[1]

    for (i in seq_len(nrow)) {
      row <- img[i, , ]
      alpha <- row[, 4] == 0
      row[alpha, ] <- NA
      img[i, , ] <- row
    }
  }


  # compose brick raster
  rout <-
    raster::brick(img, crs = sf::st_crs(3857)$proj4string)

  raster::extent(rout) <-
    raster::extent(bboxsquare[c(1, 3, 2, 4)])

  # End WMS

  return(rout)
  # nocov end
}

#' Get tiles from WMTS
#'
#' @inheritParams esp_getTiles
#'
#' @inheritParams getWMS
#'
#' @noRd
getWMTS <- function(x,
                    provs,
                    update_cache,
                    cache_dir,
                    verbose,
                    res,
                    zoom,
                    type,
                    transparent) {
  # nocov start
  # New fun

  x <- sf::st_transform(x, 4326)
  bbx <- sf::st_bbox(x)

  # select a default zoom level
  if (is.null(zoom)) {
    gz <- slippymath::bbox_tile_query(bbx)
    zoom <- min(gz[gz$total_tiles %in% 4:10, "zoom"])

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
  # nocov end
}


#' @name compose_tile_grid
#' @noRd
compose_tile_grid <- function(tile_grid, ext, images, transparent) {
  # nocov start
  bricks <- vector("list", nrow(tile_grid$tiles))
  for (i in seq_along(bricks)) {
    bbox <-
      slippymath::tile_bbox(
        tile_grid$tiles$x[i], tile_grid$tiles$y[i],
        tile_grid$zoom
      )
    img <- images[i]
    # special for png tiles
    if (ext == "png") {
      img <- png::readPNG(img) * 255

      if (dim(img)[3] == 4 & transparent) {
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
    r_img <-
      raster::brick(img, crs = sf::st_crs(3857)$proj4string)
    raster::extent(r_img) <-
      raster::extent(bbox[c(
        "xmin", "xmax",
        "ymin", "ymax"
      )])
    bricks[[i]] <- r_img
  }
  # if only one tile is needed
  if (length(bricks) == 1) {
    return(bricks[[1]])
  }
  # all tiles together
  rout <- do.call(raster::merge, bricks)
  return(rout)
  # nocov end
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
    # nocov start
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
    # nocov end
  }
