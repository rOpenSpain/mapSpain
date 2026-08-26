test_that("esp_get_tiles() returns NULL for WMS and WMTS while offline", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })
  x <- esp_nuts_2024[1, ]

  # WMTS
  expect_message(
    n <- esp_get_tiles(
      x,
      type = "IGNBase",
      update_cache = TRUE,
      verbose = TRUE
    ),
    "No internet connection"
  )
  expect_null(n)

  # WMS
  expect_message(
    n <- esp_get_tiles(
      x,
      type = "RedTransporte",
      update_cache = TRUE,
      verbose = TRUE
    ),
    "No internet connection"
  )
  expect_null(n)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("esp_get_tiles() returns NULL for HTTP 404 responses", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_if_gisco_offline()

  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  x <- esp_nuts_2024[1, ]
  expect_message(
    n <- esp_get_tiles(
      x,
      type = list(
        id = "errors",
        q = "https://a.basemaps.cartocdn.com/error/voyager/{z}/{x}/{y}.png"
      )
    ),
    "HTTP error"
  )
  expect_null(n)

  expect_message(
    n <- esp_get_tiles(x, update_cache = TRUE, verbose = TRUE),
    "HTTP error"
  )
  expect_null(n)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })
})

test_that("esp_get_tiles() rejects unsupported inputs and tile formats", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")

  df <- data.frame(a = 1, b = 2)

  expect_snapshot(error = TRUE, esp_get_tiles(df))

  ff <- esp_nuts_2024[1, ]

  expect_snapshot(
    error = TRUE,
    esp_get_tiles(ff, type = "IGNBase", options = list(format = "image/aabbcc"))
  )
})

