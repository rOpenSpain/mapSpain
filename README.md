# mapSpain CDN for CartoBase ANE

-   [Source data](#source-data)
-   [Structure](#structure)
-   [Distribution](#distribution)
-   [Files included](#files-included)
    -   [Table of files](#table-of-files)
-   [Preview](#preview)

![Data](https://img.shields.io/badge/last%20data%20available-2024-green) ![Last
Update](https://img.shields.io/badge/updated-2024--08--02-blue)

This branch is used as CDN to distribute CartoBase ANE data to **mapSpain**.

Due to poor API, data is not easily reachable, so this branch would be used as
API endpoint.

Last update : **2024-08-02**, containing **data up to 2024**.

## Source data {#source-data}

Atlas Nacional de España (ANE) [CC BY
4.0](https://creativecommons.org/licenses/by/4.0/deed.en)
[ign.es](http://www.ign.es).

<http://centrodedescargas.cnig.es/CentroDescargas/buscar.do?filtro.codFamilia=CAANE>

## Structure {#structure}

Raw data is available under data-raw/YYYY. Zipped version and unzipped (selected
files) are provided.

## Distribution {#distribution}

The `dist` folder contains a distribution of [**CartoBase
ANE**](https://www.ign.es/web/ane-area-ane) on
[**GPKG**](https://en.wikipedia.org/wiki/GeoPackage) format.

A `zip` file ([dist/CartoBase.zip](dist/CartoBase.zip), 26.4 Mb ) is also
provided, including all the data on `dist`.

## Files included {#files-included}

The files provided on `dist` come from the folder `todo` from each distribution.
These file contains the whole history on each dataset, with two relevant fields,
allowing to track historical changes between data sets:

-   `fecha_alta`: Start validity date
-   `fecha_baja`: End validity date

It is necessary to apply some filtering depending on the date requested:

``` r
library(sf)
library(dplyr)
library(ggplot2)

munic <- read_sf("dist/se89_3_admin_muni_a_x.gpkg", quiet = TRUE) %>%
  filter(rotulo == "Arenas del Rey")


ggplot(munic) +
  geom_sf() +
  facet_wrap(~fecha_alta, nrow = 1)
```

![](img/README-unnamed-chunk-23-1.png)<!-- -->

``` r


munic %>%
  st_drop_geometry() %>%
  select(fecha_alta, fecha_baja, rotulo) %>%
  knitr::kable()
```

| fecha_alta | fecha_baja | rotulo         |
|:-----------|:-----------|:---------------|
| 2005-12-31 | 2015-02-19 | Arenas del Rey |
| 2015-02-19 | 2018-12-13 | Arenas del Rey |
| 2018-12-13 | NA         | Arenas del Rey |

An example of filtering:

``` r
# 2010 shape
year <- 2010
year.fmt <- as.Date(paste(year, "01", "01", sep = "-"))

shp2010 <- munic %>%
  # If fecha_baja is NA means it is the current valid shape
  mutate(fecha_baja = ifelse(is.na(fecha_baja), Sys.Date(), fecha_baja)) %>%
  filter(fecha_alta < year.fmt & year.fmt <= fecha_baja)

ggplot(shp2010) +
  geom_sf() +
  labs(title = year)

# 2017 shape
year <- 2017
year.fmt <- as.Date(paste(year, "01", "01", sep = "-"))

shp2017 <- munic %>%
  mutate(fecha_baja = ifelse(is.na(fecha_baja), Sys.Date(), fecha_baja)) %>%
  filter(fecha_alta < year.fmt & year.fmt <= fecha_baja)

ggplot(shp2017) +
  geom_sf() +
  labs(title = year)

# Current value

shpcurrent <- munic %>% filter(is.na(fecha_baja))


ggplot(shpcurrent) +
  geom_sf() +
  labs(title = "Current")
```

<img src="img/README-unnamed-chunk-24-1.png" width="33%"/><img src="img/README-unnamed-chunk-24-2.png" width="33%"/><img src="img/README-unnamed-chunk-24-3.png" width="33%"/>

### Table of files {#table-of-files}

Full reference of each dataset in the
[data-raw](%60r%20paste0(%22data-raw/%22,params$last_year)%60) folder.

There are 77 files available:

| file                            | res | scope  | size   |
|:--------------------------------|:----|:-------|:-------|
| se89_3_admin_ccaa_a_x.gpkg      | 3   | Europe | 380 Kb |
| se89_3_admin_ccaa_a_y.gpkg      | 3   | Europe | 112 Kb |
| se89_3_admin_muni_a_x.gpkg      | 3   | Europe | 5.5 Mb |
| se89_3_admin_muni_a_y.gpkg      | 3   | Europe | 176 Kb |
| se89_3_admin_prov_a_x.gpkg      | 3   | Europe | 616 Kb |
| se89_3_admin_prov_a_y.gpkg      | 3   | Europe | 112 Kb |
| se89_3_hidro_demc_a_x.gpkg      | 3   | Europe | 304 Kb |
| se89_3_hidro_demc_a_y.gpkg      | 3   | Europe | 96 Kb  |
| se89_3_hidro_demt_a_x.gpkg      | 3   | Europe | 340 Kb |
| se89_3_hidro_demt_a_y.gpkg      | 3   | Europe | 120 Kb |
| se89_3_hidro_rio_a_x.gpkg       | 3   | Europe | 268 Kb |
| se89_3_hidro_rio_l_x.gpkg       | 3   | Europe | 1.2 Mb |
| se89_3_hidro_rio_l_y.gpkg       | 3   | Europe | 104 Kb |
| se89_3_orog_hipso_a_x.gpkg      | 3   | Europe | 4.7 Mb |
| se89_3_orog_hipso_a_y.gpkg      | 3   | Europe | 324 Kb |
| se89_3_orog_hipso_l_x.gpkg      | 3   | Europe | 2.7 Mb |
| se89_3_orog_hipso_l_y.gpkg      | 3   | Europe | 216 Kb |
| se89_3_urban_capimuni_a_x.gpkg  | 3   | Europe | 136 Kb |
| se89_3_urban_capimuni_a_y.gpkg  | 3   | Europe | 96 Kb  |
| se89_3_urban_capimuni_p_x.gpkg  | 3   | Europe | 1.5 Mb |
| se89_3_urban_capimuni_p_y.gpkg  | 3   | Europe | 116 Kb |
| se89_3_vias_ctra_l_x.gpkg       | 3   | Europe | 768 Kb |
| se89_3_vias_ctra_l_y.gpkg       | 3   | Europe | 116 Kb |
| se89_3_vias_ffcc_l_x.gpkg       | 3   | Europe | 340 Kb |
| se89_3_vias_ffcc_p_x.gpkg       | 3   | Europe | 128 Kb |
| se89_6m5_admin_ccaa_a_x.gpkg    | 6.5 | Europe | 336 Kb |
| se89_6m5_admin_ccaa_a_y.gpkg    | 6.5 | Europe | 100 Kb |
| se89_6m5_admin_cela_a_x.gpkg    | 6.5 | Europe | 680 Kb |
| se89_6m5_admin_cela_a_y.gpkg    | 6.5 | Europe | 116 Kb |
| se89_6m5_admin_muni_a_x.gpkg    | 6.5 | Europe | 5.4 Mb |
| se89_6m5_admin_muni_a_y.gpkg    | 6.5 | Europe | 160 Kb |
| se89_6m5_admin_prov_a_x.gpkg    | 6.5 | Europe | 540 Kb |
| se89_6m5_admin_prov_a_y.gpkg    | 6.5 | Europe | 104 Kb |
| se89_6m5_hidro_demc_a_x.gpkg    | 6.5 | Europe | 196 Kb |
| se89_6m5_hidro_demc_a_y.gpkg    | 6.5 | Europe | 96 Kb  |
| se89_6m5_hidro_demt_a_x.gpkg    | 6.5 | Europe | 216 Kb |
| se89_6m5_hidro_demt_a_y.gpkg    | 6.5 | Europe | 104 Kb |
| se89_6m5_hidro_rio_a_x.gpkg     | 6.5 | Europe | 144 Kb |
| se89_6m5_hidro_rio_l_x.gpkg     | 6.5 | Europe | 312 Kb |
| se89_6m5_orog_hipso_a_x.gpkg    | 6.5 | Europe | 1.8 Mb |
| se89_6m5_orog_hipso_a_y.gpkg    | 6.5 | Europe | 256 Kb |
| se89_6m5_orog_hipso_l_x.gpkg    | 6.5 | Europe | 660 Kb |
| se89_6m5_orog_hipso_l_y.gpkg    | 6.5 | Europe | 180 Kb |
| se89_6m5_vias_ffcc_e_x.gpkg     | 6.5 | Europe | 204 Kb |
| se89_10_admin_ccaa_a_x.gpkg     | 10  | Spain  | 196 Kb |
| se89_10_admin_ccaa_a_y.gpkg     | 10  | Spain  | 100 Kb |
| se89_10_admin_cela_a_x.gpkg     | 10  | Spain  | 560 Kb |
| se89_10_admin_cela_a_y.gpkg     | 10  | Spain  | 112 Kb |
| se89_10_admin_cels_a_x.gpkg     | 10  | Spain  | 544 Kb |
| se89_10_admin_cels_a_y.gpkg     | 10  | Spain  | 112 Kb |
| se89_10_admin_muni_a_x.gpkg     | 10  | Spain  | 5.3 Mb |
| se89_10_admin_muni_a_y.gpkg     | 10  | Spain  | 160 Kb |
| se89_10_admin_prov_a_x.gpkg     | 10  | Spain  | 300 Kb |
| se89_10_admin_prov_a_y.gpkg     | 10  | Spain  | 104 Kb |
| se89_10_hidro_demc_a_x.gpkg     | 10  | Spain  | 168 Kb |
| se89_10_hidro_demc_a_y.gpkg     | 10  | Spain  | 96 Kb  |
| se89_10_hidro_demt_a_x.gpkg     | 10  | Spain  | 212 Kb |
| se89_10_hidro_demt_a_y.gpkg     | 10  | Spain  | 104 Kb |
| se89_10_hidro_rio_a_x.gpkg      | 10  | Spain  | 116 Kb |
| se89_10_hidro_rio_l_x.gpkg      | 10  | Spain  | 220 Kb |
| se89_10_urban_capiccaa_p_x.gpkg | 10  | Spain  | 96 Kb  |
| se89_10_urban_capilasp_p_y.gpkg | 10  | Spain  | 96 Kb  |
| se89_10_urban_capimuni_p_x.gpkg | 10  | Spain  | 1.5 Mb |
| se89_10_urban_capimuni_p_y.gpkg | 10  | Spain  | 116 Kb |
| se89_10_urban_capiprov_p_x.gpkg | 10  | Spain  | 104 Kb |
| se89_10_urban_capiprov_p_y.gpkg | 10  | Spain  | 96 Kb  |
| se89_10_urban_capitene_p_y.gpkg | 10  | Spain  | 96 Kb  |
| se89_10_vias_ffcc_e_x.gpkg      | 10  | Spain  | 108 Kb |
| se89_10_vias_ffcc_l_x.gpkg      | 10  | Spain  | 200 Kb |
| se89_10_vias_ffcc_p_x.gpkg      | 10  | Spain  | 112 Kb |
| ee89_14_admin_pais_a.gpkg       | 14  | Europe | 1.8 Mb |
| ee89_14_urban_capital_p.gpkg    | 14  | Europe | 120 Kb |
| ww84_60_admin_pais_a.gpkg       | 60  | World  | 2.2 Mb |
| ww84_60_admin_paismar_a.gpkg    | 60  | World  | 112 Kb |
| ww84_60_hidro_pesc_a.gpkg       | 60  | World  | 420 Kb |
| ww84_60_urban_capital_p.gpkg    | 60  | World  | 156 Kb |
| se89_mult_admin_provcan_l.gpkg  | NA  | NA     | 96 Kb  |

## Preview {#preview}

<img src="img/README-preview-1.png" width="33%"/><img src="img/README-preview-2.png" width="33%"/><img src="img/README-preview-3.png" width="33%"/><img src="img/README-preview-4.png" width="33%"/><img src="img/README-preview-5.png" width="33%"/><img src="img/README-preview-6.png" width="33%"/><img src="img/README-preview-7.png" width="33%"/><img src="img/README-preview-8.png" width="33%"/><img src="img/README-preview-9.png" width="33%"/><img src="img/README-preview-10.png" width="33%"/><img src="img/README-preview-11.png" width="33%"/><img src="img/README-preview-12.png" width="33%"/><img src="img/README-preview-13.png" width="33%"/><img src="img/README-preview-14.png" width="33%"/><img src="img/README-preview-15.png" width="33%"/><img src="img/README-preview-16.png" width="33%"/><img src="img/README-preview-17.png" width="33%"/><img src="img/README-preview-18.png" width="33%"/><img src="img/README-preview-19.png" width="33%"/><img src="img/README-preview-20.png" width="33%"/><img src="img/README-preview-21.png" width="33%"/><img src="img/README-preview-22.png" width="33%"/><img src="img/README-preview-23.png" width="33%"/><img src="img/README-preview-24.png" width="33%"/><img src="img/README-preview-25.png" width="33%"/><img src="img/README-preview-26.png" width="33%"/><img src="img/README-preview-27.png" width="33%"/><img src="img/README-preview-28.png" width="33%"/><img src="img/README-preview-29.png" width="33%"/><img src="img/README-preview-30.png" width="33%"/><img src="img/README-preview-31.png" width="33%"/><img src="img/README-preview-32.png" width="33%"/><img src="img/README-preview-33.png" width="33%"/><img src="img/README-preview-34.png" width="33%"/><img src="img/README-preview-35.png" width="33%"/><img src="img/README-preview-36.png" width="33%"/><img src="img/README-preview-37.png" width="33%"/><img src="img/README-preview-38.png" width="33%"/><img src="img/README-preview-39.png" width="33%"/><img src="img/README-preview-40.png" width="33%"/><img src="img/README-preview-41.png" width="33%"/><img src="img/README-preview-42.png" width="33%"/><img src="img/README-preview-43.png" width="33%"/><img src="img/README-preview-44.png" width="33%"/><img src="img/README-preview-45.png" width="33%"/><img src="img/README-preview-46.png" width="33%"/><img src="img/README-preview-47.png" width="33%"/><img src="img/README-preview-48.png" width="33%"/><img src="img/README-preview-49.png" width="33%"/><img src="img/README-preview-50.png" width="33%"/><img src="img/README-preview-51.png" width="33%"/><img src="img/README-preview-52.png" width="33%"/><img src="img/README-preview-53.png" width="33%"/><img src="img/README-preview-54.png" width="33%"/><img src="img/README-preview-55.png" width="33%"/><img src="img/README-preview-56.png" width="33%"/><img src="img/README-preview-57.png" width="33%"/><img src="img/README-preview-58.png" width="33%"/><img src="img/README-preview-59.png" width="33%"/><img src="img/README-preview-60.png" width="33%"/><img src="img/README-preview-61.png" width="33%"/><img src="img/README-preview-62.png" width="33%"/><img src="img/README-preview-63.png" width="33%"/><img src="img/README-preview-64.png" width="33%"/><img src="img/README-preview-65.png" width="33%"/><img src="img/README-preview-66.png" width="33%"/><img src="img/README-preview-67.png" width="33%"/><img src="img/README-preview-68.png" width="33%"/><img src="img/README-preview-69.png" width="33%"/><img src="img/README-preview-70.png" width="33%"/><img src="img/README-preview-71.png" width="33%"/><img src="img/README-preview-72.png" width="33%"/><img src="img/README-preview-73.png" width="33%"/><img src="img/README-preview-74.png" width="33%"/><img src="img/README-preview-75.png" width="33%"/><img src="img/README-preview-76.png" width="33%"/><img src="img/README-preview-77.png" width="33%"/>
