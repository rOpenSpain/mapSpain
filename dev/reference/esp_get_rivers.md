# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` or `LINESTRING` of rivers, channels and other wetlands of Spain

Loads a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`POLYGON` or `LINESTRING` object representing rivers, channels,
reservoirs and other wetlands of Spain.

## Usage

``` r
esp_get_rivers(
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = "3",
  spatialtype = "line",
  name = NULL
)
```

## Source

IGN data via a custom CDN (see
<https://github.com/rOpenSpain/mapSpain/tree/sianedata>).

## Arguments

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

  Resolution of the `POLYGON`. Values available are `"3"`, `"6.5"` or
  `"10"`.

- spatialtype:

  Spatial type of the output. Use `"area"` for `POLYGON` or `"line"` for
  `LINESTRING`.

- name:

  Optional. A character or [`regex`](https://rdrr.io/r/base/grep.html)
  expression with the name of the element(s) to be extracted.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` or
`LINESTRING` object.

## Details

Metadata available on
<https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.

## See also

Other natural:
[`esp_get_hydrobasin()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_hydrobasin.md),
[`esp_get_hypsobath()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_hypsobath.md)

## Examples

``` r
# \donttest{
# Use of regex

regex1 <- esp_get_rivers(name = "Tajo|Segura")
unique(regex1$rotulo)
#> [1] "Río Tajo"                        "Río Segura"                     
#> [3] "Canal del Transvase Tajo-Segura"


regex2 <- esp_get_rivers(name = "Tajo$| Segura")
unique(regex2$rotulo)
#> [1] "Río Tajo"   "Río Segura"

# See the diference

# Rivers in Spain
shapeEsp <- esp_get_country(moveCAN = FALSE)

MainRivers <-
  esp_get_rivers(name = "Tajo$|Ebro$|Ebre$|Duero|Guadiana$|Guadalquivir")

sf::st_bbox(MainRivers)
#>      xmin      ymin      xmax      ymax 
#> -7.545006 36.798737  0.863511 43.014104 
library(ggplot2)

ggplot(shapeEsp) +
  geom_sf() +
  geom_sf(data = MainRivers, color = "skyblue", linewidth = 2) +
  coord_sf(
    xlim = c(-7.5, 1),
    ylim = c(36.8, 43)
  ) +
  theme_void()



# Wetlands in South-West Andalucia
and <- esp_get_prov(c("Huelva", "Sevilla", "Cadiz"))
Wetlands <- esp_get_rivers(spatialtype = "area")

ggplot(and) +
  geom_sf() +
  geom_sf(
    data = Wetlands, fill = "skyblue",
    color = "skyblue", alpha = 0.5
  ) +
  coord_sf(
    xlim = c(-7.5, -4.5),
    ylim = c(36, 38.5)
  ) +
  theme_void()

# }
```
