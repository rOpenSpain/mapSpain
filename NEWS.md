# mapSpain 0.2.2

-   Migrate examples, vignettes and README to `tmap`
-   `esp_dict_region_code()` works with mixed casings (e.g: `esp_dict_region_code("aLbacEte", destination = "cpro")`).

# mapSpain 0.2.1

-   **QUICKFIX**: Fix a typo on documentation: `cache_dir` should be set as `options(mapSpain_cache_dir = "path/to/dir")`.

# mapSpain 0.2.0

-   Fix DOI <https://doi.org/10.5281/zenodo.4318024>

-   Documentation ported to roxygen2/markdown

-   Include CartoBase ANE data <https://github.com/rOpenSpain/mapSpain/tree/sianedata>

    -   `mapSpain::esp_get_munic_siane()`
    -   `mapSpain::esp_get_prov_siane()`
    -   `mapSpain::esp_get_ccaa_siane()`
    -   `mapSpain::esp_get_hypsobath()`
    -   `mapSpain::esp_get_rivers()`
    -   `mapSpain::esp_get_hydrobasin()`
    -   `mapSpain::esp_get_capimun()`
    -   `mapSpain::esp_get_roads()`
    -   `mapSpain::esp_get_railway()`

-   Mute warnings from `rgdal`

# mapSpain 0.1.2

-   Fix annoying warning if `sf` was not loaded first.
-   Include new `poly` option on `mapSpain::esp_get_can_box()`.
-   New grids created with `geogrid::calculate_grid()`
-   Add more years on `mapSpain::esp_get_munic()`
-   Move to rOpenSpain organization.

# mapSpain 0.1.1

-   Fix CRAN submission.
-   Added `mapSpain::esp_get_grid_prov()` and `mapSpain::esp_get_grid_ccaa()`.

# mapSpain 0.1.0

-   Initial release.
