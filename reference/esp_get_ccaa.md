# Autonomous Communities and Cities of Spain from GISCO

Get [Autonomous Communities and Cities of
Spain](https://en.wikipedia.org/wiki/Autonomous_communities_of_Spain) at
a specified scale.

## Usage

``` r
esp_get_ccaa(ccaa = NULL, moveCAN = TRUE, ...)
```

## Source

<https://gisco-services.ec.europa.eu/distribution/v2/>.

Copyright:
<https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units>.

## Arguments

- ccaa:

  Character string. A vector of names, codes or both for Autonomous
  Communities and Cities, or `NULL` to get all Autonomous Communities
  and Cities. See **Details**.

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/reference/esp_move_can.md).

- ...:

  Arguments passed on to
  [`esp_get_nuts`](https://ropenspain.github.io/mapSpain/reference/esp_get_nuts.md)

  `year`

  :   Year character string or number. Release year of the file. See
      [`giscoR::gisco_get_nuts()`](https://ropengov.github.io/giscoR/reference/gisco_get_nuts.html)
      for valid values.

  `epsg`

  :   Character string or number. Projection of the map: 4-digit [EPSG
      code](https://epsg.io/). One of:

      - `"4258"`: [ETRS89](https://epsg.io/4258).

      - `"4326"`: [WGS84](https://epsg.io/4326).

      - `"3035"`: [ETRS89 / ETRS-LAEA](https://epsg.io/3035).

      - `"3857"`: [Pseudo-Mercator](https://epsg.io/3857).

  `cache`

  :   Logical. Whether to cache downloaded files. Defaults to `TRUE`.
      See **Caching**.

  `update_cache`

  :   Logical. If `TRUE`, refreshes the cached file and forces a new
      download. Defaults to `FALSE`.

  `cache_dir`

  :   Character string. A path to a cache directory. See **Caching**.

  `spatialtype`

  :   Character string. Type of geometry to be returned. Options
      available are:

      - `"RG"`: regions, returned as a `MULTIPOLYGON/POLYGON` object.

      - `"LB"`: labels, returned as a `POINT` object.

  `ext`

  :   Character. Extension of the file (default `"gpkg"`). See
      [`giscoR::gisco_get_nuts()`](https://ropengov.github.io/giscoR/reference/gisco_get_nuts.html).

  `verbose`

  :   A logical value. If `TRUE` displays informational messages.

  `resolution`

  :   A character string or numeric value with the geospatial data
      resolution. One of:

      - `"60"`: 1:60 million.

      - `"20"`: 1:20 million.

      - `"10"`: 1:10 million.

      - `"03"`: 1:3 million.

      - `"01"`: 1:1 million.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Details

When using `ccaa` you can use and mix names and NUTS codes (levels 1 or
2), ISO codes (corresponding to level 2) or `codauto` (see
[esp_codelist](https://ropenspain.github.io/mapSpain/reference/esp_codelist.md)).
Ceuta and Melilla are included at the Autonomous Communities and Cities
level in this function.

When calling a NUTS 1 level, all Autonomous Communities and Cities of
that level are added.

## Caching

Functions that download data store files in `cache_dir`. When
`cache_dir` is `NULL`, they use the active package cache, which defaults
to a temporary directory. Set `update_cache = TRUE` to replace an
existing cached file. See **Caching strategies** in
[`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
to configure a persistent cache.

## See also

Datasets sourced from GISCO:
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic.md),
[`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/reference/esp_get_nuts.md),
[`esp_get_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov.md),
[`esp_get_spain()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain.md)

## Examples

``` r
ccaa <- esp_get_ccaa()

library(ggplot2)

ggplot(ccaa) +
  geom_sf()


# Random Autonomous Communities and Cities.
random_ccaa <- esp_get_ccaa(ccaa = c(
  "Euskadi",
  "Catalunya",
  "ES-EX",
  "Canarias",
  "ES52",
  "01"
))

ggplot(random_ccaa) +
  geom_sf(aes(fill = codauto), show.legend = FALSE) +
  geom_sf_label(aes(label = codauto), alpha = 0.3) +
  coord_sf(crs = 3857)


# All Autonomous Communities and Cities of a NUTS 1 region plus one.

mixed <- esp_get_ccaa(ccaa = c("La Rioja", "Noroeste"))

ggplot(mixed) +
  geom_sf()


# Combine with giscoR to get countries.
# \donttest{

library(giscoR)
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE

res <- 20 # Use the same resolution.

europe <- gisco_get_countries(resolution = res)
ccaa <- esp_get_ccaa(moveCAN = FALSE, resolution = res)

ggplot(europe) +
  geom_sf(fill = "#DFDFDF", color = "#656565") +
  geom_sf(data = ccaa, fill = "#FDFBEA", color = "#656565") +
  coord_sf(
    xlim = c(23, 74) * 10e4,
    ylim = c(14, 55) * 10e4,
    crs = 3035
  ) +
  theme(panel.background = element_rect(fill = "#C7E7FB"))

# }
```
