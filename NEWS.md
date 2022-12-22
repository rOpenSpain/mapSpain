# mapSpain 0.7.0

-   Upgrade `leaflet.providersESP.df` to
    <https://dieghernan.github.io/leaflet-providersESP/> v1.3.2.

-   Changes on how to package manages tiles providers:

    -   `leaflet.providersESP.df` is superseded in favor of
        `esp_tiles_providers`.
    -   You can use a custom url with the `type` argument in `esp_getTiles()`
        #88 .
    -   Add new function `esp_make_provider()` that helps to create custom
        providers.

# mapSpain 0.6.2

-   Now `moveCAN` is a explicit parameter in the relevant functions.

-   Deprecate `layer_spatraster().` Use `tidyterra::geom_spatraster_rgb()`
    instead.

-   Fix geometries on `esp_get_hex_prov()` and `esp_get_hex_ccaa()`.

-   Add new function to get comarcas from INE: `esp_get_comarca()`.

-   Add new functions to get simplified maps from INE:

    -   `esp_get_simpl_prov()`

    -   `esp_get_simpl_ccaa()`

# mapSpain 0.6.1

-   HOTFIX: Bug on `esp_getTiles()` when `mask = TRUE`.

# mapSpain 0.6.0

-   Upgrade `leaflet.providersESP.df` to
    <https://dieghernan.github.io/leaflet-providersESP/> v1.3.0. New providers:

    -   `Catastro.BuildingPart`
    -   `Catastro.AdministrativeBoundary`
    -   `Catastro.AdministrativeUnit`

-   Add new param `options` to `esp_getTiles()`.

-   Improve regex search on municipalities: Now the casing of the word is
    ignored.

# mapSpain 0.5.0

-   Rebuild coding database to avoid errors due to encoding.

-   Fix translations on Galician.

-   New grid functions (#61):

    -   `esp_get_grid_MTN()`
    -   `esp_get_grid_BDN()`
    -   `esp_get_grid_EEA()`
    -   `esp_get_grid_ESDAC()`

# mapSpain 0.4.0

-   Switch from `raster` to `terra`.
-   Clean up dependencies. Imagery packages moved to 'Suggests'.
-   Add `layer_spatraster()`.
-   Move examples to `ggplot2`

# mapSpain 0.3.1

-   Fix an error on CRAN related with the cache folder #52:

    -   Add `mapSpain::esp_clear_cache()`

-   Update docs with `@family` tag.

# mapSpain 0.3.0

-   Caching improvements: new function `esp_set_cache_dir()` based on
    `rappdirs::user_cache_dir()`. Now the cache_dir path is stored and it is not
    necessary to set it up again on a new session.
-   Add a new parameter `zoommin` on `esp_getTiles()`.
-   New tests with `testthat`.
-   Update on docs. New examples
-   Precompute vignette.

# mapSpain 0.2.3

-   Move minimum version of `giscoR` to v0.2.4

-   Fix typos on `esp_dict_translate()` #36.

-   Not run examples on tiles, as the server sometimes doesn't respond.

-   Refactor `sysdata.rda`.

-   CRAN fixes:

    -   Removed broken link on `addProviderEspTiles()`.
    -   Vignette removed (CRAN warning).

-   Now the `cache` directory is created recursively.

# mapSpain 0.2.2

-   Migrate examples, vignettes and README to `tmap`.
-   Add vignette to package.
-   `esp_dict_region_code()` works with mixed casings (e.g:
    `esp_dict_region_code("aLbacEte", destination = "cpro")`).

# mapSpain 0.2.1

-   **QUICKFIX**: Fix a typo on documentation: `cache_dir` should be set as
    `options(mapSpain_cache_dir = "path/to/dir")`.

# mapSpain 0.2.0

-   Fix DOI <https://doi.org/10.5281/zenodo.4318024>

-   Documentation ported to roxygen2/markdown.

-   Include CartoBase ANE data
    <https://github.com/rOpenSpain/mapSpain/tree/sianedata>:

    -   `mapSpain::esp_get_munic_siane()`
    -   `mapSpain::esp_get_prov_siane()`
    -   `mapSpain::esp_get_ccaa_siane()`
    -   `mapSpain::esp_get_hypsobath()`
    -   `mapSpain::esp_get_rivers()`
    -   `mapSpain::esp_get_hydrobasin()`
    -   `mapSpain::esp_get_capimun()`
    -   `mapSpain::esp_get_roads()`
    -   `mapSpain::esp_get_railway()`

-   Mute warnings from `rgdal`.

# mapSpain 0.1.2

-   Fix annoying warning if `sf` was not loaded first.
-   Include new `poly` option on `mapSpain::esp_get_can_box()`.
-   New grids created with `geogrid::calculate_grid()`.
-   Add more years on `mapSpain::esp_get_munic()`.
-   Move to rOpenSpain organization.

# mapSpain 0.1.1

-   Fix CRAN submission.
-   Added `mapSpain::esp_get_grid_prov()` and `mapSpain::esp_get_grid_ccaa()`.

# mapSpain 0.1.0

-   Initial release.
