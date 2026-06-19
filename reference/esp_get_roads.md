# Roads of Spain from SIANE

Object representing the main roads of Spain.

## Usage

``` r
esp_get_roads(
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  moveCAN = TRUE
)
```

## Source

CartoBase ANE (Atlas Nacional de España) provided by Instituto
Geográfico Nacional (IGN), <http://www.ign.es/web/ign/portal>. Years
available are 2005 up to today.

Copyright:
<https://centrodedescargas.cnig.es/CentroDescargas/cartobase-ane>

Always acknowledge authorship using the following statements:

1.  When the original digital product is not modified or altered, use
    one of the following statements:

    - CartoBase ANE 2006-2024 CC-BY 4.0 ign.es.

    - CartoBase ANE 2006-2024 CC-BY 4.0 Instituto Geográfico Nacional.

2.  When a new product is generated:

    - Obra derivada de CartoBase ANE 2006-2024 CC-BY 4.0 ign.es.

Data distributed through the `sianedata` data branch, see
<https://github.com/rOpenSpain/mapSpain/tree/sianedata>.

## Arguments

- year:

  Ignored.

- epsg:

  Character string or number. Projection of the map: 4-digit [EPSG
  code](https://epsg.io/). One of:

  - `"4258"`: [ETRS89](https://epsg.io/4258).

  - `"4326"`: [WGS84](https://epsg.io/4326).

  - `"3035"`: [ETRS89 / ETRS-LAEA](https://epsg.io/3035).

  - `"3857"`: [Pseudo-Mercator](https://epsg.io/3857).

- cache:

  Logical. Whether to cache downloaded files. Defaults to `TRUE`. See
  **Caching**.

- update_cache:

  Logical. If `TRUE`, refreshes the cached file and forces a new
  download. Defaults to `FALSE`.

- cache_dir:

  Character string. A path to a cache directory. See **Caching**.

- verbose:

  A logical value. If `TRUE` displays informational messages.

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/reference/esp_move_can.md).

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Caching

Functions that download data store files in `cache_dir`. When
`cache_dir` is `NULL`, they use the active package cache, which defaults
to a temporary directory. Set `update_cache = TRUE` to replace an
existing cached file. See **Caching strategies** in
[`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
to configure a persistent cache.

## See also

Transport infrastructure datasets:
[`esp_get_railway()`](https://ropenspain.github.io/mapSpain/reference/esp_get_railway.md)

## Examples

``` r
# \donttest{

country <- esp_get_spain()
roads <- esp_get_roads()

library(ggplot2)

ggplot(country) +
  geom_sf(fill = "grey90") +
  geom_sf(data = roads, aes(color = t_ctra_desc), show.legend = "line") +
  scale_color_manual(
    values = c("#003399", "#003399", "#ff0000", "#ffff00")
  ) +
  guides(color = guide_legend(direction = "vertical")) +
  theme_minimal() +
  labs(color = "Road type") +
  theme(legend.position = "bottom")

# }
```
