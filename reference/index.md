# Package index

## Political and administrative boundary datasets

These functions return [sf](https://CRAN.R-project.org/package=sf)
objects representing political and administrative boundaries.

### CartoBase ANE (Atlas Nacional de España)

Datasets sourced from CartoBase ANE.

- [`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/reference/esp_get_capimun.md)
  : City where the municipal public authorities are based from SIANE
- [`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa_siane.md)
  : Autonomous Communities and Cities of Spain from SIANE
- [`esp_get_countries_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_countries_siane.md)
  : Countries of the world from SIANE
- [`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md)
  : Municipalities of Spain from SIANE
- [`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov_siane.md)
  : Provinces of Spain from SIANE
- [`esp_get_spain_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain_siane.md)
  : Boundaries of Spain from SIANE
- [`esp_siane_bulk_download()`](https://ropenspain.github.io/mapSpain/reference/esp_siane_bulk_download.md)
  : SIANE bulk download

### GISCO

Datasets sourced from GISCO and Eurostat.

- [`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa.md)
  : Autonomous Communities and Cities of Spain from GISCO
- [`esp_get_munic()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic.md)
  : Municipalities of Spain from GISCO
- [`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/reference/esp_get_nuts.md)
  : Territorial Spanish units for statistics (NUTS) dataset
- [`esp_get_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov.md)
  : Provinces of Spain from GISCO
- [`esp_get_spain()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain.md)
  : Boundaries of Spain from GISCO

### Additional boundary helpers

- [`esp_get_can_box()`](https://ropenspain.github.io/mapSpain/reference/esp_get_can_box.md)
  [`esp_get_can_provinces()`](https://ropenspain.github.io/mapSpain/reference/esp_get_can_box.md)
  : Canary Islands inset box and outline

- [`esp_move_can()`](https://ropenspain.github.io/mapSpain/reference/esp_move_can.md)
  :

  Displace a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
  object located in the Canary Islands

- [`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/reference/esp_get_comarca.md)
  : Comarcas of Spain

- [`esp_get_hex_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md)
  [`esp_get_hex_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md)
  [`esp_get_grid_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md)
  [`esp_get_grid_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md)
  :

  Get a [`sf`](https://r-spatial.github.io/sf/reference/sf.html) hexbin
  or squared `POLYGON` of Spain

- [`esp_get_simpl_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_simpl.md)
  [`esp_get_simpl_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_simpl.md)
  : Simplified map of provinces and Autonomous Communities and Cities of
  Spain

## Static map tiles and imagery

Functions that return static map tiles or add Spanish public
administration basemaps to interactive
[leaflet](https://CRAN.R-project.org/package=leaflet) maps.

- [`addProviderEspTiles()`](https://ropenspain.github.io/mapSpain/reference/addProviderEspTiles.md)
  :

  Add a tile layer from Spanish public administrations to a
  [leaflet](https://CRAN.R-project.org/package=leaflet) map

- [`esp_get_tiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  [`esp_get_attributions()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  : Get static map tiles from public administrations of Spain

- [`esp_make_provider()`](https://ropenspain.github.io/mapSpain/reference/esp_make_provider.md)
  : Create a custom tile provider

- [`plotRGB(`*`<SpatRaster>`*`)`](https://rspatial.github.io/terra/reference/plotRGB.html)
  : Red-Green-Blue plot of a multi-layered SpatRaster (from terra)

- [`addProviderTiles()`](https://rstudio.github.io/leaflet/reference/addProviderTiles.html)
  [`providerTileOptions()`](https://rstudio.github.io/leaflet/reference/addProviderTiles.html)
  : Add a tile layer from a known map provider (from leaflet)

- [`geom_spatraster_rgb()`](https://dieghernan.github.io/tidyterra/reference/geom_spatraster_rgb.html)
  :

  Visualise `SpatRaster` objects as images (from tidyterra)

## Natural features

These functions return [sf](https://CRAN.R-project.org/package=sf)
objects with natural features.

- [`esp_get_hydrobasin()`](https://ropenspain.github.io/mapSpain/reference/esp_get_hydrobasin.md)
  : River basin districts of Spain from SIANE
- [`esp_get_hypsobath()`](https://ropenspain.github.io/mapSpain/reference/esp_get_hypsobath.md)
  : Hypsometry and bathymetry of Spain from SIANE
- [`esp_get_rivers()`](https://ropenspain.github.io/mapSpain/reference/esp_get_landwater.md)
  [`esp_get_wetlands()`](https://ropenspain.github.io/mapSpain/reference/esp_get_landwater.md)
  : Rivers and wetlands of Spain from SIANE

## Transport infrastructure

These functions return [sf](https://CRAN.R-project.org/package=sf)
objects with transport infrastructure features.

- [`esp_get_railway()`](https://ropenspain.github.io/mapSpain/reference/esp_get_railway.md)
  [`esp_get_stations()`](https://ropenspain.github.io/mapSpain/reference/esp_get_railway.md)
  : Railways of Spain from SIANE
- [`esp_get_roads()`](https://ropenspain.github.io/mapSpain/reference/esp_get_roads.md)
  : Roads of Spain from SIANE

## Cache management

- [`esp_clear_cache()`](https://ropenspain.github.io/mapSpain/reference/esp_clear_cache.md)
  :

  Clear your [mapSpain](https://CRAN.R-project.org/package=mapSpain)
  cache directory

- [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
  [`esp_detect_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
  :

  Set your [mapSpain](https://CRAN.R-project.org/package=mapSpain) cache
  directory

## Dictionary and translation helpers

Translate Spanish subdivision names across languages and coding
standards.

- [`esp_dict_region_code()`](https://ropenspain.github.io/mapSpain/reference/esp_dict.md)
  [`esp_dict_translate()`](https://ropenspain.github.io/mapSpain/reference/esp_dict.md)
  : Convert and translate Spanish subdivision names and codes

## Datasets

Datasets included with
[mapSpain](https://CRAN.R-project.org/package=mapSpain).

- [`esp_codelist`](https://ropenspain.github.io/mapSpain/reference/esp_codelist.md)
  : Spanish subdivision codes and names

- [`esp_nuts_2024`](https://ropenspain.github.io/mapSpain/reference/esp_nuts_2024.md)
  :

  NUTS 2024 for Spain
  [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object

- [`esp_tiles_providers`](https://ropenspain.github.io/mapSpain/reference/esp_tiles_providers.md)
  : Public WMS and WMTS providers for Spain

- [`pobmun25`](https://ropenspain.github.io/mapSpain/reference/pobmun25.md)
  : Population of Spain by municipality (2025)

## Geographical grid datasets

Geographical grids are agreed, defined and harmonized grid networks with
standardized locations and grid cell sizes.

- [`esp_get_grid_BDN()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_BDN.md)
  [`esp_get_grid_BDN_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_BDN.md)
  : National geographic grids from BDN (Nature Data Bank)
- [`esp_get_grid_ESDAC()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_ESDAC.md)
  : National geographic grids from the European Soil Data Centre (ESDAC)
- [`esp_get_grid_MTN()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_MTN.md)
  : National geographic grids from IGN MTN (Mapa Topografico Nacional)

## About the package

- [`mapSpain`](https://ropenspain.github.io/mapSpain/reference/mapSpain-package.md)
  [`mapSpain-package`](https://ropenspain.github.io/mapSpain/reference/mapSpain-package.md)
  : mapSpain: Administrative Boundaries and Static Map Tiles for Spain
