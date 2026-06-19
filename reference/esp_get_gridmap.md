# Get a [`sf`](https://r-spatial.github.io/sf/reference/sf.html) hexbin or squared `POLYGON` of Spain

Loads a hexbin map
([`sf`](https://r-spatial.github.io/sf/reference/sf.html) object) or a
map of squares with boundaries of the provinces or Autonomous
Communities and Cities of Spain.

## Usage

``` r
esp_get_hex_prov(prov = NULL)

esp_get_hex_ccaa(ccaa = NULL)

esp_get_grid_prov(prov = NULL)

esp_get_grid_ccaa(ccaa = NULL)
```

## Arguments

- prov, ccaa:

  Character. A vector of names, codes or both for provinces and
  Autonomous Communities and Cities, or `NULL` to get all the data. See
  **Details**.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Details

Hexbin (or grid) maps have an advantage over traditional choropleth
maps. In choropleths, regions with larger polygons tend to appear more
prominent simply because of their size, which introduces visual bias.
With hexbin maps, each region is represented equally, reducing this
bias.

You can use and mix names, ISO codes, `"codauto"` or `"cpro"` codes (see
[esp_codelist](https://ropenspain.github.io/mapSpain/reference/esp_codelist.md))
and NUTS codes of different levels.

When using a code corresponding to a higher level (for example,
`esp_get_prov("Andalucia")`), all the corresponding units of that level
are provided (in this case, all the provinces of Andalusia).

Results are provided in **EPSG:4258**. Use
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html)
to change the projection.

## See also

Additional boundary datasets and representations:
[`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/reference/esp_get_comarca.md),
[`esp_get_simpl`](https://ropenspain.github.io/mapSpain/reference/esp_get_simpl.md)

## Examples

``` r
# \donttest{
esp <- esp_get_spain()
hexccaa <- esp_get_hex_ccaa()

library(ggplot2)

ggplot(hexccaa) +
  geom_sf(data = esp) +
  geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
  geom_sf_text(aes(label = label), check_overlap = TRUE) +
  theme_void() +
  labs(title = "Hexbin: Autonomous Communities and Cities")
#> Warning: st_point_on_surface may not give correct results for longitude/latitude data


hexprov <- esp_get_hex_prov()

ggplot(hexprov) +
  geom_sf(data = esp) +
  geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
  geom_sf_text(aes(label = label), check_overlap = TRUE) +
  theme_void() +
  labs(title = "Hexbin: Provinces")
#> Warning: st_point_on_surface may not give correct results for longitude/latitude data


gridccaa <- esp_get_grid_ccaa()

ggplot(gridccaa) +
  geom_sf(data = esp) +
  geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
  geom_sf_text(aes(label = label), check_overlap = TRUE) +
  theme_void() +
  labs(title = "Grid: Autonomous Communities and Cities")
#> Warning: st_point_on_surface may not give correct results for longitude/latitude data


gridprov <- esp_get_grid_prov()

ggplot(gridprov) +
  geom_sf(data = esp) +
  geom_sf(aes(fill = codauto), alpha = 0.3, show.legend = FALSE) +
  geom_sf_text(aes(label = label), check_overlap = TRUE) +
  theme_void() +
  labs(title = "Grid: Provinces")
#> Warning: st_point_on_surface may not give correct results for longitude/latitude data

# }
```
