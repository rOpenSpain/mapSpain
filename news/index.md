# Changelog

## mapSpain 1.2.0

- Refactored internal helpers for downloading and reading geospatial
  files, SIANE file handling, EPSG validation, subdivision-code
  filtering, municipal metadata enrichment, empty-result messages and
  Canary Islands displacement. This is intended to simplify maintenance
  without changing the public API.
- Consolidated repeated Autonomous Community or City, province and
  municipality metadata across GISCO, SIANE, simplified and gridmap
  getters.
- Further simplified internal cache handling, `sf` output finalization,
  WMTS tile retrieval, dictionary translation and no-match messages.
  These changes are intended to improve maintainability without changing
  user-facing behavior.
- Reviewed roxygen2 documentation, generated Rd files and prose
  documentation for consistent terminology and clearer user-facing
  messages. This work was completed with AI assistance and human review.
- This internal refactor was developed with AI assistance and reviewed
  through focused package checks, including
  [`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html)
  followed by `lintr::lint_package()`.

## mapSpain 1.1.0

CRAN release: 2026-03-26

- Migrated package vignettes to Quarto.
- Minimum **httr2** version is now **1.2.0** to ensure compatibility
  with **giscoR**.
- Query timeout can be controlled with `options(mapspain_timeout)` using
  [`httr2::req_timeout()`](https://httr2.r-lib.org/reference/req_timeout.html).
  The default value is `httr2::req_timeout(..., seconds = 300)` (5
  minutes).

## mapSpain 1.0.0

CRAN release: 2026-01-17

This major release introduces a full overhaul of the codebase and test
suite. Requests now use **httr2**, and cached files are reorganized into
topic-based subfolders for easier management.

> Because of internal changes, **existing caches are not compatible**
> with this release and must be rebuilt.

We have transitioned from
[`rappdirs::user_config_dir()`](https://rappdirs.r-lib.org/reference/user_data_dir.html)
to [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html) for
managing the persistent cache directory. If you have an existing cache
directory, you will receive a one-time notification about this
migration.

The package now requires **R \>= 4.1**, and dependency updates improve
performance and maintainability. All functions return tidy objects,
either tibbles or `sf` objects with tibble data.

Several new functions and arguments have been added, some functions
renamed and others deprecated. All bundled datasets have been updated to
their latest versions.

### Breaking changes

- Minimum required R version is now **4.1.0**.
- Removed dependency on **slippymath**
  ([\#126](https://github.com/rOpenSpain/mapSpain/issues/126)).
- [`esp_get_grid_EEA()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_EEA.md)
  is deprecated and defunct because the source file is no longer
  available.
