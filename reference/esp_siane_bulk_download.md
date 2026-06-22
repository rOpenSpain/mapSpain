# SIANE bulk download

Download zipped data from SIANE to the
[`cache_dir`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
and extract the relevant files.

## Usage

``` r
esp_siane_bulk_download(
  cache_dir = NULL,
  update_cache = FALSE,
  verbose = FALSE
)
```

## Source

CartoBase ANE (Atlas Nacional de España) provided by Instituto
Geográfico Nacional (IGN), <http://www.ign.es/web/ign/portal>. Years
available are 2005 up to today.

Copyright:
<https://centrodedescargas.cnig.es/CentroDescargas/cartobase-ane>

Always acknowledge authorship using the following statements:

1.  When the original digital product is not modified or altered, use
    one of the following statements:

    - CartoBase ANE 2006-2024 CC-BY 4.0 ign.es.

    - CartoBase ANE 2006-2024 CC-BY 4.0 Instituto Geográfico Nacional.

2.  When a new product is generated:

    - Obra derivada de CartoBase ANE 2006-2024 CC-BY 4.0 ign.es.

Data distributed through the `sianedata` data branch, see
<https://github.com/rOpenSpain/mapSpain/tree/sianedata>.

## Arguments

- cache_dir:

  Character string. A path to a cache directory. See **Caching**.

- update_cache:

  Logical. If `TRUE`, refreshes the cached file and forces a new
  download. Defaults to `FALSE`.

- verbose:

  A logical value. If `TRUE` displays informational messages.

## Value

An invisible character vector with the full paths of the extracted
files. See **Examples**.

## Caching

Functions that download data store files in `cache_dir`. When
`cache_dir` is `NULL`, they use the active package cache, which defaults
to a temporary directory. Set `update_cache = TRUE` to replace an
existing cached file. See **Caching strategies** in
[`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/reference/esp_set_cache_dir.md)
to configure a persistent cache.

## See also

Datasets sourced from CartoBase ANE (Atlas Nacional de España):
[`esp_get_capimun()`](https://ropenspain.github.io/mapSpain/reference/esp_get_capimun.md),
[`esp_get_ccaa_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_ccaa_siane.md),
[`esp_get_countries_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_countries_siane.md),
[`esp_get_munic_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_munic_siane.md),
[`esp_get_prov_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_prov_siane.md),
[`esp_get_spain_siane()`](https://ropenspain.github.io/mapSpain/reference/esp_get_spain_siane.md)

## Examples

``` r
tmp <- file.path(tempdir(), "testexample")
dest_files <- esp_siane_bulk_download(cache_dir = tmp)

# Read one file.
library(sf)
read_sf(dest_files[1]) |> head()
#> Simple feature collection with 6 features and 16 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 1.438781 ymin: 39.67722 xmax: 28.58508 ymax: 51.56253
#> Geodetic CRS:  ETRS89
#> # A tibble: 6 × 17
#>   fecha_alta fecha_baja rotulo     id_iso2  t_ua x_cvi y_cvi x_cap y_cap id_iso3
#>   <date>     <date>     <chr>      <chr>   <int> <dbl> <dbl> <dbl> <dbl> <chr>  
#> 1 2005-12-31 2019-12-31 Albania    AL         97 20.1   41.1 19.8   41.3 ALB    
#> 2 2005-12-31 2019-12-31 Andorra    AD         97  1.58  42.5  1.52  42.5 AND    
#> 3 2005-12-31 2019-12-31 Bélgica    BE         97  4.68  50.6  4.37  50.8 BEL    
#> 4 2005-12-31 2019-12-31 Bosnia y … BA         97 17.8   44.2 18.4   43.9 BIH    
#> 5 2005-12-31 2019-12-31 Liechtens… LI         97  9.56  47.2  9.52  47.1 LIE    
#> 6 2005-12-31 2019-12-31 Bulgaria   BG         97 25.2   42.8 23.3   42.7 BGR    
#> # ℹ 7 more variables: id_pais <chr>, id_palt <chr>, id_leng <chr>,
#> #   rotulo2 <chr>, st_area_sh <dbl>, st_length_ <dbl>, geom <MULTIPOLYGON [°]>

# Connect the function with the downloaded data.

connect <- esp_get_munic_siane(cache_dir = tmp, verbose = TRUE)
#> ℹ Cache directory is /tmp/RtmpCZEvXa/testexample/siane.
#> ✔ File already cached: /tmp/RtmpCZEvXa/testexample/siane/se89_3_admin_muni_a_x.gpkg.
#> ℹ Cache directory is /tmp/RtmpCZEvXa/testexample/siane.
#> ✔ File already cached: /tmp/RtmpCZEvXa/testexample/siane/se89_3_admin_muni_a_y.gpkg.

# The message shows that the file is already cached.

# Clean up.
unlink(tmp, force = TRUE, recursive = TRUE)
```
