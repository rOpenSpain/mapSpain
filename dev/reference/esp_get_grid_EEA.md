# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` of the national geographic grids from EEA

**\[defunct\]**

This function is defunct as the source file is not available any more.

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

  Resolution of the grid in kms. Could be `1`, `10` or `100`.

- type:

  The scope of the grid. It could be mainland Spain (`"main"`) or the
  Canary Islands (`"canary"`).

- update_cache:

  logical. Should the cached file be refreshed?. Default is `FALSE`.
  When set to `TRUE` it would force a new download.

- cache_dir:

  character string. A path to a cache directory. See **Caching
  strategies** section in
  [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_set_cache_dir.md).

- verbose:

  logical. If `TRUE` displays informational messages.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON`.

## Examples

``` r
# \dontrun{

grid <- esp_get_grid_EEA(type = "main", resolution = 100)
#> Error: `esp_get_grid_EEA()` was deprecated in mapSpain 1.0.0 and is now
#> defunct.
#> ℹ The source file is not available for download any more
grid_can <- esp_get_grid_EEA(type = "canary", resolution = 100)
#> Error: `esp_get_grid_EEA()` was deprecated in mapSpain 1.0.0 and is now
#> defunct.
#> ℹ The source file is not available for download any more
esp <- esp_get_country(moveCAN = FALSE)

library(ggplot2)

ggplot(grid) +
  geom_sf() +
  geom_sf(data = grid_can) +
  geom_sf(data = esp, fill = NA) +
  theme_light() +
  labs(title = "EEA Grid for Spain")
#> Error in ggplot(grid): `data` cannot be a function.
#> ℹ Have you misspelled the `data` argument in `ggplot()`?
# }
```