- `providerEspTileOptions()` has been removed, use
  [`leaflet::providerTileOptions()`](https://rstudio.github.io/leaflet/reference/addProviderTiles.html)
  instead.
- Removed dataset `?esp_munic.sf`.
- Removed dataset `?leaflet.providersESP.df`, superseded in **mapSpain**
  v0.8.0.
- Removed dataset `?pobmun19`, replaced by
  [`?pobmun25`](https://ropenspain.github.io/mapSpain/reference/pobmun25.md).

### Deprecations and new function names

- [`esp_get_country()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain.md)
  has been renamed to
  [`esp_get_spain()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain.md),
  the old name still works.
- [`esp_get_rivers()`](https://ropenspain.github.io/mapSpain/reference/esp_get_landwater.md)
  deprecates the `resolution` and `spatialtype` arguments. Wetlands
  support has been moved to the new
  [`esp_get_wetlands()`](https://ropenspain.github.io/mapSpain/reference/esp_get_landwater.md)
  function.
- [`esp_getTiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  has been renamed to
  [`esp_get_tiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md),
  the old name still works.

### New features

- Added dataset
  [`?esp_nuts_2024`](https://ropenspain.github.io/mapSpain/reference/esp_nuts_2024.md),
  replacing `?esp_nuts.sf`.
- [`esp_get_attributions()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  retrieves tile provider attributions.
- [`esp_get_countries_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_countries_siane.md)
  retrieves all countries available in SIANE at a given date.
- [`esp_get_rivers()`](https://ropenspain.github.io/mapSpain/reference/esp_get_landwater.md)
  gains a new `moveCAN` argument.
- [`esp_get_spain_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain_siane.md)
  is analogous to
  [`esp_get_spain()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain.md)
  but uses SIANE data.
- [`esp_get_stations()`](https://ropenspain.github.io/mapSpain/reference/esp_get_railway.md)
  replaces `esp_get_railway(..., spatialtype = "point")`.
- [`esp_get_tiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  can be used with providers that need an API key.
- [`esp_siane_bulk_download()`](https://ropenspain.github.io/mapSpain/reference/esp_siane_bulk_download.md)
  downloads all SIANE datasets to a specified `cache_dir` in a single
  step.

## mapSpain 0.10.0

CRAN release: 2024-12-15

- [`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/reference/esp_get_comarca.md)
  gains a new `type` argument to extract official (IGN), statistical
  (INE), agrarian or livestock comarcas (MAPA).
- [`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov_siane.md)
  fixes a bug when selecting columns
  ([\#115](https://github.com/rOpenSpain/mapSpain/issues/115)).

## mapSpain 0.9.2

CRAN release: 2024-08-26

- Adapted functions to the SIANE 2024 databases.
- [`esp_dict_region_code()`](https://ropenspain.github.io/mapSpain/reference/esp_dict.md)
  and
  [`esp_dict_translate()`](https://ropenspain.github.io/mapSpain/reference/esp_dict.md)
  improve dictionary support.

## mapSpain 0.9.1

CRAN release: 2024-06-10

- Updated actions and documentation.

## mapSpain 0.9.0

CRAN release: 2024-01-23

- Changed how modifications to Canary Islands objects are handled
  ([\#101](https://github.com/rOpenSpain/mapSpain/issues/101)).
- [`esp_detect_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
  shows the current cache directory.
- [`esp_move_can()`](https://ropenspain.github.io/mapSpain/reference/esp_move_can.md)
  was added as a helper to displace standalone `sf` objects in the
  Canary Islands.
- [`esp_move_can()`](https://ropenspain.github.io/mapSpain/reference/esp_move_can.md)
  is used internally by all functions.
- `layer_spatraster()` was removed, it was deprecated in **mapSpain**
  0.6.2.

## mapSpain 0.8.0

CRAN release: 2023-07-12

- Improved download of NUTS data from **giscoR**.
- Upgraded
  [`?esp_tiles_providers`](https://ropenspain.github.io/mapSpain/reference/esp_tiles_providers.md)
  to <https://dieghernan.github.io/leaflet-providersESP/> v1.3.3. New
  providers include `IDErioja.Base`, `IDErioja.Relieve`,
  `IDErioja.Claro` and `IDErioja.Oscuro`.
- [`esp_getTiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  now supports non-OGC-compliant WMTS providers, such as Stamen or
  OpenStreetMap. See examples.

## mapSpain 0.7.0

CRAN release: 2022-12-22

- Changed how the package manages tile providers.
- Upgraded `?leaflet.providersESP.df` to
  <https://dieghernan.github.io/leaflet-providersESP/> v1.3.2.
- `?leaflet.providersESP.df` is superseded in favor of
  [`?esp_tiles_providers`](https://ropenspain.github.io/mapSpain/reference/esp_tiles_providers.md).
- [`esp_getTiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  can use a custom URL with the `type` argument
  ([\#88](https://github.com/rOpenSpain/mapSpain/issues/88)).
- [`esp_make_provider()`](https://ropenspain.github.io/mapSpain/reference/esp_make_provider.md)
  was added to help create custom providers.

## mapSpain 0.6.2

CRAN release: 2022-08-13

- `moveCAN` is now an explicit argument in the relevant functions.
- Deprecated `layer_spatraster()`. Use
  [`tidyterra::geom_spatraster_rgb()`](https://dieghernan.github.io/tidyterra/reference/geom_spatraster_rgb.html)
  instead.
- [`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/reference/esp_get_comarca.md)
  gets comarcas from INE.
- [`esp_get_hex_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md)
  and
  [`esp_get_hex_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md)
  fix geometries.
- Added functions to get simplified maps from INE,
  [`esp_get_simpl_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_simpl.md)
  and
  [`esp_get_simpl_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_simpl.md).

## mapSpain 0.6.1

CRAN release: 2022-02-25

- [`esp_getTiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  fixes a bug when `mask = TRUE`.

## mapSpain 0.6.0

CRAN release: 2022-02-18

- Improved regex search on municipalities. Letter case is now ignored.
- Upgraded `?leaflet.providersESP.df` to
  <https://dieghernan.github.io/leaflet-providersESP/> v1.3.0. New
  providers include `Catastro.BuildingPart`,
  `Catastro.AdministrativeBoundary` and `Catastro.AdministrativeUnit`.
- [`esp_getTiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  gains a new `options` argument.

## mapSpain 0.5.0

CRAN release: 2022-01-25

- Rebuilt coding database to avoid encoding errors.
- Fixed Galician translations.
- Added grid functions
  [`esp_get_grid_MTN()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_MTN.md),
  [`esp_get_grid_BDN()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_BDN.md),
  [`esp_get_grid_EEA()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_EEA.md)
  and
  [`esp_get_grid_ESDAC()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_ESDAC.md)
  ([\#61](https://github.com/rOpenSpain/mapSpain/issues/61)).

## mapSpain 0.4.0

CRAN release: 2021-10-14

- Switched from **raster** to **terra**.
- Cleaned up dependencies. Imagery packages moved to `Suggests`.
- Added `layer_spatraster()`.
- Moved examples to **ggplot2**.

## mapSpain 0.3.1

CRAN release: 2021-09-10

- Fixed an error on **CRAN** related to the cache folder
  ([\#52](https://github.com/rOpenSpain/mapSpain/issues/52)).
- Added
  [`esp_clear_cache()`](https://ropenspain.github.io/mapSpain/reference/esp_clear_cache.md).
- Updated documentation with `@family` tags.

## mapSpain 0.3.0

CRAN release: 2021-09-01

- Added tests with **testthat**.
- Precomputed the vignette.
- Refactored `sysdata.rda`.
- Updated documentation with new examples.
- [`esp_getTiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  gains a new `zoommin` argument.
- [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
  improves caching with
  [`rappdirs::user_cache_dir()`](https://rappdirs.r-lib.org/reference/user_cache_dir.html).
  The `cache_dir` path is now stored, so it does not need to be set
  again in each new session.

## mapSpain 0.2.3

CRAN release: 2021-04-25

- Moved minimum version of **giscoR** to v0.2.4.
- Fixed typos in
  [`esp_dict_translate()`](https://ropenspain.github.io/mapSpain/reference/esp_dict.md)
  ([\#36](https://github.com/rOpenSpain/mapSpain/issues/36)).
- Do not run examples on tiles because the server sometimes does not
  respond.
- **CRAN** fixes removed a broken link in
  [`addProviderEspTiles()`](https://ropenspain.github.io/mapSpain/reference/addProviderEspTiles.md)
  and removed the vignette after a **CRAN** warning.
- Refactored `sysdata.rda`.
- Now the `cache` directory is created recursively.

## mapSpain 0.2.2

CRAN release: 2021-04-17

- Migrated examples, vignettes and README to **tmap**.
- Added vignette to the package.
- [`esp_dict_region_code()`](https://ropenspain.github.io/mapSpain/reference/esp_dict.md)
  works with mixed casing, for example
  `esp_dict_region_code("aLbacEte", destination = "cpro")`.

## mapSpain 0.2.1

CRAN release: 2021-03-19

- Fixed a documentation typo: `cache_dir` must be set as
  `options(mapSpain_cache_dir = "path/to/dir")`.

## mapSpain 0.2.0

CRAN release: 2021-02-25

- Fixed DOI <https://doi.org/10.5281/zenodo.4318024>.
- Ported documentation to **roxygen2**.
- Included CartoBase ANE (Atlas Nacional de España) data:
  <https://github.com/rOpenSpain/mapSpain/tree/sianedata>, with
  [`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md),
  [`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov_siane.md),
  [`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa_siane.md),
  [`esp_get_hypsobath()`](https://ropenspain.github.io/mapSpain/reference/esp_get_hypsobath.md),
  [`esp_get_rivers()`](https://ropenspain.github.io/mapSpain/reference/esp_get_landwater.md),
  [`esp_get_hydrobasin()`](https://ropenspain.github.io/mapSpain/reference/esp_get_hydrobasin.md),
  [`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/reference/esp_get_capimun.md),
  [`esp_get_roads()`](https://ropenspain.github.io/mapSpain/reference/esp_get_roads.md)
  and
  [`esp_get_railway()`](https://ropenspain.github.io/mapSpain/reference/esp_get_railway.md).
- Muted warnings from **rgdal**.

## mapSpain 0.1.2

CRAN release: 2021-01-05

- Fixed a warning when **sf** was not loaded first.
- Added more years to
  [`esp_get_munic()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic.md).
- Created new grids with `geogrid::calculate_grid()`.
- Moved to rOpenSpain organization.
- [`esp_get_can_box()`](https://ropenspain.github.io/mapSpain/reference/esp_get_can_box.md)
  gains a new `poly` option.

## mapSpain 0.1.1

CRAN release: 2020-11-30

- Fixed **CRAN** submission.
- Added
  [`esp_get_grid_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md)
  and
  [`esp_get_grid_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md).

## mapSpain 0.1.0

- Initial release.
