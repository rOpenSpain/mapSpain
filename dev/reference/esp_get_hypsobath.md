# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` or `LINESTRING` with hypsometry and bathymetry of Spain

Loads a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`POLYGON` or `LINESTRING` object representing the hypsometry and
bathymetry of Spain.

- **Hypsometry** represents the the elevation and depth of features of
  the Earth's surface relative to mean sea level.

- **Bathymetry** is the measurement of the depth of water in oceans,
  rivers, or lakes.

## Usage

``` r
esp_get_hypsobath(
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = "3",
  spatialtype = "area"
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

  Resolution of the shape. Values available are `"3"` or `"6.5"`.

- spatialtype:

  Spatial type of the output. Use `"area"` for `POLYGON` or `"line"` for
  `LINESTRING`.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `POLYGON` or
`LINESTRING` object.

## Details

Metadata available on
<https://github.com/rOpenSpain/mapSpain/tree/sianedata/>.

## See also

Other natural:
[`esp_get_hydrobasin()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_hydrobasin.md),
[`esp_get_rivers()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_rivers.md)

## Examples

``` r
# \donttest{
# This code would produce a nice plot - It will take a few seconds to run
library(ggplot2)

hypsobath <- esp_get_hypsobath()

# Error on the data provided - There is an empty shape
# Remove:

hypsobath <- hypsobath[!sf::st_is_empty(hypsobath), ]

# Tints from Wikipedia
# https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Maps/Conventions/
# Topographic_maps

bath_tints <- colorRampPalette(
  rev(
    c(
      "#D8F2FE", "#C6ECFF", "#B9E3FF",
      "#ACDBFB", "#A1D2F7", "#96C9F0",
      "#8DC1EA", "#84B9E3", "#79B2DE",
      "#71ABD8"
    )
  )
)

hyps_tints <- colorRampPalette(
  rev(
    c(
      "#F5F4F2", "#E0DED8", "#CAC3B8", "#BAAE9A",
      "#AC9A7C", "#AA8753", "#B9985A", "#C3A76B",
      "#CAB982", "#D3CA9D", "#DED6A3", "#E8E1B6",
      "#EFEBC0", "#E1E4B5", "#D1D7AB", "#BDCC96",
      "#A8C68F", "#94BF8B", "#ACD0A5"
    )
  )
)

levels <- sort(unique(hypsobath$val_inf))

# Create palette
br_bath <- length(levels[levels < 0])
br_terrain <- length(levels) - br_bath

pal <- c(bath_tints((br_bath)), hyps_tints((br_terrain)))


# Plot Canary Islands
ggplot(hypsobath) +
  geom_sf(aes(fill = as.factor(val_inf)),
    color = NA
  ) +
  coord_sf(
    xlim = c(-18.6, -13),
    ylim = c(27, 29.5)
  ) +
  scale_fill_manual(values = pal) +
  guides(fill = guide_legend(
    title = "Elevation",
    direction = "horizontal",
    label.position = "bottom",
    title.position = "top",
    nrow = 1
  )) +
  theme(legend.position = "bottom")



# Plot Mainland
ggplot(hypsobath) +
  geom_sf(aes(fill = as.factor(val_inf)),
    color = NA
  ) +
  coord_sf(
    xlim = c(-9.5, 4.4),
    ylim = c(35.8, 44)
  ) +
  scale_fill_manual(values = pal) +
  guides(fill = guide_legend(
    title = "Elevation",
    reverse = TRUE,
    keyheight = .8
  ))

# }
```
