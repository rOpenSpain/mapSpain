# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POINT` of the municipalities of Spain

Get a [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POINT`
with the location of the political powers for each municipality
(possibly the center of the municipality).

Note that this differs of the centroid of the boundaries of the
municipality, returned by
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_munic.md).

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

CartoBase ANE provided by Instituto Geografico Nacional (IGN),
<http://www.ign.es/web/ign/portal>. Years available are 2005 up to
today.

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

- rawcols:

  logical. Setting this to `TRUE` would add the raw columns of the
  resulting object as provided by IGN.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POINT`
object.

## Details

`year` could be passed as a single year (`YYYY` format, as end of year)
or as a specific date (`YYYY-MM-DD` format). Historical information
starts as of 2005.

When using `region` you can use and mix names and NUTS codes (levels 1,
2 or 3), ISO codes (corresponding to level 2 or 3) or `cpro`. See
[esp_codelist](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md)

When calling a higher level (province, CCAA or NUTS1), all the
municipalities of that level would be added.

## See also

Other political:
[`esp_codelist`](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md),
[`esp_get_can_box()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_can_box.md),
[`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa.md),
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa_siane.md),
[`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_comarca.md),
[`esp_get_country()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_country.md),
[`esp_get_gridmap`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_gridmap.md),
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_munic.md),
[`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_nuts.md),
[`esp_get_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_prov.md),
[`esp_get_simpl_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_simplified.md)

Other siane:
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa_siane.md)

Other municipalities:
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_munic.md),
[`esp_munic.sf`](https://ropenspain.github.io/mapSpain/dev/reference/esp_munic.sf.md)

## Examples

``` r
# \dontrun{
# This code compares centroids of municipalities against esp_get_capimun
# It also download tiles, make sure you are online

library(sf)
#> Linking to GEOS 3.13.1, GDAL 3.11.4, PROJ 9.7.0; sf_use_s2() is TRUE

# Get shape
area <- esp_get_munic_siane(munic = "Valladolid", epsg = 3857)

# Area in km2
print(paste0(round(as.double(sf::st_area(area)) / 1000000, 2), " km2"))
#> [1] "353.42 km2"

# Extract centroid
centroid <- sf::st_centroid(area)
#> Warning: st_centroid assumes attributes are constant over geometries
centroid$type <- "Centroid"

# Compare with capimun
capimun <- esp_get_capimun(munic = "Valladolid", epsg = 3857)
capimun$type <- "Capimun"

# Get a tile to check
tile <- esp_get_tiles(area, "IGNBase.Todo", zoommin = 2)

# Join both point geometries
points <- rbind(
  centroid[, "type"],
  capimun[, "type"]
)
#> Error in match.names(clabs, names(xi)): names do not match previous names


# Check on plot
library(ggplot2)
library(tidyterra)
#> 
#> Attaching package: 'tidyterra'
#> The following object is masked from 'package:stats':
#> 
#>     filter

ggplot(points) +
  geom_spatraster_rgb(data = tile, maxcell = Inf) +
  geom_sf(data = area, fill = NA, color = "blue") +
  geom_sf(data = points, aes(fill = type), size = 5, shape = 21) +
  scale_fill_manual(values = c("green", "red")) +
  theme_void() +
  labs(title = "Centroid vs. capimun")
#> Error in ggplot(points): `data` cannot be a function.
#> ℹ Have you misspelled the `data` argument in `ggplot()`?
# }
```
