test_that("Validate providers errors", {
  expect_snapshot(error = TRUE, validate_provider(1))
  expect_snapshot(error = TRUE, validate_provider(list(a = 1, q = "2")))
  expect_error(validate_provider("FAKE"), "`type` should be one of")
})

test_that("Validate external", {
  skip_on_cran()
  custom_wms <- esp_make_provider(
    id = "an_id_for_caching",
    q = "https://idecyl.jcyl.es/geoserver/ge/wms?",
    service = "WMS",
    version = "1.3.0",
    format = "image/png",
    layers = "geolog_cyl_litologia"
  )
  expect_silent(res <- validate_provider(custom_wms))
  expect_true(is.list(res))
  expect_true(all(c("id", "q") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMS")
  expect_identical(get_tile_crs(res), "EPSG:3857")
  expect_identical(get_tile_ext(res), "png")

  cartodb_voyager <- list(
    id = "CartoDB_Voyager",
    q = "https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png"
  )
  expect_silent(res <- validate_provider(cartodb_voyager))
  expect_true(is.list(res))
  expect_true(all(c("id", "q") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_identical(get_tile_crs(res), "EPSG:3857")
  expect_identical(get_tile_ext(res), "png")

  # And a Custom OGR WMTS
  list_custom <- list(
    id = "noparams",
    q = paste0(
      "https://www.ign.es/wmts/ign-base?",
      "service=WMTS&request=GetTile",
      "&version=1.0.0&format=image/jpeg",
      "&layer=IGNBase-gris&style=default"
    )
  )
  res <- validate_provider(list_custom)
  expect_identical(res$tilematrixset, "GoogleMapsCompatible")
  expect_identical(res$tilematrix, "{z}")
  expect_identical(res$tilerow, "{y}")
  expect_identical(res$tilecol, "{x}")
  expect_identical(get_tile_crs(res), "EPSG:3857")
})

test_that("Validate internal", {
  skip_on_cran()
  # WMTS - Not Inspire style
  expect_silent(res <- validate_provider("IDErioja"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_identical(get_tile_crs(res), "EPSG:3857")
  expect_identical(get_tile_ext(res), "png")

  # WMTS
  expect_silent(res <- validate_provider("PNOA"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution", "tilematrixset") %in% names(res)))
  expect_true("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_identical(get_tile_crs(res), "EPSG:3857")

  # WMS v1.0.0
  expect_silent(res <- validate_provider("Catastro"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution", "srs") %in% names(res)))
  expect_true("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMS")
  expect_true(res$version < "1.3.0")
  expect_identical(get_tile_crs(res), "EPSG:3857")

  # WMS v1.3.0
  expect_silent(res <- validate_provider("ADIF"))
  expect_true(is.list(res))
  expect_true(all(c("id", "q", "attribution", "crs") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMS")
  expect_true(res$version >= "1.3.0")
  expect_identical(get_tile_crs(res), "EPSG:3857")

  # JPG
  expect_silent(res <- validate_provider("MTN"))
  expect_identical(get_tile_ext(res), "jpeg")
})

test_that("Validate all internals", {
  skip_on_cran()

  all_int <- mapSpain::esp_tiles_providers

  all_n <- names(all_int)

  expect_silent(
    validated <- lapply(all_n, function(nm) {
      static <- all_int[[nm]]$static
      static$id <- nm
      validate_provider(static)
    })
  )
  prov_type <- vapply(validated, guess_provider_type, FUN.VALUE = character(1))
  expect_snapshot(unique(prov_type))
  expect_silent(
    in_epsg <- vapply(
      validated,
      function(x) {
        ensure_null(get_tile_crs(x))
      },
      FUN.VALUE = character(1)
    )
  )
  expect_snapshot(unique(in_epsg))
})

test_that("Validate options", {
  skip_on_cran()

  wms_1_0_0 <- esp_make_provider(
    "ADIF1",
    q = "http://ideadif.adif.es/services/wms?",
    service = "WMS",
    version = "1.0.0",
    layers = "TN.RailTransportNetwork.RailwayLink"
  )
  prov_list <- validate_provider(wms_1_0_0)

  expect_identical(prov_list, modify_provider_list(prov_list))
  change_wms_version <- modify_provider_list(
    prov_list,
    options = list(version = "1.3.0")
  )
  expect_null(prov_list$crs)
  expect_identical(prov_list$srs, change_wms_version$crs)
  expect_identical(change_wms_version$version, "1.3.0")

  wms_1_3_0 <- esp_make_provider(
    "ADIF1",
    q = "http://ideadif.adif.es/services/wms?",
    service = "WMS",
    version = "1.3.0",
    layers = "TN.RailTransportNetwork.RailwayLink"
  )
  prov_list <- validate_provider(wms_1_3_0)
  # Make 1.0.0
  to_1_0_0 <- modify_provider_list(prov_list, list(version = "1.0.0"))
  expect_false("crs" %in% names(to_1_0_0))
  expect_true("crs" %in% names(prov_list))

  # Snapshot for Catastro package
  prov_list <- validate_provider("Catastro.Building")
  options <- list(version = "1.3.0", styles = "ELFCadastre", srs = "EPSG:25830")
  catastro_mod <- modify_provider_list(prov_list, options)

  expect_false(prov_list$id == catastro_mod$id)

  expect_true(get_tile_crs(catastro_mod) == "EPSG:25830")

  # Make url
  q <- catastro_mod$q
  q_opts <- catastro_mod[
    !names(catastro_mod) %in% c("id", "q", "attribution", "min_zoom")
  ]

  q_end <- paste0(names(q_opts), "=", q_opts, collapse = "&")
  final_q <- paste0(q, q_end)

  expect_identical(
    final_q,
    paste0(
      "https://ovc.catastro.meh.es/cartografia/INSPIRE/",
      "spadgcwms.aspx?service=WMS&version=1.3.0&request=GetMap&",
      "format=image/png&transparent=true&layers=BU.Building&crs=",
      "EPSG:25830&width=512&height=512&bbox={bbox}&styles=",
      "ELFCadastre"
    )
  )

  # Ignore TileMatrix fields in WMTS
  res <- validate_provider("PNOA")
  expect_equal(guess_provider_type(res), "WMTS")

  end <- modify_provider_list(res, list(TileMatrix = "FAKE"))
  expect_identical(end[-2], res[-2])
})


test_that("bbox WMTS", {
  skip_on_cran()

  df <- data.frame(x = c(0, 1), y = c(0, 0.5))
  sf_obj <- sf::st_as_sf(
    df,
    coords = c("x", "y"),
    crs = sf::st_crs("EPSG:3857")
  )
  init_bbox <- as.double(sf::st_bbox(sf_obj))
  expect_identical(
    get_tile_bbox(sf_obj, bbox_expand = 0, prov_type = "WMTS"),
    sf::st_bbox(sf_obj) |> sf::st_as_sfc()
  )
  # With a factor
  b2 <- get_tile_bbox(sf_obj, bbox_expand = .75, prov_type = "WMTS")
  b2_bbox <- as.double(sf::st_bbox(b2))

  x_rel <- diff(b2_bbox[c(1, 3)]) / diff(init_bbox[c(1, 3)])
  y_rel <- diff(b2_bbox[c(2, 4)]) / diff(init_bbox[c(2, 4)])
  expect_identical(x_rel, y_rel)
  expect_identical(x_rel - 1, 0.75)
})

test_that("bbox WMS", {
  skip_on_cran()

  df <- data.frame(x = c(0, 1), y = c(0, 0.5))
  sf_obj <- sf::st_as_sf(
    df,
    coords = c("x", "y"),
    crs = sf::st_crs("EPSG:3857")
  )
  init_bbox <- as.double(sf::st_bbox(sf_obj))
  zero_expand <- get_tile_bbox(sf_obj, bbox_expand = 0, prov_type = "WMS")
  expect_false(identical(zero_expand, sf::st_bbox(sf_obj) |> sf::st_as_sfc()))

  # Should be a square
  zero_bbox <- sf::st_bbox(zero_expand)
  new_rel <- diff(zero_bbox[c(1, 3)]) / diff(zero_bbox[c(2, 4)])
  expect_true(new_rel == 1)
  # With a factor

  b2 <- get_tile_bbox(sf_obj, bbox_expand = .75, prov_type = "WMS")
  b2_bbox <- as.double(sf::st_bbox(b2))
  new_rel <- diff(b2_bbox[c(1, 3)]) / diff(b2_bbox[c(2, 4)])
  expect_true(new_rel == 1)

  # Both midpoints should be the same
  coords_init <- sf::st_bbox(sf_obj) |>
    sf::st_as_sfc() |>
    sf::st_centroid() |>
    sf::st_coordinates()
  coords_expand <- b2 |>
    sf::st_centroid() |>
    sf::st_coordinates()
  expect_identical(coords_init, coords_expand)
})

test_that("External with apikeys", {
  skip_on_cran()

  url_thunder <- paste0(
    "https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=",
    "A_FAKE_API_KEY"
  )
  custom_wmts <- list(id = "ThunderTransport", q = url_thunder)

  expect_silent(res <- validate_provider(custom_wmts))
  expect_true(is.list(res))
  expect_true(all(c("id", "q") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_identical(get_tile_crs(res), "EPSG:3857")
  expect_identical(get_tile_ext(res), "png")

  # MapBox case
  custom_wmts <- list(
    id = "MadridMapBox",
    q = paste0(
      "https://api.mapbox.com/styles/v1/dieghernan/cmk2cz3wm00ds01sidzuoanfn/",
      "tiles/{z}/{x}/{y}?access_token=A_FAKE_API_KEY"
    )
  )

  expect_silent(res <- validate_provider(custom_wmts))
  expect_true(is.list(res))
  expect_true(all(c("id", "q") %in% names(res)))
  expect_false("min_zoom" %in% names(res))
  expect_true(guess_provider_type(res) == "WMTS")
  expect_identical(get_tile_crs(res), "EPSG:3857")
  expect_identical(get_tile_ext(res), "png")
})
