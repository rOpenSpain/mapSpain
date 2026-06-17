# Railways of Spain from SIANE

Loads a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`LINESTRING` or `POINT` object representing the nodes and railway lines
of Spain.

## Usage

``` r
esp_get_railway(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  spatialtype = c("line", "point")
)

esp_get_stations(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
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

  Logical. Whether to cache downloaded files. Default is `TRUE`. See
  **Caching strategies** section in
  [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md).

- update_cache:

  Logical. If `TRUE`, refreshes the cached file and forces a new
  download. Defaults to `FALSE`.

- cache_dir:

  Character string. A path to a cache directory. See **Caching
  strategies** section in
  [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md).

- verbose:

  A logical value. If `TRUE` displays informational messages.

- spatialtype:

  **\[deprecated\]** character string. Use `esp_get_stations()` instead
  of `"point"` for stations.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## See also

Transport infrastructure datasets:
[`esp_get_roads()`](https://ropenspain.github.io/mapSpain/reference/esp_get_roads.md)

## Examples

``` r
# \donttest{
provs <- esp_get_prov()
ccaa <- esp_get_ccaa()

# Railways.
rails <- esp_get_railway()

# Stations.
stations <- esp_get_stations()

# Map.

library(ggplot2)

ggplot(provs) +
  geom_sf(fill = "grey99", color = "grey50") +
  geom_sf(data = ccaa, fill = NA) +
  geom_sf(
    data = rails, aes(color = t_ffcc_desc),
    show.legend = FALSE,
    linewidth = 1.5
  ) +
  geom_sf(
    data = stations,
    color = "red", alpha = 0.5
  ) +
  scale_colour_viridis_d() +
  facet_wrap(~t_ffcc_desc) +
  theme_minimal()

# }
```
