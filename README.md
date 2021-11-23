
# mapSpain <img src="man/figures/logo.png" align="right" width="120"/>

<!-- badges: start -->

[![rOS-badge](https://ropenspain.github.io/rostemplate/reference/figures/ropenspain-badge.svg)](https://ropenspain.es/)
[![CRAN-status](https://www.r-pkg.org/badges/version/mapSpain)](https://CRAN.R-project.org/package=mapSpain)
[![CRAN-results](https://cranchecks.info/badges/worst/mapSpain)](https://cran.r-project.org/web/checks/check_results_mapSpain.html)
[![Downloads](https://cranlogs.r-pkg.org/badges/mapSpain)](https://CRAN.R-project.org/package=mapSpain)
[![r-universe](https://ropenspain.r-universe.dev/badges/mapSpain)](https://ropenspain.r-universe.dev/)
[![R-CMD-check](https://github.com/rOpenSpain/mapSpain/workflows/R-CMD-check/badge.svg)](https://github.com/rOpenSpain/mapSpain/actions?query=workflow%3AR-CMD-check)
[![codecov](https://codecov.io/gh/rOpenSpain/mapSpain/branch/main/graph/badge.svg?token=6L01BKLL85)](https://app.codecov.io/gh/rOpenSpain/mapSpain)
[![DOI](https://img.shields.io/badge/DOI-10.5281/zenodo.5366622-blue)](https://doi.org/10.5281/zenodo.5366622)
[![Project-Status:Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![status](https://tinyverse.netlify.com/badge/mapSpain)](https://CRAN.R-project.org/package=mapSpain)

<!-- badges: end -->

[**mapSpain**](https://ropenspain.github.io/mapSpain/) is a package that
provides spatial `sf` objects of the administrative boundaries of Spain,
including CCAA, provinces and municipalities.

**mapSpain** also provides a leaflet plugin to be used with the
[`leaflet` package](https://rstudio.github.io/leaflet/), that loads
several basemaps of public institutions of Spain, and the ability of
downloading and processing static tiles.

Full site with examples and vignettes on
<https://ropenspain.github.io/mapSpain/>

## Installation

Install **mapSpain** from
[**CRAN**](https://CRAN.R-project.org/package=mapSpain):

``` r
install.packages("mapSpain", dependencies = TRUE)
```

You can install the developing version of **mapSpain** using the
[r-universe](https://ropenspain.r-universe.dev/ui#builds):

``` r
# Enable this universe
options(repos = c(
  ropenspain = "https://ropenspain.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))

install.packages("mapSpain", dependencies = TRUE)
```

Alternatively, you can install the developing version of **mapSpain**
with:

``` r
library(remotes)
install_github("rOpenSpain/mapSpain", dependencies = TRUE)
```

## Usage

This script highlights some features of **mapSpain** :

``` r

library(mapSpain)

census <- mapSpain::pobmun19

# Extract CCAA from base dataset

codelist <- mapSpain::esp_codelist

census <-
  unique(merge(census, codelist[, c("cpro", "codauto")], all.x = TRUE))

# Summarize by CCAA
census_ccaa <-
  aggregate(cbind(pob19, men, women) ~ codauto, data = census, sum)

census_ccaa$porc_women <- census_ccaa$women / census_ccaa$pob19
census_ccaa$porc_women_lab <-
  paste0(round(100 * census_ccaa$porc_women, 2), "%")

# Merge into spatial data

CCAA_sf <- esp_get_ccaa()
CCAA_sf <- merge(CCAA_sf, census_ccaa)
Can <- esp_get_can_box()


# Plot with ggplot
library(ggplot2)


ggplot(CCAA_sf) +
  geom_sf(aes(fill = porc_women),
    color = "grey70",
    lwd = .3
  ) +
  geom_sf(data = Can, color = "grey70") +
  geom_sf_label(aes(label = porc_women_lab),
    fill = "white", alpha = 0.5,
    size = 3,
    label.size = 0
  ) +
  scale_fill_gradientn(
    colors = hcl.colors(10, "Blues", rev = TRUE),
    n.breaks = 10,
    labels = function(x) {
      sprintf("%1.1f%%", 100 * x)
    },
    guide = guide_legend(title = "Porc. women")
  ) +
  theme_void() +
  theme(legend.position = c(0.1, 0.6))
```

<img src="https://raw.githubusercontent.com/ropenspain/mapSpain/main/img/README-static-1.png" width="100%" />

You can combine `sf` objects with static tiles

``` r

# Get census
census <- mapSpain::pobmun19
census$porc_women <- census$women / census$pob19

# Get shapes
shape <- esp_get_munic_siane(region = "Segovia", epsg = 3857)
provs <- esp_get_prov_siane(epsg = 3857)

shape_pop <- merge(shape,
  census,
  by = c("cpro", "cmun"),
  all.x = TRUE
)


tile <-
  esp_getTiles(shape_pop,
    type = "IGNBase.Todo",
    zoom = 10,
    bbox_expand = .1
  )

# Plot

library(ggplot2)

lims <- as.double(terra::ext(tile)@ptr$vector)

ggplot(remove_missing(shape_pop, na.rm = TRUE)) +
  layer_spatraster(tile) +
  geom_sf(aes(fill = porc_women), color = NA) +
  geom_sf(data = provs, fill = NA) +
  scale_fill_gradientn(
    colours = hcl.colors(10, "RdYlBu", alpha = .5),
    n.breaks = 8,
    labels = function(x) {
      sprintf("%1.0f%%", 100 * x)
    },
    guide = guide_legend(title = "", )
  ) +
  coord_sf(
    xlim = lims[c(1, 2)],
    ylim = lims[c(3, 4)],
    expand = FALSE
  ) +
  labs(
    title = "Share of women in Segovia by town (2019)",
    caption = "Source: INE"
  ) +
  theme_void() +
  theme(
    title = element_text(face = "bold")
  )
```

<img src="https://raw.githubusercontent.com/ropenspain/mapSpain/main/img/README-tile-1.png" width="100%" />

## mapSpain and giscoR

If you need to plot Spain along with another countries, consider using
[**giscoR**](https://ropengov.github.io/giscoR/) package, that is
installed as a dependency when you installed **mapSpain**. A basic
example:

``` r

library(giscoR)

# Set the same resolution for a perfect fit

res <- "03"

# Same crs
target_crs <- 3035

all_countries <- gisco_get_countries(
  resolution = res,
  epsg = target_crs
)
eu_countries <- gisco_get_countries(
  resolution = res, region = "EU",
  epsg = target_crs
)
ccaa <- esp_get_ccaa(
  moveCAN = FALSE, resolution = res,
  epsg = target_crs
)

library(ggplot2)

ggplot(all_countries) +
  geom_sf(fill = "#DFDFDF", color = "#656565") +
  geom_sf(data = eu_countries, fill = "#FDFBEA", color = "#656565") +
  geom_sf(data = ccaa, fill = "#C12838", color = "grey80", lwd = .1) +
  # Center in Europe: EPSG 3035
  coord_sf(
    xlim = c(2377294, 7453440),
    ylim = c(1313597, 5628510)
  ) +
  theme(
    panel.background = element_blank(),
    panel.grid = element_line(
      colour = "#DFDFDF",
      linetype = "dotted"
    )
  )
```

<img src="https://raw.githubusercontent.com/ropenspain/mapSpain/main/img/README-giscoR-1.png" width="100%" />

## A note on caching

Some data sets and tiles may have a size larger than 50MB. You can use
**mapSpain** to create your own local repository at a given local
directory passing the following option:

``` r
esp_set_cache_dir("./path/to/location")
```

When this option is set, **mapSpain** would look for the cached file and
it will load it, speeding up the process.

## Plotting `sf` objects

Some packages recommended for visualization are:

  - [**tmap**](https://github.com/r-tmap/tmap)
  - [**mapsf**](https://riatelab.github.io/mapsf/)
  - [**ggplot2**](https://github.com/tidyverse/ggplot2) +
    [**ggspatial**](https://github.com/paleolimbot/ggspatial)
  - [**leaflet**](https://rstudio.github.io/leaflet/)

## Citation

To cite the ‘mapSpain’ package in publications use:

Hernangómez D (2021). *mapSpain: Administrative Boundaries of Spain*.
doi: 10.5281/zenodo.5366622 (URL:
<https://doi.org/10.5281/zenodo.5366622>), \<URL:
<https://ropenspain.github.io/mapSpain/>\>.

A BibTeX entry for LaTeX users is:

    #> @Manual{,
    #>   title = {mapSpain: Administrative Boundaries of Spain},
    #>   year = {2021},
    #>   version = {0.4.0},
    #>   author = {Diego Hernangómez},
    #>   doi = {10.5281/zenodo.5366622},
    #>   url = {https://ropenspain.github.io/mapSpain/},
    #>   abstract = {Administrative Boundaries of Spain at several levels
    #>     (Autonomous Communities, Provinces, Municipalities) based on the
    #>     'GISCO' 'Eurostat' database <https://ec.europa.eu/eurostat/web/gisco>
    #>     and 'CartoBase SIANE' from 'Instituto Geografico Nacional'
    #>     <https://www.ign.es/>.  It also provides a 'leaflet' plugin and the
    #>     ability of downloading and processing static tiles.},
    #> }

## Contribute

Check the GitHub page for [source
code](https://github.com/ropenspain/mapSpain/).

## Copyright notice

This package uses data from CartoBase SIANE, provided by Instituto
Geográfico Nacional:

> Atlas Nacional de España (ANE) [CC BY
> 4.0](https://creativecommons.org/licenses/by/4.0/deed.en)
> [ign.es](https://www.ign.es/)

See <https://github.com/rOpenSpain/mapSpain/tree/sianedata>

This package uses data from **GISCO**. GISCO
[(FAQ)](https://ec.europa.eu/eurostat/web/gisco/faq) is a geospatial
open data repository including several data sets at several resolution
levels.

*From GISCO \> Geodata \> Reference data \> Administrative Units /
Statistical Units*

> When data downloaded from this page is used in any printed or
> electronic publication, in addition to any other provisions applicable
> to the whole Eurostat website, data source will have to be
> acknowledged in the legend of the map and in the introductory page of
> the publication with the following copyright notice:
> 
> EN: © EuroGeographics for the administrative boundaries
> 
> FR: © EuroGeographics pour les limites administratives
> 
> DE: © EuroGeographics bezüglich der Verwaltungsgrenzen
> 
> For publications in languages other than English, French or German,
> the translation of the copyright notice in the language of the
> publication shall be used.

If you intend to use the data commercially, please contact
EuroGeographics for information regarding their license agreements.
