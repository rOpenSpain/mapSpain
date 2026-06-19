# Comarcas of Spain

Get [comarcas of
Spain](https://en.wikipedia.org/wiki/Comarcas_of_Spain). Comarcas are
traditional informal territorial divisions comprising several
municipalities that share geographical, economic or cultural traits,
typically with poorly defined limits.

## Usage

``` r
esp_get_comarca(
  region = NULL,
  comarca = NULL,
  moveCAN = TRUE,
  type = c("INE", "IGN", "AGR", "LIV"),
  epsg = 4258,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
)
```

## Source

INE: PC_Axis files, IGN, Ministry of Agriculture, Fisheries and Food
(MAPA).

## Arguments

- region:

  Character string. A vector of names, codes or both for provinces, or
  `NULL` to get all the comarcas. See **Details**.

- comarca:

  Character string. A name or
  [`regex`](https://rdrr.io/r/base/grep.html) expression with the names
  of the required comarcas. Use `NULL` to return all possible comarcas.

- moveCAN:

  A logical `TRUE/FALSE` or a vector of coordinates `c(lat, lon)`. It
  places the Canary Islands close to Spain's mainland. Initial position
  can be adjusted using the vector of coordinates. See **Displacing the
  Canary Islands** in
  [`esp_move_can()`](https://ropenspain.github.io/mapSpain/reference/esp_move_can.md).

- type:

  Character string. One of `"INE"`, `"IGN"`, `"AGR"`, `"LIV"`. Type of
  comarca to return. See **Details**.

- epsg:

  Character string or number. Projection of the map: 4-digit [EPSG
  code](https://epsg.io/). One of:

  - `"4258"`: [ETRS89](https://epsg.io/4258).

  - `"4326"`: [WGS84](https://epsg.io/4326).

  - `"3035"`: [ETRS89 / ETRS-LAEA](https://epsg.io/3035).

  - `"3857"`: [Pseudo-Mercator](https://epsg.io/3857).

- update_cache:

  Logical. If `TRUE`, refreshes the cached file and forces a new
  download. Defaults to `FALSE`.

- cache_dir:

  Character string. A path to a cache directory. See **Caching**.

- verbose:

  A logical value. If `TRUE` displays informational messages.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Details

When using `region` you can use and mix names and NUTS codes (levels 1,
2 or 3), ISO codes (corresponding to level 2 or 3) or `"cpro"` (see
[esp_codelist](https://ropenspain.github.io/mapSpain/reference/esp_codelist.md)).

When calling a higher level (province, Autonomous Community or City, or
NUTS 1), all comarcas of that level are added.

## Note

The use of the information contained on the [INE
website](https://www.ine.es/en/index.htm) may be carried out by users or
re-use agents, at their own risk, and they will be the sole liable
parties in the case of having to answer to third parties due to damages
arising from such use.

## About comarcas

Comarcas (English equivalent: district, county, area or zone) do not
always have a formal legal status. They correspond mainly to natural
areas (valleys, river basins and similar areas), historical regions or
ancient kingdoms.

In the case of Spain, comarcas only have an administrative character
legally recognized in Catalonia, the Basque Country, Navarra (named
merindades instead), the region of El Bierzo (Castilla y Leon) and
Aragon. Galicia, the Principality of Asturias and Andalusia have
functional comarcas.

## Types

`esp_get_comarca()` can retrieve several types of comarcas, each
provided under different classification criteria.

- `"INE"`: Comarcas defined by the National Statistics Institute (INE).

- `"IGN"`: Official comarcas, only available for some Autonomous
  Communities and Cities, provided by the National Geographic Institute.

- `"AGR"`: Agrarian comarcas defined by the Ministry of Agriculture,
  Fisheries and Food (MAPA).

- `"LIV"`: Livestock comarcas defined by the Ministry of Agriculture,
  Fisheries and Food (MAPA).

## Caching

Functions that download data store files in `cache_dir`. When
`cache_dir` is `NULL`, they use the active package cache, which defaults
to a temporary directory. Set `update_cache = TRUE` to replace an
existing cached file. See **Caching strategies** in
[`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
to configure a persistent cache.

## See also

Additional boundary datasets and representations:
[`esp_get_gridmap`](https://ropenspain.github.io/mapSpain/reference/esp_get_gridmap.md),
[`esp_get_simpl`](https://ropenspain.github.io/mapSpain/reference/esp_get_simpl.md)

## Examples

``` r
# \donttest{
comarcas <- esp_get_comarca(moveCAN = FALSE)

library(ggplot2)

ggplot(comarcas) +
  geom_sf()


# IGN provides recognized comarcas.

rec <- esp_get_comarca(type = "IGN")

ggplot(rec) +
  geom_sf(aes(fill = t_comarca))


# Legal comarcas of Catalunya.

comarcas_cat <- esp_get_comarca("Catalunya", type = "IGN")

ggplot(comarcas_cat) +
  geom_sf(aes(fill = ine.prov.name)) +
  labs(fill = "Province")

# }
```
