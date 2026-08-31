# Get the attribution for a tile provider

`esp_get_attributions()` returns the attribution for a tile provider
defined by the `type` argument.

## Usage

``` r
esp_get_attributions(type, options = NULL)
```

## Arguments

- type:

  This argument can be one of:

  - The name of one of the pre-defined providers (see
    [esp_tiles_providers](https://ropenspain.github.io/mapSpain/reference/esp_tiles_providers.md)).

  - A list with two named elements `id` and `q` with your own arguments.
    See
    [`esp_make_provider()`](https://ropenspain.github.io/mapSpain/reference/esp_make_provider.md)
    and examples.

- options:

  A named list containing additional options to pass to the query.

## Value

A character string with the provider attribution, or `NULL` if no
attribution is available.

## See also

- [`esp_get_tiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md)
  downloads static map tiles.

- [`giscoR::gisco_attributions()`](https://ropengov.github.io/giscoR/reference/gisco_attributions.html)
  provides GISCO attribution text.

Static map tiles and imagery:
[`addProviderEspTiles()`](https://ropenspain.github.io/mapSpain/reference/addProviderEspTiles.md),
[`esp_get_tiles()`](https://ropenspain.github.io/mapSpain/reference/esp_get_tiles.md),
[`esp_make_provider()`](https://ropenspain.github.io/mapSpain/reference/esp_make_provider.md)

## Examples

``` r
esp_get_attributions("IGNBase.Todo")
#> [1] "CC BY 4.0 scne.es. Sistema Geográfico Nacional IGN"
```
