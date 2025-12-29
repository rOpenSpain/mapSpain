# Database with the population of Spain by municipality (2025)

Database with the population of Spain by municipality (2025)

## Format

An example
[tibble](https://tibble.tidyverse.org/reference/tbl_df-class.html)
object with 8,132 rows containing the population data by municipality in
Spain (2025).

- cpro:

  INE code of the province.

- provincia:

  name of the province.

- cmun:

  INE code of the municipality.

- name:

  Name of the municipality.

- pob25:

  Overall population (2025)

- men:

  Men population (2025)

- women:

  Women population (2025)

## Source

INE: Instituto Nacional de Estadistica
<https://www.ine.es/dyngs/INEbase/categoria.htm?c=Estadistica_P&cid=1254734710990>.

## See also

Other datasets:
[`esp_codelist`](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md),
[`esp_nuts_2024`](https://ropenspain.github.io/mapSpain/dev/reference/esp_nuts_2024.md),
[`esp_tiles_providers`](https://ropenspain.github.io/mapSpain/dev/reference/esp_tiles_providers.md)

## Examples

``` r
data("pobmun25")
```
