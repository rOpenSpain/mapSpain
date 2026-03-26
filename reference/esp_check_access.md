# Check access to SIANE data resources

Check whether **R** has access to resources at
<https://github.com/rOpenSpain/mapSpain/tree/sianedata>.

## Usage

``` r
esp_check_access()
```

## Value

Logical scalar, `TRUE` if accessible and `FALSE` otherwise.

## See also

[`giscoR::gisco_check_access()`](https://ropengov.github.io/giscoR/reference/gisco_check_access.html).

## Examples

``` r
esp_check_access()
#> [1] TRUE
```
