# mapSpain 1.1.0

- Migrated package vignettes to Quarto.
- Minimum **httr2** version is now **1.2.0** to ensure compatibility with
  **giscoR**.
- Query timeout can be controlled with `options(mapspain_timeout)` using
  `httr2::req_timeout()`. The default value is
  `httr2::req_timeout(..., seconds = 300)` (5 minutes).

# mapSpain 1.0.0

This major release introduces a full overhaul of the codebase and test suite.
Requests now use **httr2**, and cached files are reorganized into topic-based
subfolders for easier management.

> Because of internal changes, **existing caches are not compatible** with this
> release and must be rebuilt.

We have transitioned from `rappdirs::user_config_dir()` to `tools::R_user_dir()`
for managing the persistent cache directory. If you have an existing cache
directory, you will receive a one-time notification about this migration.

The package now requires **R ≥ 4.1**, and dependency updates improve both
performance and maintainability. All functions return tidy objects (tibbles or
`sf` objects with tibble data).

Several new functions and arguments have been added, some functions renamed, and
some others deprecated. All bundled datasets have been updated to their latest
versions.

## Breaking changes

- Minimum required R version is now **4.1.0**.
- Removed dependency on **slippymath** (#126).
- `providerEspTileOptions()` has been removed; use
  `leaflet::providerTileOptions()` instead.
- Removed dataset `?esp_munic.sf`.
- Removed dataset `?leaflet.providersESP.df` (superseded in **mapSpain**
  v0.8.0).
- Removed dataset `?pobmun19`; it has been replaced by `?pobmun25`.
- `esp_get_grid_EEA()` is deprecated and defunct, as the source file is no
  longer available.

## Deprecations and new function names

- `esp_getTiles()` has been renamed to `esp_get_tiles()` (old name still works).
- `esp_get_country()` has been renamed to `esp_get_spain()` (old name still
  works).
- In `esp_get_rivers()`:
  - Arguments `resolution` and `spatialtype` are deprecated.
  - Wetlands support has been moved to the new `esp_get_wetlands()` function.

## New features

- Added dataset `?esp_nuts_2024`, replacing `?esp_nuts.sf`.
- `esp_get_attributions()` retrieves tile provider attributions.
- `esp_get_countries_siane()` retrieves all countries available in SIANE at a
  given date.
- `esp_get_rivers()` gains a new `moveCAN` argument.
- `esp_get_spain_siane()` is analogous to `esp_get_spain()` but uses SIANE data.
- `esp_get_stations()` replaces `esp_get_railway(..., spatialtype = "point")`.
- `esp_get_tiles()` can be used with providers that need an API key.
- `esp_siane_bulk_download()` downloads all SIANE datasets to a specified
  `cache_dir` in a single step.

# mapSpain 0.10.0

- `esp_get_prov_siane()` fixes a bug when selecting columns (#115).
- `esp_get_comarca()` gains a new `type` argument to extract official (IGN),
  statistical (INE), agrarian or livestock comarcas (MAPA).

# mapSpain 0.9.2

- Adapted functions to the SIANE 2024 databases.
- `esp_dict_region_code()` and `esp_dict_translate()` improve dictionary
  support.

# mapSpain 0.9.1

- Updated actions and documentation.

# mapSpain 0.9.0

- Changes to how modifications to Canary Islands objects are handled (#101):
  - Added `esp_move_can()` as a helper to displace stand-alone `sf` objects in
    the Canary Islands.
  - `esp_move_can()` is used internally by all functions.
- `esp_detect_cache_dir()` shows the current cache directory.
- `mapSpain::layer_spatraster()` removed (was deprecated in **mapSpain** 0.6.2).

# mapSpain 0.8.0

- Improved download of NUTS data from **giscoR**.
- Upgraded `?esp_tiles_providers` to
  <https://dieghernan.github.io/leaflet-providersESP/> v1.3.3. New providers
  included:
  - `IDErioja.Base`
  - `IDErioja.Relieve`
  - `IDErioja.Claro`
  - `IDErioja.Oscuro`
- `esp_getTiles()` now supports non-OGC-compliant WMTS providers, such as Stamen
  or OpenStreetMap (see examples).

# mapSpain 0.7.0

- Upgraded `?leaflet.providersESP.df` to
  <https://dieghernan.github.io/leaflet-providersESP/> v1.3.2.
- Changed how the package manages tile providers:
  - `?leaflet.providersESP.df` is superseded in favor of `?esp_tiles_providers`.
  - You can use a custom URL with the `type` argument in `esp_getTiles()` (#88).
  - Added `esp_make_provider()` to help create custom providers.

# mapSpain 0.6.2

- `moveCAN` is now an explicit argument in the relevant functions.
- Deprecated `layer_spatraster()`. Use `tidyterra::geom_spatraster_rgb()`
  instead.
- `esp_get_comarca()` gets comarcas from INE.
- `esp_get_hex_prov()` and `esp_get_hex_ccaa()` fix geometries.
- Added functions to get simplified maps from INE:
  - `esp_get_simpl_prov()`.
  - `esp_get_simpl_ccaa()`.

# mapSpain 0.6.1

- `esp_getTiles()` fixes a bug when `mask = TRUE`.

# mapSpain 0.6.0

- Upgraded `?leaflet.providersESP.df` to
  <https://dieghernan.github.io/leaflet-providersESP/> v1.3.0. New providers:
  - `Catastro.BuildingPart`
  - `Catastro.AdministrativeBoundary`
  - `Catastro.AdministrativeUnit`
- `esp_getTiles()` gains a new `options` argument.
- Improved regex search on municipalities. Letter case is now ignored.

# mapSpain 0.5.0

- Rebuilt coding database to avoid encoding errors.
- Fixed Galician translations.
- Added grid functions (#61):
  - `esp_get_grid_MTN()`
  - `esp_get_grid_BDN()`
  - `esp_get_grid_EEA()`
  - `esp_get_grid_ESDAC()`

# mapSpain 0.4.0

- Switched from **raster** to **terra**.
- Cleaned up dependencies. Imagery packages moved to `Suggests`.
- Added `layer_spatraster()`.
- Moved examples to **ggplot2**.

# mapSpain 0.3.1

- Fixed an error on **CRAN** related to the cache folder (#52):
  - Added `mapSpain::esp_clear_cache()`.
- Updated documentation with `@family` tags.

# mapSpain 0.3.0

- `esp_set_cache_dir()` improves caching with `rappdirs::user_cache_dir()`. The
  `cache_dir` path is now stored, so it does not need to be set again in each
  new session.
- `esp_getTiles()` gains a new `zoommin` argument.
- Added tests with **testthat**.
- Updated documentation with new examples.
- Precomputed the vignette.

# mapSpain 0.2.3

- Moved minimum version of **giscoR** to v0.2.4.
- Fixed typos in `esp_dict_translate()` (#36).
- Do not run examples on tiles because the server sometimes does not respond.
- Refactored `sysdata.rda`.
- **CRAN** fixes:
  - Removed a broken link in `addProviderEspTiles()`.
  - Vignette removed (**CRAN** warning).
- Now the `cache` directory is created recursively.

# mapSpain 0.2.2

- Migrated examples, vignettes and README to **tmap**.
- Added vignette to the package.
- `esp_dict_region_code()` works with mixed casing, for example
  `esp_dict_region_code("aLbacEte", destination = "cpro")`.

# mapSpain 0.2.1

- Fixed a documentation typo: `cache_dir` should be set as
  `options(mapSpain_cache_dir = "path/to/dir")`.

# mapSpain 0.2.0

- Fixed DOI <https://doi.org/10.5281/zenodo.4318024>.
- Ported documentation to **roxygen2**.
- Included CartoBase ANE data
  <https://github.com/rOpenSpain/mapSpain/tree/sianedata>:
  - `mapSpain::esp_get_munic_siane()`
  - `mapSpain::esp_get_prov_siane()`
  - `mapSpain::esp_get_ccaa_siane()`
  - `mapSpain::esp_get_hypsobath()`
  - `mapSpain::esp_get_rivers()`
  - `mapSpain::esp_get_hydrobasin()`
  - `mapSpain::esp_get_capimun()`
  - `mapSpain::esp_get_roads()`
  - `mapSpain::esp_get_railway()`
- Muted warnings from **rgdal**.

# mapSpain 0.1.2

- Fixed a warning when **sf** was not loaded first.
- `mapSpain::esp_get_can_box()` gains a new `poly` option.
- Created new grids with `geogrid::calculate_grid()`.
- Added more years to `mapSpain::esp_get_munic()`.
- Moved to rOpenSpain organization.

# mapSpain 0.1.1

- Fixed **CRAN** submission.
- Added `mapSpain::esp_get_grid_prov()` and `mapSpain::esp_get_grid_ccaa()`.

# mapSpain 0.1.0

- Initial release.
