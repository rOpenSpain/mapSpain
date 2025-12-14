# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `LINESTRING` of the roads of Spain

Loads a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`LINESTRING` object representing the main roads of Spain.

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

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_move_can.md).

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `LINESTRING`
object.

## Details

`year` could be passed as a single year ("YYYY" format, as end of year)
or as a specific date ("YYYY-MM-DD" format).

## See also

Other infrastructure:
[`esp_get_railway()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_railway.md)

## Examples

``` r
# \donttest{

country <- esp_get_country()
Roads <- esp_get_roads()

library(ggplot2)

ggplot(country) +
  geom_sf(fill = "grey90") +
  geom_sf(data = Roads, aes(color = tipo), show.legend = "line") +
  scale_color_manual(
    values = c("#003399", "#003399", "#ff0000", "#ffff00")
  ) +
  guides(color = guide_legend(direction = "vertical")) +
  theme_minimal() +
  labs(color = "Road type") +
  theme(legend.position = "bottom")

# }
```
