mapSpain CDN for SIANE data
================

![Data](https://img.shields.io/badge/last%20data%20available-2020-green)
![Last Update](https://img.shields.io/badge/updated-2021--01--07-blue)

This branch is used as CDN to distribute CartoBase ANE data to
`mapSpain`.

Due to poor API, data is not easily reachable, so this branch would be
used as API endpoint.

Last update : **2021-01-07**, containing **data up to 2020**.

## Structure

Raw data is available under data-raw/YYYY. Both zipped and unzipped
versions are provided.

## Distribution

The `dist` folder contains a distribution of [**CartoBase
ANE**](https://www.ign.es/web/ane-area-ane) on
[**GPKG**](https://en.wikipedia.org/wiki/GeoPackage) format.

Updates are made running the `R/create_dist.R` script after proper
download of new information on `data-raw`.

### Files included

The files provided on `dist` come from the folder `todo` from each
distribution. These file contains the whole history on each dataset,
with two relevant fields, allowing to track historical changes between
data sets:

  - `fecha_alta`: Start validity date
  - `fecha_baja`: End validity date

It is necessary to apply some filtering depending on the date requested:

``` r
library(sf)
library(dplyr)

munic <- st_read("dist/se89_3_admin_muni_a_x.gpkg", quiet = TRUE) %>%
  filter(rotulo == "Arenas del Rey")

# Grey area = Initial
# Green line = Second row
# Blue line = Third row

plot(
  st_geometry(munic),
  col = c("grey50", NA, NA),
  border = c(NA, "green", "blue"),
  lty = c(1, 1, 5)
)
```

![](img/README-unnamed-chunk-1-1.png)<!-- -->

``` r


keepcols <- c("fecha_alta", "fecha_baja", "rotulo")

knitr::kable(st_drop_geometry(munic[, keepcols]))
```

| fecha\_alta | fecha\_baja | rotulo         |
| :---------- | :---------- | :------------- |
| 2005-12-31  | 2015-02-19  | Arenas del Rey |
| 2015-02-19  | 2018-12-13  | Arenas del Rey |
| 2018-12-13  | NA          | Arenas del Rey |

An example of filtering:

``` r

# 2010 shape
year <- 2010
year.fmt <- as.Date(paste(year, "01", "01", sep = "-"))

shp2010 <- munic %>%
  # If fecha_baja is NA means it is the current valid shape
  mutate(fecha_baja = ifelse(is.na(fecha_baja), Sys.Date(), fecha_baja)) %>%
  filter(fecha_alta < year.fmt & year.fmt <= fecha_baja)

plot(st_geometry(shp2010), main = year)
```

![](img/README-unnamed-chunk-2-1.png)<!-- -->

``` r

# 2017 shape
year <- 2017
year.fmt <- as.Date(paste(year, "01", "01", sep = "-"))

shp2017 <- munic %>%
  mutate(fecha_baja = ifelse(is.na(fecha_baja), Sys.Date(), fecha_baja)) %>%
  filter(fecha_alta < year.fmt & year.fmt <= fecha_baja)

plot(st_geometry(shp2017), main = year)
```

![](img/README-unnamed-chunk-2-2.png)<!-- -->

``` r

# Current value

shpcurrent <- munic %>% filter(is.na(fecha_baja))


plot(st_geometry(shpcurrent), main = "Current")
```

![](img/README-unnamed-chunk-2-3.png)<!-- -->

### Table of files

Full reference of each dataset in the [data-raw](data-raw/2020) folder.

| file                                 |  res | scope |
| :----------------------------------- | ---: | :---- |
| se89\_3\_admin\_ccaa\_a\_x.gpkg      |  3.0 | Spain |
| se89\_3\_admin\_ccaa\_a\_y.gpkg      |  3.0 | Spain |
| se89\_3\_admin\_muni\_a\_x.gpkg      |  3.0 | Spain |
| se89\_3\_admin\_muni\_a\_y.gpkg      |  3.0 | Spain |
| se89\_3\_admin\_prov\_a\_x.gpkg      |  3.0 | Spain |
| se89\_3\_admin\_prov\_a\_y.gpkg      |  3.0 | Spain |
| se89\_3\_hidro\_demc\_a\_x.gpkg      |  3.0 | Spain |
| se89\_3\_hidro\_demc\_a\_y.gpkg      |  3.0 | Spain |
| se89\_3\_hidro\_demt\_a\_x.gpkg      |  3.0 | Spain |
| se89\_3\_hidro\_demt\_a\_y.gpkg      |  3.0 | Spain |
| se89\_3\_hidro\_rio\_a\_x.gpkg       |  3.0 | Spain |
| se89\_3\_hidro\_rio\_l\_x.gpkg       |  3.0 | Spain |
| se89\_3\_hidro\_rio\_l\_y.gpkg       |  3.0 | Spain |
| se89\_3\_orog\_hipso\_a\_x.gpkg      |  3.0 | Spain |
| se89\_3\_orog\_hipso\_a\_y.gpkg      |  3.0 | Spain |
| se89\_3\_orog\_hipso\_l\_x.gpkg      |  3.0 | Spain |
| se89\_3\_orog\_hipso\_l\_y.gpkg      |  3.0 | Spain |
| se89\_3\_urban\_capimuni\_a\_x.gpkg  |  3.0 | Spain |
| se89\_3\_urban\_capimuni\_a\_y.gpkg  |  3.0 | Spain |
| se89\_3\_urban\_capimuni\_p\_x.gpkg  |  3.0 | Spain |
| se89\_3\_urban\_capimuni\_p\_y.gpkg  |  3.0 | Spain |
| se89\_3\_vias\_ctra\_l\_x.gpkg       |  3.0 | Spain |
| se89\_3\_vias\_ctra\_l\_y.gpkg       |  3.0 | Spain |
| se89\_3\_vias\_ffcc\_l\_x.gpkg       |  3.0 | Spain |
| se89\_3\_vias\_ffcc\_p\_x.gpkg       |  3.0 | Spain |
| se89\_6m5\_admin\_ccaa\_a\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_admin\_ccaa\_a\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_admin\_cela\_a\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_admin\_cela\_a\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_admin\_muni\_a\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_admin\_muni\_a\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_admin\_prov\_a\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_admin\_prov\_a\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_hidro\_demc\_a\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_hidro\_demc\_a\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_hidro\_demt\_a\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_hidro\_demt\_a\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_hidro\_rio\_a\_x.gpkg     |  6.5 | Spain |
| se89\_6m5\_hidro\_rio\_l\_x.gpkg     |  6.5 | Spain |
| se89\_6m5\_orog\_hipso\_a\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_orog\_hipso\_a\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_orog\_hipso\_l\_x.gpkg    |  6.5 | Spain |
| se89\_6m5\_orog\_hipso\_l\_y.gpkg    |  6.5 | Spain |
| se89\_6m5\_vias\_ffcc\_e\_x.gpkg     |  6.5 | Spain |
| se89\_10\_admin\_ccaa\_a\_x.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_ccaa\_a\_y.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_cela\_a\_x.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_cela\_a\_y.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_cels\_a\_x.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_cels\_a\_y.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_muni\_a\_x.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_muni\_a\_y.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_prov\_a\_x.gpkg     | 10.0 | Spain |
| se89\_10\_admin\_prov\_a\_y.gpkg     | 10.0 | Spain |
| se89\_10\_hidro\_demc\_a\_x.gpkg     | 10.0 | Spain |
| se89\_10\_hidro\_demc\_a\_y.gpkg     | 10.0 | Spain |
| se89\_10\_hidro\_demt\_a\_x.gpkg     | 10.0 | Spain |
| se89\_10\_hidro\_demt\_a\_y.gpkg     | 10.0 | Spain |
| se89\_10\_hidro\_rio\_a\_x.gpkg      | 10.0 | Spain |
| se89\_10\_hidro\_rio\_l\_x.gpkg      | 10.0 | Spain |
| se89\_10\_urban\_capiccaa\_p\_x.gpkg | 10.0 | Spain |
| se89\_10\_urban\_capilasp\_p\_y.gpkg | 10.0 | Spain |
| se89\_10\_urban\_capimuni\_p\_x.gpkg | 10.0 | Spain |
| se89\_10\_urban\_capimuni\_p\_y.gpkg | 10.0 | Spain |
| se89\_10\_urban\_capiprov\_p\_x.gpkg | 10.0 | Spain |
| se89\_10\_urban\_capiprov\_p\_y.gpkg | 10.0 | Spain |
| se89\_10\_urban\_capitene\_p\_y.gpkg | 10.0 | Spain |
| se89\_10\_vias\_ffcc\_e\_x.gpkg      | 10.0 | Spain |
| se89\_10\_vias\_ffcc\_l\_x.gpkg      | 10.0 | Spain |
| se89\_10\_vias\_ffcc\_p\_x.gpkg      | 10.0 | Spain |
| se89\_mult\_admin\_provcan\_l.gpkg   |   NA | NA    |

## Preview

<img src="img/README-preview-1.png" width="33%" /><img src="img/README-preview-2.png" width="33%" /><img src="img/README-preview-3.png" width="33%" /><img src="img/README-preview-4.png" width="33%" /><img src="img/README-preview-5.png" width="33%" /><img src="img/README-preview-6.png" width="33%" /><img src="img/README-preview-7.png" width="33%" /><img src="img/README-preview-8.png" width="33%" /><img src="img/README-preview-9.png" width="33%" /><img src="img/README-preview-10.png" width="33%" /><img src="img/README-preview-11.png" width="33%" /><img src="img/README-preview-12.png" width="33%" /><img src="img/README-preview-13.png" width="33%" /><img src="img/README-preview-14.png" width="33%" /><img src="img/README-preview-15.png" width="33%" /><img src="img/README-preview-16.png" width="33%" /><img src="img/README-preview-17.png" width="33%" /><img src="img/README-preview-18.png" width="33%" /><img src="img/README-preview-19.png" width="33%" /><img src="img/README-preview-20.png" width="33%" /><img src="img/README-preview-21.png" width="33%" /><img src="img/README-preview-22.png" width="33%" /><img src="img/README-preview-23.png" width="33%" /><img src="img/README-preview-24.png" width="33%" /><img src="img/README-preview-25.png" width="33%" /><img src="img/README-preview-26.png" width="33%" /><img src="img/README-preview-27.png" width="33%" /><img src="img/README-preview-28.png" width="33%" /><img src="img/README-preview-29.png" width="33%" /><img src="img/README-preview-30.png" width="33%" /><img src="img/README-preview-31.png" width="33%" /><img src="img/README-preview-32.png" width="33%" /><img src="img/README-preview-33.png" width="33%" /><img src="img/README-preview-34.png" width="33%" /><img src="img/README-preview-35.png" width="33%" /><img src="img/README-preview-36.png" width="33%" /><img src="img/README-preview-37.png" width="33%" /><img src="img/README-preview-38.png" width="33%" /><img src="img/README-preview-39.png" width="33%" /><img src="img/README-preview-40.png" width="33%" /><img src="img/README-preview-41.png" width="33%" /><img src="img/README-preview-42.png" width="33%" /><img src="img/README-preview-43.png" width="33%" /><img src="img/README-preview-44.png" width="33%" /><img src="img/README-preview-45.png" width="33%" /><img src="img/README-preview-46.png" width="33%" /><img src="img/README-preview-47.png" width="33%" /><img src="img/README-preview-48.png" width="33%" /><img src="img/README-preview-49.png" width="33%" /><img src="img/README-preview-50.png" width="33%" /><img src="img/README-preview-51.png" width="33%" /><img src="img/README-preview-52.png" width="33%" /><img src="img/README-preview-53.png" width="33%" /><img src="img/README-preview-54.png" width="33%" /><img src="img/README-preview-55.png" width="33%" /><img src="img/README-preview-56.png" width="33%" /><img src="img/README-preview-57.png" width="33%" /><img src="img/README-preview-58.png" width="33%" /><img src="img/README-preview-59.png" width="33%" /><img src="img/README-preview-60.png" width="33%" /><img src="img/README-preview-61.png" width="33%" /><img src="img/README-preview-62.png" width="33%" /><img src="img/README-preview-63.png" width="33%" /><img src="img/README-preview-64.png" width="33%" /><img src="img/README-preview-65.png" width="33%" /><img src="img/README-preview-66.png" width="33%" /><img src="img/README-preview-67.png" width="33%" /><img src="img/README-preview-68.png" width="33%" /><img src="img/README-preview-69.png" width="33%" /><img src="img/README-preview-70.png" width="33%" /><img src="img/README-preview-71.png" width="33%" />
