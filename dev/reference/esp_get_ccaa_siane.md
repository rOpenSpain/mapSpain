# Autonomous Communities of Spain - SIANE

Returns [Autonomous Communities of
Spain](https://en.wikipedia.org/wiki/Autonomous_communities_of_Spain) at
a specified scale.

## Usage

``` r
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

CartoBase ANE provided by Instituto Geografico Nacional (IGN),
<http://www.ign.es/web/ign/portal>. Years available are 2005 up to
today.

## Arguments

- ccaa:

  A vector of names and/or codes for autonomous communities or `NULL` to
  get all the autonomous communities. See **Details**.

- year:

  character string or number. Release year. See **Details**.

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

  character string or number. Resolution of the geospatial data. One of:

  - "10": 1:10 million.

  - "6.5": 1:6.5 million.

  - "6.5": 1:3 million.

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_move_can.md).

- rawcols:

  logical. Setting this to `TRUE` would add the raw columns of the
  resulting object as provided by IGN.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Details

`year` could be passed as a single year (`YYYY` format, as end of year)
or as a specific date (`YYYY-MM-DD` format). Historical information
starts as of 2005.

## See also

Other political:
[`esp_codelist`](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md),
[`esp_get_can_box()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_can_box.md),
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_capimun.md),
[`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa.md),
[`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_comarca.md),
[`esp_get_country()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_country.md),
[`esp_get_gridmap`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_gridmap.md),
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_munic.md),
[`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_nuts.md),
[`esp_get_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_prov.md),
[`esp_get_simpl_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_simplified.md)

Other siane:
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_capimun.md)
