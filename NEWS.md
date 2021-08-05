# mapSpain (development version)

-   Caching improvements: new function `esp_set_cache_dir()` based on 
    `rappdirs::user_cache_dir()`. Now the cache_dir path is stored and it is 
    not necessary to set it up again on a new session.
-   Add a new parameter `zoommin` on `esp_getTiles()`.
-   New tests with `testthat`.
-   Update on docs. New examples
-   Precompute vignette.



# mapSpain 0.2.3

-   Move minimum version of `giscoR` to v0.2.4
-   Fix typos on `esp_dict_translate()` 
    [#36](https://github.com/rOpenSpain/mapSpain/issues/36)
-   Not run examples on tiles, as the server sometimes doesn't respond.
-   Refactor `sysdata.rda`.
-   CRAN fixes:
    -   Removed broken link on `addProviderEspTiles()`.
    -   Vignette removed (CRAN warning).
-   Now the `cache` directory is created recursively.

# mapSpain 0.2.2

-   Migrate examples, vignettes and README to `tmap`.
-   Add vignette to package.
-   `esp_dict_region_code()` works with mixed casings (e.g: `esp_dict_region_code("aLbacEte", destination = "cpro")`).

# mapSpain 0.2.1

-   **QUICKFIX**: Fix a typo on documentation: `cache_dir` should be set as `options(mapSpain_cache_dir = "path/to/dir")`.

# mapSpain 0.2.0

-   Fix DOI <https://doi.org/10.5281/zenodo.4318024>
-   Documentation ported to roxygen2/markdown.
-   Include CartoBase ANE data <https://github.com/rOpenSpain/mapSpain/tree/sianedata>:
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
