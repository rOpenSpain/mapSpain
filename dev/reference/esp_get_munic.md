# Get municipalities of Spain as [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON`

Returns municipalities of Spain `sf` POLYGON\` at a specified scale.

- `esp_get_munic()` uses GISCO (Eurostat) as source. Please use
  [`giscoR::gisco_attributions()`](https://ropengov.github.io/giscoR/reference/gisco_attributions.html).

&nbsp;

- `esp_get_munic_siane()` uses CartoBase ANE as source, provided by
  Instituto Geografico Nacional (IGN),
  <http://www.ign.es/web/ign/portal>. Years available are 2005 up to
  today.

## Usage

``` r
esp_get_munic(
  year = "2019",
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  region = NULL,
  munic = NULL,
  moveCAN = TRUE
)

esp_get_munic_siane(
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = 3,
  region = NULL,
  munic = NULL,
  moveCAN = TRUE,
  rawcols = FALSE
)
```

## Source

[GISCO API](https://gisco-services.ec.europa.eu/distribution/v2/)

IGN data via a custom CDN (see
<https://github.com/rOpenSpain/mapSpain/tree/sianedata>).

## Arguments

- year:

  Release year. See **Details** for years available.

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

- region:

  A vector of names and/or codes for provinces or `NULL` to get all the
  municipalities. See **Details**.

- munic:

  A name or [`regex`](https://rdrr.io/r/base/grep.html) expression with
  the names of the required municipalities. `NULL` would return all
  municipalities.

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_move_can.md).

- resolution:

  Resolution of the polygon. Values available are `"3"`, `"6.5"` or
  `"10"`.

- rawcols:

  logical. Setting this to `TRUE` would add the raw columns of the
  resulting object as provided by IGN.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON`.

## Details

The years available are:

- `esp_get_munic()`: `year` could be one of "2001", "2004", "2006",
  "2008", "2010", "2013" and any year between 2016 and 2019. See
  [`giscoR::gisco_get_lau()`](https://ropengov.github.io/giscoR/reference/gisco_get_lau.html),
  [`giscoR::gisco_get_communes()`](https://ropengov.github.io/giscoR/reference/gisco_get_communes.html).

- `esp_get_munic_siane()`: `year` could be passed as a single year
  ("YYYY" format, as end of year) or as a specific date ("YYYY-MM-DD"
  format). Historical information starts as of 2005.

When using `region` you can use and mix names and NUTS codes (levels 1,
2 or 3), ISO codes (corresponding to level 2 or 3) or `"cpro"` (see
[esp_codelist](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md)).

When calling a higher level (Province, Autonomous Community or NUTS1),
all the municipalities of that level would be added.

## See also

[`giscoR::gisco_get_lau()`](https://ropengov.github.io/giscoR/reference/gisco_get_lau.html),
[`base::regex()`](https://rdrr.io/r/base/regex.html).

Other political:
[`esp_codelist`](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md),
[`esp_get_can_box()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_can_box.md),
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_capimun.md),
[`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa.md),
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa_siane.md),
[`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_comarca.md),
[`esp_get_country()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_country.md),
[`esp_get_gridmap`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_gridmap.md),
[`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_nuts.md),
[`esp_get_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_prov.md),
[`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_prov_siane.md),
[`esp_get_simpl_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_simplified.md)

Other municipalities:
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_capimun.md),
[`esp_munic.sf`](https://ropenspain.github.io/mapSpain/dev/reference/esp_munic.sf.md)

## Examples

``` r
# \donttest{
# Get munics
Base <- esp_get_munic(year = "2019", region = "Castilla y Leon")

# Provs for delimiting
provs <- esp_get_prov(prov = "Castilla y Leon")

# Load population data
data("pobmun19")

# Arrange and create breaks

Base_pop <- merge(Base, pobmun19,
  by = c("cpro", "cmun"),
  all.x = TRUE
)

br <- sort(c(
  0, 50, 100, 200, 500,
  1000, 5000, 50000, 100000,
  Inf
))

Base_pop$cuts <- cut(Base_pop$pob19, br, dig.lab = 20)

# Plot
library(ggplot2)


ggplot(Base_pop) +
  geom_sf(aes(fill = cuts), color = NA) +
  geom_sf(data = provs, fill = NA, color = "grey70") +
  scale_fill_manual(values = hcl.colors(length(br), "cividis")) +
  labs(
    title = "Population in Castilla y Leon",
    subtitle = "INE, 2019",
    fill = "Persons"
  ) +
  theme_void()

# }
```
