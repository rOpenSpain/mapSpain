# Simplified versions of slippymath functions
# Internal developed by dieghernan
bbox_tile_query <- function(bbox, zoom_levels = 0:20) {
  deg2num <- function(lat_deg, lon_deg, zoom) {
    range_lats <- get_range_lats_merc()
    lat_deg <- min(max(range_lats[1], lat_deg), range_lats[2])
    lat_rad <- lat_deg * pi / 180
    n <- 2.0^zoom
    xtile <- floor((lon_deg + 180.0) / 360.0 * n)
    ytile <- floor(
      (1.0 - log(tan(lat_rad) + (1 / cos(lat_rad))) / pi) / 2.0 * n
    )
    c(xtile, ytile)
  }

  # For mins
  degs_min <- lapply(zoom_levels, function(x) {
    degs <- deg2num(bbox[4], bbox[1], x)
    data.frame(x_min = degs[1], y_min = degs[2], zoom = x, row.names = NULL)
  })
  degs_min <- do.call(rbind, degs_min)

  # For maxs
  degs_max <- lapply(zoom_levels, function(x) {
    degs <- deg2num(bbox[2], bbox[3], x)
    data.frame(x_max = degs[1], y_max = degs[2], zoom = x, row.names = NULL)
  })
  degs_max <- do.call(rbind, degs_max)

  merged <- merge(degs_min, degs_max)

  merged$y_dim <- merged$y_max - merged$y_min + 1
  merged$x_dim <- merged$x_max - merged$x_min + 1
  merged$total_tiles <- merged$y_dim * merged$x_dim
  merged <- merged[, c(setdiff(names(merged), "zoom"), "zoom")]

  merged
}

bbox_to_tile_grid <- function(bbox, zoom = NULL, max_tiles = NULL) {
  ext <- bbox_tile_query(bbox, zoom)
  # Implement
  x_seq <- seq(ext$x_min, ext$x_max)
  y_seq <- seq(ext$y_min, ext$y_max)
  tiles <- expand.grid(x = x_seq, y = y_seq)
  list(tiles = tiles, zoom = zoom)
}


tile_bbox <- function(x, y, zoom) {
  n <- 2^zoom

  # Four corners
  lon_deg_min <- x / n * 360 - 180
  lon_deg_max <- (x + 1) / n * 360 - 180
  lat_deg_min <- atan(sinh(pi * (1 - 2 * (y + 1) / n))) * 180 / pi
  lat_deg_max <- atan(sinh(pi * (1 - 2 * y / n))) * 180 / pi

  # To radians
  lon_rad_min <- lon_deg_min * (pi / 180)
  lon_rad_max <- lon_deg_max * (pi / 180)
  lat_rad_min <- lat_deg_min * (pi / 180)
  lat_rad_max <- lat_deg_max * (pi / 180)

  # Mercator Earth Radius
  earth_radius <- 6378137

  x_min_merc <- earth_radius * lon_rad_min
  x_max_merc <- earth_radius * lon_rad_max

  # Simplified
  y_min_merc <- earth_radius * log(tan(pi / 4 + lat_rad_min / 2))
  y_max_merc <- earth_radius * log(tan(pi / 4 + lat_rad_max / 2))

  structure(
    c(
      xmin = x_min_merc,
      ymin = y_min_merc,
      xmax = x_max_merc,
      ymax = y_max_merc
    ),
    class = "bbox",
    crs = sf::st_crs(3857)
  )
}

get_range_lats_merc <- function() {
  n <- 2^0
  lat_deg_min <- atan(sinh(pi * (1 - 2 * (1) / n))) * 180 / pi
  lat_deg_max <- atan(sinh(pi * (1 - 2 * 0 / n))) * 180 / pi

  c(lat_deg_min, lat_deg_max)
}
