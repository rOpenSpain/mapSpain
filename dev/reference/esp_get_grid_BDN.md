# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` with the national geographic grids from BDN

Loads a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`POLYGON` with the geographic grids of Spain as provided on the Banco de
Datos de la Naturaleza (Nature Data Bank), by the Ministry of
Environment (MITECO):

- `esp_get_grid_BDN()` extracts country-wide grids with resolutions 5x5
  or 10x10 kms.

- `esp_get_grid_BDN_ccaa()` extracts grids by Autonomous Community with
  resolution 1x1 km.

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

BDN data via a custom CDN (see
<https://github.com/rOpenSpain/mapSpain/tree/sianedata/MTN>).

See original metadata and source on
<https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/bdn-cart-aux-descargas-ccaa.html>

## Arguments

- resolution:

  Resolution of the grid in kms. Could be `5` or `10`.

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

- ccaa:

  A vector of names and/or codes for autonomous communities. See
  **Details** on
  [`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa.md).

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON`.

## See also

[`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa.md)

Other grids:
[`esp_get_grid_ESDAC()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_grid_ESDAC.md),
[`esp_get_grid_MTN()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_grid_MTN.md)

## Examples

``` r
# \donttest{
grid <- esp_get_grid_BDN(resolution = "10", type = "main")

library(ggplot2)

ggplot(grid) +
  geom_sf() +
  theme_light() +
  labs(title = "BDN Grid for Spain")

# }
```
