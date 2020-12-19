roxygen2::roxygenise()

remotes::install_github("rOpenSpain/mapSpain")

tinytest::test_all()

devtools::check()
devtools::check_win_devel()

a <- esp_get_ccaa()

f <- esp_get_hex_ccaa()
plot(st_geometry(f))

f <- esp_get_hex_ccaa()
f <- st_make_valid(f)
st_is_valid(f)

st_crs(f)

library(mapSpain)

s <- esp_get_hex_prov()
s <- st_transform(s,3857)
st_is_valid(s)
par(mar=c(0,0,0,0))
plot(st_geometry(s))

devtools::build_readme()

tinytest::test_all()

help(giscoR)

usethis::use_cran_comments()

devtools::spell_check()

??mapSpain

devtools::release(check = TRUE)

devtools::check()

tinytest::test_all()

options(mapSpain_cache_dir="~/R/mapslib/GISCO")

devtools::revdep("mapSpain")
pkgdown::build_articles()
pkgdown::clean_site()
pkgdown::build_article("mapSpain")

pkgdown::build_articles_index()

pkgdown::build_site(lazy = TRUE)

devtools::spell_check()

pkgdown::clean_site()

sessionInfo()

tinytest::test_all()

hcl.pals("sequential")

devtools::check()
devtools::check_win_release()
devtools::check_win_devel()
devtools::check_win_oldrelease()
devtools::check_rhub()

devtools::build_manual(path = "./dev")
pkgdown::build_favicons(overwrite = TRUE)

pkgdown::build_site(lazy = TRUE)
pkgdown::build_articles(lazy = FALSE)

pkgdown::build_site()
pkgdown::build_reference_index()

pkgdown::build_favicons(overwrite = TRUE)

usethis::use_readme_rmd()
devtools::build_readme()
pkgdown::build_()

pkgdown::clean_site()
devtools::document()
interactive()

leaflet.providersESP.df

leafle
tinytest::test_all()



# Checks release


devtools::spell_check()
devtools::check_rhub()
devtools::check_win_release()
devtools::check_win_devel()
devtools::check_win_oldrelease()

devtools::release()


leaflet::addP

point <- st_point(c(-3.6886664,40.3922413))
point <- st_sfc(point)
point <- st_set_crs(point,4326)
point <- st_transform(point,3857)
#point <- st_buffer(point,1000)
a <- esp_getTiles(point, type = "Catastro.Parcela",
                           verbose = TRUE,
                  crop = TRUE,
                  res=256)


raster::plotRGB(a)
plot(st_geometry(point), add=TRUE)

point

library(mapSpain)

sessionInfo()

f <- mapSpain::leaflet.providersESP
f <- unique(f$provider)


library(goodpractice)

gp()

tinytest::test_all()

xx <- esp_get_ccaa()

xx <- sf::st_transform(xx,3857)

options(mapSpain_cache_dir = "~/R/mapslib/GISCO")

rt <- esp_getTiles(xx, type = f[1], verbose = TRUE, zoom = 4 )

par(mar=c(0,0,0,0))
cartography::tilesLayer(rt)

lintr::lint_package()


tinytest::test_all()
covr::report()


ff <- mapSpain::leaflet.providersESP

leaflet::addp

addTiles(
  map,
  urlTemplate = "//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
  attribution = NULL,
  layerId = NULL,
  group = NULL,
  options = tileOptions(),
  data = getMapData(map)
)


addProviderTiles(
  map,
  provider,
  layerId = NULL,
  group = NULL,
  options = providerTileOptions()
)

providerTileOptions(
  errorTileUrl = "",
  noWrap = FALSE,
  opacity = NULL,
  zIndex = NULL,
  updateWhenIdle = NULL,
  detectRetina = FALSE,
  ...
)

aa <- leaflet::WMSTileOptions()
bb <- leaflet::tileOptions(arg = 1)


ff <- mapSpain::leaflet.providersESP

library(leaflet)

cc <- do.call( leaflet::tileOptions,c(aa,bb))

cc

WMSTileOptions(
  styles = "",
  format = "image/jpeg",
  transparent = FALSE,
  version = "1.1.1",
  crs = NULL,
  ...
)

addWMSTiles(
  map,
  baseUrl,
  layerId = NULL,
  group = NULL,
  options = WMSTileOptions(),
  attribution = NULL,
  layers = "",
  data = getMapData(map)
)


devtools::build_manual("./dev")

library(goodpractice)

gp()

lintr::lint_package()

f <- esp_get_nuts(region = "Madrid", moveCAN = TRUE, epsg = 3857)
p <- esp_getTiles(f, type = "IGNBase.Gris", verbose = TRUE)
par(mar=c(0,0,0,0))
cartography::tilesLayer(p)


x <- f
update_cache = FALSE
cache_dir = NULL
verbose = FALSE
type = "IDErioja"
zoom = NULL
crop = TRUE
res = 512



xinit <- x

if (nrow(x) == 1 && sf::st_is(x, "POINT")) {
  x <- sf::st_transform(x, 3857)
  x <- sf::st_buffer(sf::st_geometry(x), 1000)
  crop <- FALSE
}

leafletProvidersESP <- mapSpain::leaflet.providersESP
provs <-
  leafletProvidersESP[leafletProvidersESP$provider == type,]

if (nrow(provs) == 0) {
  stop(
    "No match for type = '",
    type,
    "' found. Available providers are:\n\n",
    paste0("'", unique(leafletProvidersESP$provider), "'", collapse = ", ")
  )

}


cache_dir <- esp_hlp_cachedir(cache_dir)
cache_dir <- esp_hlp_cachedir(paste0(cache_dir, "/", type))


x <- sf::st_transform(x, 4326)
bbx <-
  sf::st_bbox(sf::st_transform(sf::st_as_sfc(sf::st_bbox(x)), 4326))

# select a default zoom level
if (is.null(zoom)) {
  gz <- slippymath::bbox_tile_query(bbx)
  zoom <- min(gz[gz$total_tiles %in% 4:10, "zoom"])

  if (verbose) {
    message("Auto zoom level: ", zoom)
  }
}
minZoom <- as.numeric()

!is.na(as.numeric(minZoom))

if (length(minZoom) > 0) {
  zoom <- max(zoom, minZoom)

  if (verbose & minZoom == zoom)
    message("\nSwiching. Minimum zoom for this provider is ", zoom, "\n")


}