test_that("esp_get_tiles() converts color tables to RGBA rasters", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  # Known problem on SSH certificate of catastro on ci
  skip_on_ci()

  cdir <- file.path(tempdir(), "wms_test")
  unlink(cdir, recursive = TRUE, force = TRUE)

  expect_length(list.files(file.path(cdir, "Catastro")), 0)
  # Single point
  point <- esp_get_capimun(munic = "^Segovia", cache_dir = cdir, epsg = 3857)

  # Buffer
  point <- sf::st_buffer(point, dist = 50)

  expect_silent(res <- esp_get_tiles(point, "Catastro", cache_dir = cdir))
  expect_length(list.files(file.path(cdir, "Catastro")), 1)
  # This file if read is only one layer
  r_orig <- suppressWarnings(
    terra::rast(
      list.files(file.path(cdir, "Catastro"), full.names = TRUE),
      noflip = TRUE
    )
  )

  expect_equal(terra::nlyr(r_orig), 1)
  expect_true(terra::has.colors(r_orig))
  expect_false(terra::has.RGB(r_orig))

  # But ours
  expect_s4_class(res, "SpatRaster")
  expect_named(res, c("red", "green", "blue", "alpha"))
  expect_true(terra::has.RGB(res))
  expect_false(any(terra::has.colors(res)))

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() applies crop and mask independently", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "wms_test_crop")
  unlink(cdir, recursive = TRUE, force = TRUE)

  # Poly
  poly <- esp_get_nuts(cache_dir = cdir, epsg = 3857, region = "Segovia")

  res <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    crop = FALSE,
    mask = FALSE,
    bbox_expand = 0.1
  )

  expect_identical(dim(res), c(512, 512, 4))

  # Crop
  res2 <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    crop = TRUE,
    mask = FALSE,
    bbox_expand = 0.1
  )
  expect_identical(dim(res)[1:2] <= dim(res2)[1:2], c(FALSE, FALSE))

  # No NAs here
  expect_false(anyNA(terra::values(res2)))

  # Masking...
  res3 <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    crop = FALSE,
    mask = TRUE,
    bbox_expand = 0.1
  )
  expect_identical(dim(res), dim(res3))

  # No NAs here
  expect_false(anyNA(terra::values(res)))

  # But in mask...
  expect_true(anyNA(terra::values(res3)))

  # Crop and mask
  res4 <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    crop = TRUE,
    mask = TRUE,
    bbox_expand = 0.1
  )
  expect_identical(dim(res2), dim(res4))
  # But in mask...
  expect_true(anyNA(terra::values(res4)))

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() returns rasters in the input CRS", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "test_rep")
  unlink(cdir, recursive = TRUE, force = TRUE)

  # Poly
  poly <- esp_get_nuts(cache_dir = cdir, epsg = 3857, region = "Segovia")

  res_3857 <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    crop = FALSE,
    mask = FALSE,
    bbox_expand = 0.1
  )

  expect_identical(terra::crs(res_3857), terra::crs(poly))

  poly_4258 <- esp_get_nuts(cache_dir = cdir, epsg = 4258, region = "Segovia")

  res_4258 <- esp_get_tiles(
    poly_4258,
    "IGNBase",
    cache_dir = cdir,
    crop = FALSE,
    mask = FALSE,
    bbox_expand = 0.1
  )
  expect_identical(terra::crs(res_4258), terra::crs(poly_4258))
  expect_false(terra::ncell(res_3857) == terra::ncell(res_4258))

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() controls alpha channels with transparent", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "wms_test_transp")
  unlink(cdir, recursive = TRUE, force = TRUE)

  # Poly
  poly <- esp_get_nuts(
    cache_dir = cdir,
    epsg = 3857,
    region = "Galicia",
    resolution = 60
  )

  res <- esp_get_tiles(
    poly,
    "CaminoDeSantiago",
    cache_dir = cdir,
    transparent = TRUE,
    bbox_expand = 0.1
  )

  expect_identical(dim(res), c(512, 512, 4))

  expect_named(res, c("red", "green", "blue", "alpha"))
  expect_true(anyNA(terra::values(res)))

  # No transparency...
  res2 <- esp_get_tiles(
    poly,
    "CaminoDeSantiago",
    cache_dir = cdir,
    transparent = FALSE,
    bbox_expand = 0.1
  )

  expect_identical(dim(res2), c(512, 512, 3))

  expect_named(res2, c("red", "green", "blue"))
  expect_false(anyNA(terra::values(res2)))

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() caches WMS tiles and respects WMS options", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "wms_test")
  unlink(cdir, recursive = TRUE, force = TRUE)

  expect_length(list.files(file.path(cdir, "CaminoDeSantiago")), 0)
  # Single point
  point <- esp_get_capimun(munic = "^Segovia", cache_dir = cdir, epsg = 3857)

  expect_silent(
    res <- esp_get_tiles(
      point,
      "CaminoDeSantiago",
      cache_dir = cdir,
      bbox_expand = 0
    )
  )

  expect_length(list.files(file.path(cdir, "CaminoDeSantiago")), 1)

  v <- as.vector(terra::ext(res))
  rel_x <- unname(diff(v[1:2])) / 2
  rel_y <- unname(diff(v[3:4])) / 2
  expect_identical(rel_x, rel_y)
  expect_equal(rel_x, 50)

  # See if cache is modified
  res2 <- esp_get_tiles(
    point,
    "CaminoDeSantiago",
    cache_dir = cdir,
    bbox_expand = 0
  )

  expect_identical(terra::crs(res2), terra::crs(point))
  expect_length(list.files(file.path(cdir, "CaminoDeSantiago")), 1)

  # Modify res
  res3 <- esp_get_tiles(
    point,
    "CaminoDeSantiago",
    cache_dir = cdir,
    bbox_expand = 0,
    res = 256
  )

  expect_equal(terra::ncol(res2), 512)

  expect_equal(terra::ncol(res3), 256)

  # Known problem on SSH certificate of catastro on ci
  skip_on_ci()

  # Test Catastro
  bbox <- c(222500, 4019500, 222700, 4019700)
  names(bbox) <- names(sf::st_bbox(point))
  class(bbox) <- class(sf::st_bbox(point))
  bbox <- sf::st_as_sfc(bbox)
  bbox <- sf::st_set_crs(bbox, 25830)

  cat_styles <- esp_get_tiles(
    bbox,
    type = "Catastro",
    options = list(
      version = "1.3.0",
      styles = "ELFCadastre",
      srs = "EPSG:25830"
    ),
    cache_dir = cdir
  )
  expect_identical(terra::crs(terra::vect(bbox)), terra::crs(cat_styles))

  expect_s4_class(cat_styles, "SpatRaster")
  expect_named(cat_styles, c("red", "green", "blue", "alpha"))

  cat_styles_noalpha <- esp_get_tiles(
    bbox,
    type = "Catastro",
    transparent = FALSE,
    options = list(
      version = "1.3.0",
      styles = "ELFCadastre",
      srs = "EPSG:25830"
    ),
    cache_dir = cdir
  )
  expect_s4_class(cat_styles_noalpha, "SpatRaster")
  expect_named(cat_styles_noalpha, c("red", "green", "blue"))

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() applies WMTS autozoom and provider limits", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "wmts_test")
  unlink(cdir, recursive = TRUE, force = TRUE)

  expect_length(list.files(file.path(cdir, "Catastro")), 0)
  # Single point
  point <- esp_get_capimun(munic = "^Segovia", cache_dir = cdir, epsg = 3857)

  expect_silent(
    res <- esp_get_tiles(
      point,
      "IGNBase",
      cache_dir = cdir,
      bbox_expand = 0,
      crop = TRUE
    )
  )

  # Increase zooms
  # Poly
  poly <- esp_get_nuts(cache_dir = cdir, epsg = 3857, region = "Segovia")

  res1 <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    bbox_expand = 0,
    zoom = 0,
    crop = TRUE
  )
  res_auto <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    bbox_expand = 0,
    crop = TRUE
  )

  res_delta <- esp_get_tiles(
    poly,
    "IGNBase",
    cache_dir = cdir,
    bbox_expand = 0,
    zoommin = 1,
    crop = TRUE
  )
  expect_gt(terra::ncell(res_auto), terra::ncell(res1))
  expect_gt(terra::ncell(res_delta), terra::ncell(res_auto))

  # With auto zoom...
  my_prov <- validate_provider("PNOA")
  auto <- esp_get_tiles(poly, "PNOA", zoom = 1)
  min <- esp_get_tiles(poly, "PNOA", zoom = my_prov$min_zoom)
  expect_identical(terra::ncell(auto), terra::ncell(min))
  expect_false(my_prov$min_zoom == 1)

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("Single WMTS points report automatic zoom only when verbose", {
  point <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)

  quiet_result <- expect_silent(prepare_tile_geometry(
    point,
    NULL,
    TRUE,
    "WMTS",
    FALSE
  ))
  expect_identical(quiet_result$zoom, 18)
  expect_false(quiet_result$crop)

  expect_snapshot(
    result <- prepare_tile_geometry(point, NULL, TRUE, "WMTS", TRUE)
  )
  expect_identical(result$zoom, 18)
  expect_false(result$crop)
})

