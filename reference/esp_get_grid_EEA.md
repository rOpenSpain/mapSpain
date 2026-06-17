# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` of the national geographic grids from EEA

**\[defunct\]**

This function is defunct because the source file is no longer available.

## Usage

``` r
esp_get_grid_EEA(
  resolution = 100,
  type = "main",
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
)
```

## Source

[EEA reference
grid](https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b).

## Arguments

- resolution:

  Resolution of the grid in kilometers. Can be `1`, `10` or `100`.

- type:

  Character. The geographic scope of the grid:

  - `"main"`: Mainland Spain (default).

  - `"canary"`: Canary Islands.

- update_cache:

  Logical. If `TRUE`, refreshes the cached file and forces a new
  download. Defaults to `FALSE`.

- cache_dir:

  Character string. A path to a cache directory. See **Caching
  strategies** section in
  [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md).

- verbose:

  A logical value. If `TRUE` displays informational messages.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON`.
