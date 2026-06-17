# Countries of the world from SIANE

This dataset contains the administrative boundaries at country level of
the world.

The data included in this cartographic database do not imply any opinion
of the IGN regarding its legal status.

## Usage

``` r
esp_get_countries_siane(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  country = NULL
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

  Character string or number. Release year. It must use format `YYYY`
  (assuming end of year) or `YYYY-MM-DD`. Historical information starts
  as of 2005.

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

- country:

  Character vector of country codes. It can be a vector of country
  names, ISO3 country codes or ISO2 country codes. See also
  [`countrycode::countrycode()`](https://vincentarelbundock.github.io/countrycode/man/countrycode.html).

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## See also

[`giscoR::gisco_get_countries()`](https://ropengov.github.io/giscoR/reference/gisco_get_countries.html).

Political and administrative boundary datasets:
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/reference/esp_get_capimun.md),
[`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa.md),
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa_siane.md),
[`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/reference/esp_get_comarca.md),
[`esp_get_gridmap`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md),
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic.md),
[`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md),
[`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/reference/esp_get_nuts.md),
[`esp_get_prov()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov.md),
[`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov_siane.md),
[`esp_get_simpl`](https://ropenspain.github.io/mapSpain/reference/esp_get_simpl.md),
[`esp_get_spain()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain.md),
[`esp_get_spain_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain_siane.md),
[`esp_siane_bulk_download()`](https://ropenspain.github.io/mapSpain/reference/esp_siane_bulk_download.md)

Datasets sourced from CartoBase ANE (Atlas Nacional de España):
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/reference/esp_get_capimun.md),
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa_siane.md),
[`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md),
[`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov_siane.md),
[`esp_get_spain_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain_siane.md),
[`esp_siane_bulk_download()`](https://ropenspain.github.io/mapSpain/reference/esp_siane_bulk_download.md)

## Examples

``` r
cntries <- esp_get_countries_siane()

library(ggplot2)
ggplot(cntries) +
  geom_sf()
```
