# Simplified map of provinces and Autonomous Communities and Cities of Spain

Simplified map with the boundaries of the provinces or Autonomous
Communities of Spain, as provided by the **INE** (Instituto Nacional de
Estadistica).

## Usage

``` r
esp_get_simpl_prov(
  prov = NULL,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
)

esp_get_simpl_ccaa(
  ccaa = NULL,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE
)
```

## Source

INE: PC-Axis files.

## Arguments

- prov, ccaa:

  Character. A vector of names, codes or both for provinces and
  Autonomous Communities and Cities, or `NULL` to get all the data. See
  **Details**.

- update_cache:

  Logical. Should the cached file be refreshed? Default is `FALSE`. When
  set to `TRUE`, it will force a new download.

- cache_dir:

  Character string. A path to a cache directory. See **Caching
  strategies** section in
  [`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_set_cache_dir.md).

- verbose:

  logical. If `TRUE` displays informational messages.

## Value

A [`sf`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Details

Results are provided **without CRS**, as provided by the source.

You can use and mix names, ISO codes, `"codauto"` or `"cpro"` codes (see
[esp_codelist](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md))
and NUTS codes of different levels.

When using a code corresponding to a higher level (for example,
`esp_get_prov("Andalucia")`), all the corresponding units of that level
are provided (in this case, all the provinces of Andalusia).

## See also

[`esp_get_gridmap()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_gridmap.md).

Political and administrative boundary datasets:
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_capimun.md),
[`esp_get_ccaa()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa.md),
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_ccaa_siane.md),
[`esp_get_comarca()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_comarca.md),
[`esp_get_countries_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_countries_siane.md),
[`esp_get_gridmap`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_gridmap.md),
[`esp_get_munic()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_munic.md),
[`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_munic_siane.md),
[`esp_get_nuts()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_nuts.md),
[`esp_get_prov()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_prov.md),
[`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_prov_siane.md),
[`esp_get_spain()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_spain.md),
[`esp_get_spain_siane()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_spain_siane.md),
[`esp_siane_bulk_download()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_siane_bulk_download.md)

## Examples

``` r
# \donttest{
prov_simp <- esp_get_simpl_prov()

library(ggplot2)

ggplot(prov_simp) +
  geom_sf(aes(fill = ine.ccaa.name)) +
  labs(fill = "Autonomous Communities and Cities")


# Provinces of a single Autonomous Community or City.

and_simple <- esp_get_simpl_prov("Andalucia")

ggplot(and_simple) +
  geom_sf()


# Autonomous Communities and Cities.

ccaa_simp <- esp_get_simpl_ccaa()

ggplot(ccaa_simp) +
  geom_sf() +
  geom_sf_text(aes(label = ine.ccaa.name), check_overlap = TRUE)

# }
```
