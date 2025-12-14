# Get [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `LINESTRING` or `POINT` with the railways of Spain

Loads a [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
`LINESTRING` or `POINT` object representing the nodes and railway lines
of Spain.

## Usage

``` r
esp_get_railway(
  year = Sys.Date(),
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  spatialtype = "line"
)
```

## Source

IGN data via a custom CDN (see
<https://github.com/rOpenSpain/mapSpain/tree/sianedata>).

## Arguments

- year:

  Release year.

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

- spatialtype:

  Spatial type of the output. Use `"line"` for extracting the railway as
  lines and `"point"` for extracting stations.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) `LINESTRING`
or `POINT` object.

## See also

Other infrastructure:
[`esp_get_roads()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_roads.md)

## Examples

``` r
# \donttest{

provs <- esp_get_prov()
ccaa <- esp_get_ccaa()

# Railways
rails <- esp_get_railway()

# Stations
stations <- esp_get_railway(spatialtype = "point")

# Map

library(ggplot2)

ggplot(provs) +
  geom_sf(fill = "grey99", color = "grey50") +
  geom_sf(data = ccaa, fill = NA) +
  geom_sf(
    data = rails, aes(color = tipo),
    show.legend = FALSE, linewidth = 1.5
  ) +
  geom_sf(
    data = stations,
    color = "red", alpha = 0.5
  ) +
  coord_sf(
    xlim = c(-7.5, -2.5),
    ylim = c(38, 41)
  ) +
  scale_color_manual(values = hcl.colors(
    length(unique(rails$tipo)), "viridis"
  )) +
  theme_minimal()

# }
```
