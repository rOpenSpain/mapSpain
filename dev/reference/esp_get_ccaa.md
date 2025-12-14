# Get Autonomous Communities of Spain as [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` or `POINT`

Returns [Autonomous Communities of
Spain](https://en.wikipedia.org/wiki/Autonomous_communities_of_Spain) as
`sf` `POLYGON` or `POINT` at a specified scale.

- `esp_get_ccaa()` uses GISCO (Eurostat) as source. Please use
  [`giscoR::gisco_attributions()`](https://ropengov.github.io/giscoR/reference/gisco_attributions.html)

&nbsp;

- `esp_get_ccaa_siane()` uses CartoBase ANE as source, provided by
  Instituto Geografico Nacional (IGN),
  <http://www.ign.es/web/ign/portal>. Years available are 2005 up to
  today.

## Usage

``` r
esp_get_ccaa(ccaa = NULL, moveCAN = TRUE, ...)

esp_get_ccaa_siane(
  ccaa = NULL,
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = "3",
  moveCAN = TRUE,
  rawcols = FALSE
)
```

## Source

IGN data via a custom CDN (see
<https://github.com/rOpenSpain/mapSpain/tree/sianedata>).

## Arguments

- ccaa:

  A vector of names and/or codes for autonomous communities or `NULL` to
  get all the autonomous communities. See **Details**.

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_move_can.md).

- ...:

  Arguments passed on to
  [`esp_get_nuts`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_nuts.md)

  `spatialtype`

  :   character string. Type of geometry to be returned. Options
      available are:

      - "RG": Regions - `MULTIPOLYGON/POLYGON` object.

      - "LB": Labels - `POINT` object.

  `ext`

  :   character. Extension of the file (default `"gpkg"`). See
      [`giscoR::gisco_get_nuts()`](https://ropengov.github.io/giscoR/reference/gisco_get_nuts.html).

- year:

  Release year. See
  [`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_nuts.md)
  for `esp_get_ccaa()` and **Details** for `esp_get_ccaa_siane()`.

- epsg:

  character string or number. Projection of the map: 4-digit [EPSG
  code](https://epsg.io/). One of:

  - `"4258"`: [ETRS89](https://epsg.io/4258)

  - `"4326"`: [WGS84](https://epsg.io/4326).

  - `"3035"`: [ETRS89 / ETRS-LAEA](https://epsg.io/3035).

  - `"3857"`: [Pseudo-Mercator](https://epsg.io/3857).

- cache:

  logical. Whether to do caching. Default is `TRUE`. See **Caching
  strategies** section in
  [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_set_cache_dir.md).

- update_cache:

  logical. Should the cached file be refreshed?. Default is `FALSE`.
  When set to `TRUE` it would force a new download.

- cache_dir:

  character string. A path to a cache directory. See **Caching
  strategies** section in
  [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_set_cache_dir.md).

- verbose:

  logical. If `TRUE` displays informational messages.

- resolution:

  Resolution of the `POLYGON`. Values available are `3`, `6.5` or `10`.

- rawcols:

  Logical. Setting this to `TRUE` would add the raw columns of the
  resulting object as provided by IGN.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object
specified by `spatialtype`.

## Details

When using `ccaa` you can use and mix names and NUTS codes (levels 1 or
2), ISO codes (corresponding to level 2) or `codauto` (see
[esp_codelist](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md)).
Ceuta and Melilla are considered as Autonomous Communities on this
function.

When calling a NUTS1 level, all the Autonomous Communities of that level
would be added.

On `esp_get_ccaa_siane()`, `year` could be passed as a single year
(`YYYY` format, as end of year) or as a specific date (`YYYY-MM-DD`
format). Historical information starts as of 2005.

## See also

Other political:
[`esp_codelist`](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md),
[`esp_get_can_box()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_can_box.md),
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_capimun.md),
[`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_comarca.md),
[`esp_get_country()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_country.md),
[`esp_get_gridmap`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_gridmap.md),
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_munic.md),
[`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_nuts.md),
[`esp_get_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_prov.md),
[`esp_get_simpl_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_simplified.md)

## Examples

``` r
ccaa <- esp_get_ccaa()

library(ggplot2)

ggplot(ccaa) +
  geom_sf()


# Random CCAA
Random <- esp_get_ccaa(ccaa = c(
  "Euskadi",
  "Catalunya",
  "ES-EX",
  "Canarias",
  "ES52",
  "01"
))


ggplot(Random) +
  geom_sf(aes(fill = codauto), show.legend = FALSE) +
  geom_sf_label(aes(label = codauto), alpha = 0.3)
#> Warning: st_point_on_surface may not give correct results for longitude/latitude data


# All CCAA of a Zone plus an addition

Mix <-
  esp_get_ccaa(ccaa = c("La Rioja", "Noroeste"))

ggplot(Mix) +
  geom_sf()


# Combine with giscoR to get countries
# \donttest{

library(giscoR)
library(sf)

res <- 20 # Set same resoluion

europe <- gisco_get_countries(resolution = res)
ccaa <- esp_get_ccaa(moveCAN = FALSE, resolution = res)

# Transform to same CRS
europe <- st_transform(europe, 3035)
ccaa <- st_transform(ccaa, 3035)

ggplot(europe) +
  geom_sf(fill = "#DFDFDF", color = "#656565") +
  geom_sf(data = ccaa, fill = "#FDFBEA", color = "#656565") +
  coord_sf(
    xlim = c(23, 74) * 10e4,
    ylim = c(14, 55) * 10e4
  ) +
  theme(panel.background = element_rect(fill = "#C7E7FB"))

# }
```
