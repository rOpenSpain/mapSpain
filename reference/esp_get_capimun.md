# City where the municipal public authorities are based from SIANE

Get a [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POINT`
with the location of the political powers for each municipality.

Note that this differs from the centroid of the boundaries of the
municipality, returned by
[`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md).

## Usage

``` r
esp_get_capimun(
  year = Sys.Date(),
  epsg = 4258,
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  region = NULL,
  munic = NULL,
  moveCAN = TRUE,
  rawcols = FALSE
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

  Logical. Whether to cache downloaded files. Defaults to `TRUE`. See
  **Caching**.

- update_cache:

  Logical. If `TRUE`, refreshes the cached file and forces a new
  download. Defaults to `FALSE`.

- cache_dir:

  Character string. A path to a cache directory. See **Caching**.

- verbose:

  A logical value. If `TRUE` displays informational messages.

- region:

  Optional. A vector of region names, NUTS or ISO codes (see
  [`esp_dict_region_code()`](https://ropenspain.github.io/mapSpain/reference/esp_dict.md)).

- munic:

  Character string. A name or
  [`regex`](https://rdrr.io/r/base/grep.html) expression with the names
  of the required municipalities. Use `NULL` to return all
  municipalities.

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/reference/esp_move_can.md).

- rawcols:

  Logical. If `TRUE`, adds the raw columns of the resulting object as
  provided by IGN.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Details

When using `region` you can use and mix names and NUTS codes (levels 1,
2 or 3), ISO codes (corresponding to level 2 or 3) or `"cpro"` (see
[esp_codelist](https://ropenspain.github.io/mapSpain/reference/esp_codelist.md)).

When calling a higher level (province, Autonomous Community or City, or
NUTS 1), all municipalities of that level are added.

## Caching

Functions that download data store files in `cache_dir`. When
`cache_dir` is `NULL`, they use the active package cache, which defaults
to a temporary directory. Set `update_cache = TRUE` to replace an
existing cached file. See **Caching strategies** in
[`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
to configure a persistent cache.

## See also

Datasets sourced from CartoBase ANE (Atlas Nacional de España):
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa_siane.md),
[`esp_get_countries_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_countries_siane.md),
[`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md),
[`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov_siane.md),
[`esp_get_spain_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain_siane.md),
[`esp_siane_bulk_download()`](https://ropenspain.github.io/mapSpain/reference/esp_siane_bulk_download.md)

Municipality-level datasets:
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic.md),
[`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md)

## Examples

``` r
# \donttest{
# Compare municipality centroids against esp_get_capimun().

# Get the municipality boundary.
area <- esp_get_munic_siane(munic = "Valladolid", epsg = 3857)

# Area in km2.
print(paste0(round(as.double(sf::st_area(area)) / 1000000, 2), " km2"))
#> [1] "353.42 km2"

# Extract the centroid.
centroid <- sf::st_centroid(area)
#> Warning: st_centroid assumes attributes are constant over geometries
centroid$type <- "Centroid"

# Compare with capimun.
capimun <- esp_get_capimun(munic = "Valladolid", epsg = 3857)
capimun$type <- "Capimun"

# Join both point geometries.
points <- dplyr::bind_rows(centroid, capimun)

# Check on a plot.
library(ggplot2)

ggplot(points) +
  geom_sf(data = area, fill = NA, color = "blue") +
  geom_sf(data = points, aes(fill = type), size = 5, shape = 21) +
  scale_fill_manual(values = c("green", "red")) +
  labs(title = "Centroid vs. capimun")

# }
```
