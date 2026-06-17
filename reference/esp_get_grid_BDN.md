# National geographic grids from BDN (Nature Data Bank)

Load an [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`POLYGON` object with the geographic grids of Spain as provided by the
Banco de Datos de la Naturaleza (Nature Data Bank), under the Ministry
of Environment (MITECO).

This dataset provides two accessors. `esp_get_grid_BDN()` extracts
country-wide regular grids with resolutions of 5 x 5 or 10 x 10
kilometers for mainland Spain or the Canary Islands.
`esp_get_grid_BDN_ccaa()` extracts 1 x 1 kilometer resolution grids for
individual Autonomous Communities and Cities.

These grids are useful for biodiversity analysis, environmental
monitoring, and spatial statistical applications.

`esp_get_grid_BDN_ccaa()` provides higher-resolution 1 x 1 kilometer
grids for specific Autonomous Communities and Cities, useful for
regional analysis with finer spatial detail.

## Usage

``` r
esp_get_grid_BDN(
  resolution = c(10, 5),
  type = c("main", "canary"),
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
)

esp_get_grid_BDN_ccaa(
  ccaa,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
)
```

## Source

Data sourced from the Banco de Datos de la Naturaleza (BDN). See the
repository structure:
<https://github.com/rOpenSpain/mapSpain/tree/sianedata/MITECO/dist>

For more information about BDN grids and other resources, visit:
<https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/bdn-cart-aux-descargas-ccaa.html>.

## Arguments

- resolution:

  Numeric. Resolution of the grid in kilometers. Must be one of:

  - `5`: 5 x 5 kilometer cells.

  - `10`: 10 x 10 kilometer cells (default).

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

- ccaa:

  Character string. A vector of names, codes or both for Autonomous
  Communities and Cities. See **Details** on
  [`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa.md)
  for accepted formats.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Details

The BDN provides standardized geographic grids for Spain that follow the
Nature Data Bank's specifications. The data are downloaded from the
`sianedata/MITECO/dist` data branch and is regularly updated.

## See also

[`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa.md)

Geographical grid datasets:
[`esp_get_grid_ESDAC()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_ESDAC.md),
[`esp_get_grid_MTN()`](https://ropenspain.github.io/mapSpain/reference/esp_get_grid_MTN.md)

## Examples

``` r
# \donttest{
# Load a 10 x 10 km grid for mainland Spain.
grid <- esp_get_grid_BDN(resolution = 10, type = "main")

# Visualize the grid.
library(ggplot2)

ggplot(grid) +
  geom_sf(fill = NA, color = "steelblue") +
  theme_light() +
  labs(title = "BDN Geographic Grid: 10x10 km Spain")

# }
```