test_that("WMTS minimum zoom messages respect verbose", {
  provider <- validate_provider("PNOA")
  min_zoom <- as.numeric(provider$min_zoom)
  expect_gt(min_zoom, 1)

  quiet_zoom <- expect_silent(resolve_wmts_zoom(NULL, provider, 1, 0, FALSE))
  expect_identical(quiet_zoom, min_zoom)

  expect_snapshot(verbose_zoom <- resolve_wmts_zoom(NULL, provider, 1, 0, TRUE))
  expect_identical(verbose_zoom, min_zoom)
})

test_that("esp_getTiles() remains an alias for esp_get_tiles()", {
  expect_identical(esp_getTiles, esp_get_tiles)
})

test_that("esp_get_tiles() supports legacy WMS provider options", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "old_test")
  unlink(cdir, recursive = TRUE, force = TRUE)

  poly <- esp_get_capimun(
    munic = "^Santiago de compos",
    epsg = 3857,
    cache = FALSE,
    cache_dir = cdir
  )
  poly <- sf::st_buffer(poly, 2000)

  tile2 <- esp_get_tiles(
    poly,
    type = "CaminoDeSantiago",
    options = list(
      version = "1.3.0",
      crs = "EPSG:25830",
      format = "image/jpeg"
    ),
    cache_dir = cdir
  )

  expect_s4_class(tile2, "SpatRaster")

  # Known problem on SSH certificate of catastro on ci
  skip_on_ci()
  tile <- esp_get_tiles(
    poly,
    type = "Catastro.Building",
    options = list(styles = "elfcadastre"),
    cache_dir = cdir
  )
  expect_s4_class(tile, "SpatRaster")

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() accepts custom WMS providers", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "custom_wms")
  unlink(cdir, recursive = TRUE, force = TRUE)

  lugo <- esp_get_prov("lugo", epsg = 3857, cache_dir = cdir)

  custom_wms <- list(
    id = "new_cached_test",
    q = paste0(
      "https://www.ign.es/wms-inspire/camino-santiago?",
      "service=WMS&version=1.3.0&request=GetMap&format=image/png&",
      "transparent=true&layers=camino_frances&crs=EPSG:3857"
    )
  )

  tile <- esp_get_tiles(lugo, type = custom_wms, cache_dir = cdir)
  expect_s4_class(tile, "SpatRaster")
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() accepts custom WMTS templates and extensions", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")
  cdir <- file.path(tempdir(), "custom_wmts")
  unlink(cdir, recursive = TRUE, force = TRUE)

  segovia <- esp_get_prov("segovia", epsg = 3857, cache_dir = cdir)
  custom_wmts <- list(
    id = "cyl_wmts",
    q = paste0(
      "https://www.ign.es/wmts/ign-base?",
      "request=GetTile&service=WMTS&version=1.0.0",
      "&format=image/png",
      "&tilematrixset=GoogleMapsCompatible",
      "&layer=IGNBaseTodo-nofondo&style=default"
    )
  )

  tile <- esp_get_tiles(segovia, type = custom_wmts, cache_dir = cdir)
  expect_s4_class(tile, "SpatRaster")

  # Non-INSPIRE e.g OSM
  another_wms <- list(
    id = "OSM2",
    q = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
  )

  tile2 <- esp_get_tiles(segovia, type = another_wms, cache_dir = cdir)
  expect_s4_class(tile2, "SpatRaster")

  # Can extract whole world
  world <- giscoR::gisco_get_countries(epsg = 3857, cache_dir = cdir)
  expect_silent(
    tileworld <- esp_get_tiles(
      world,
      type = another_wms,
      crop = FALSE,
      cache_dir = cdir
    )
  )
  expect_s4_class(tileworld, "SpatRaster")

  # With another extension
  esri_wsm <- list(
    id = "ESRI_WorldStreetMap",
    q = paste0(
      "https://server.arcgisonline.com/ArcGIS/rest/services/",
      "World_Street_Map/MapServer/tile/{z}/{y}/{x}.jpg"
    )
  )

  tile3 <- esp_get_tiles(segovia, type = esri_wsm, cache_dir = cdir)
  expect_s4_class(tile3, "SpatRaster")
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() supports authenticated Thunderforest providers", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")

  # Skip if not API KEY
  apikey <- Sys.getenv("THUNDERFOREST_API_KEY", "")
  if (!nzchar(apikey)) {
    skip("Need a ThunderForest API KEY")
  }

  cdir <- file.path(tempdir(), "custom_thunder")
  unlink(cdir, recursive = TRUE, force = TRUE)

  segovia <- esp_get_prov("segovia", epsg = 3857, cache_dir = cdir)
  thunder <- list(
    id = "ThunderForest",
    q = paste0(
      "https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=",
      apikey
    )
  )

  tile <- esp_get_tiles(segovia, type = thunder, cache_dir = cdir, zoom = 2)
  expect_s4_class(tile, "SpatRaster")
  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("esp_get_tiles() supports authenticated Mapbox providers", {
  skip_on_cran()
  skip_if_not_installed("terra")
  skip_on_os("mac")

  # Skip if not API KEY
  apikey <- Sys.getenv("MAPBOX_API_KEY", "")
  if (!nzchar(apikey)) {
    skip("Need a MapBox API KEY")
  }

  cdir <- file.path(tempdir(), "custom_mapbox")
  unlink(cdir, recursive = TRUE, force = TRUE)

  segovia <- esp_get_prov("segovia", epsg = 3857, cache_dir = cdir)
  mapbox <- list(
    id = "MadridMapBox",
    q = paste0(
      "https://api.mapbox.com/styles/v1/dieghernan/cmk2cz3wm00ds01sidzuoanfn/",
      "tiles/{z}/{x}/{y}?access_token=",
      apikey
    )
  )

  tile <- esp_get_tiles(segovia, type = mapbox, cache_dir = cdir, zoom = 2)
  expect_s4_class(tile, "SpatRaster")
  unlink(cdir, recursive = TRUE, force = TRUE)
})
