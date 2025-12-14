# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` of the drainage basin demarcations of Spain

Loads a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`POLYGON` object containing areas with the required hydrographic
elements of Spain.

## Usage

``` r
esp_get_hydrobasin(
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = "3",
  domain = "land"
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

- domain:

  Possible values are `"land"`, that includes only the ground part or
  the ground or `"landsea"`, that includes both the ground and the
  related sea waters of the basin.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON`
object.

## Details

Metadata available on
<https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.

## See also

Other natural:
[`esp_get_hypsobath()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_hypsobath.md),
[`esp_get_rivers()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_rivers.md)

## Examples

``` r
# \donttest{
hydroland <- esp_get_hydrobasin(domain = "land")
hydrolandsea <- esp_get_hydrobasin(domain = "landsea")

library(ggplot2)


ggplot(hydroland) +
  geom_sf(data = hydrolandsea, fill = "skyblue4", alpha = .4) +
  geom_sf(fill = "skyblue", alpha = .5) +
  geom_sf_text(aes(label = rotulo),
    size = 3, check_overlap = TRUE,
    fontface = "bold",
    family = "serif"
  ) +
  coord_sf(
    xlim = c(-9.5, 4.5),
    ylim = c(35, 44)
  ) +
  theme_void()
#> Warning: st_point_on_surface may not give correct results for longitude/latitude data

# }
```
