
# mapSpain <img src="man/figures/logo.png" align="right" width="120"/>

<!-- badges: start -->

[![rOS-badge](https://ropenspain.github.io/rostemplate/reference/figures/ropenspain-badge.svg)](https://ropenspain.es/)
[![CRAN-status](https://www.r-pkg.org/badges/version/mapSpain)](https://CRAN.R-project.org/package=mapSpain)
[![CRAN-results](https://badges.cranchecks.info/worst/mapSpain.svg)](https://cran.r-project.org/web/checks/check_results_mapSpain.html)
[![Downloads](https://cranlogs.r-pkg.org/badges/mapSpain)](https://CRAN.R-project.org/package=mapSpain)
[![r-universe](https://ropenspain.r-universe.dev/badges/mapSpain)](https://ropenspain.r-universe.dev/mapSpain)
[![R-CMD-check](https://github.com/rOpenSpain/mapSpain/actions/workflows/check-full.yaml/badge.svg)](https://github.com/rOpenSpain/mapSpain/actions/workflows/check-full.yaml)
[![R-hub](https://github.com/rOpenSpain/mapSpain/actions/workflows/rhub.yaml/badge.svg)](https://github.com/rOpenSpain/mapSpain/actions/workflows/rhub.yaml)
[![codecov](https://codecov.io/gh/rOpenSpain/mapSpain/branch/main/graph/badge.svg?token=6L01BKLL85)](https://app.codecov.io/gh/rOpenSpain/mapSpain)
[![DOI](https://img.shields.io/badge/DOI-10.5281/zenodo.5366622-blue)](https://doi.org/10.5281/zenodo.5366622)
[![Project-Status:Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![status](https://tinyverse.netlify.app/badge/mapSpain)](https://CRAN.R-project.org/package=mapSpain)

<!-- badges: end -->

[**mapSpain**](https://ropenspain.github.io/mapSpain/) is a package that
provides spatial **sf** objects of the administrative boundaries of
Spain, including CCAA, provinces and municipalities.

**mapSpain** also provides a leaflet plugin to be used with the
[**leaflet** package](https://rstudio.github.io/leaflet/), that loads
several base maps of public institutions of Spain, and the ability of
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
[r-universe](https://ropenspain.r-universe.dev/mapSpain):

``` r
# Install mapSpain in R:
install.packages("mapSpain",
  repos = c(
    "https://ropenspain.r-universe.dev",
    "https://cloud.r-project.org"
  ),
  dependencies = TRUE
)
```

Alternatively, you can install the developing version of **mapSpain**
with:

``` r
# install.packages("pak")
pak::pak("rOpenSpain/mapSpain", dependencies = TRUE)
```

## Usage

This script highlights some features of **mapSpain** :

``` r
library(mapSpain)
library(sf)
library(dplyr)
census <- mapSpain::pobmun19

# Extract CCAA from base dataset

codelist <- mapSpain::esp_codelist %>%
  select(cpro, codauto) %>%
  distinct()

census_ccaa <- census %>%
  left_join(codelist) %>%
  # Summarize by CCAA
  group_by(codauto) %>%
  summarise(pob19 = sum(pob19), men = sum(men), women = sum(women)) %>%
  mutate(
    porc_women = women / pob19,
    porc_women_lab = paste0(round(100 * porc_women, 2), "%")
  )


# Merge into spatial data

ccaa_sf <- esp_get_ccaa() %>%
  left_join(census_ccaa)
can <- esp_get_can_box()


# Plot with ggplot
library(ggplot2)


ggplot(ccaa_sf) +
  geom_sf(aes(fill = porc_women), color = "grey70", linewidth = .3) +
  geom_sf(data = can, color = "grey70") +
  geom_sf_label(aes(label = porc_women_lab),
    fill = "white", alpha = 0.5,
    size = 3, label.size = 0
  ) +
  scale_fill_gradientn(
    colors = hcl.colors(10, "Blues", rev = TRUE),
    n.breaks = 10, labels = scales::label_percent(),
    guide = guide_legend(title = "Porc. women", position = "inside")
  ) +
  theme_void() +
  theme(legend.position.inside = c(0.1, 0.6))
```

<img src="https://raw.githubusercontent.com/ropenspain/mapSpain/main/img/README-static-1.png" width="100%" />

You can combine `sf` objects with static tiles

``` r
# Get census
census <- mapSpain::pobmun19 %>%
  mutate(porc_women = women / pob19) %>%
  select(cpro, cmun, porc_women)

# Get shapes
shape <- esp_get_munic_siane(region = "Segovia", epsg = 3857)
provs <- esp_get_prov_siane(epsg = 3857)

shape_pop <- shape %>% left_join(census)


tile <- esp_getTiles(shape_pop, type = "IDErioja.Relieve", zoommin = 1)

# Plot

library(ggplot2)
library(tidyterra)

lims <- as.vector(terra::ext(tile))

ggplot(remove_missing(shape_pop, na.rm = TRUE)) +
  geom_spatraster_rgb(data = tile, maxcell = 10e6) +
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
    caption = "Source: INE, CC BY 4.0 www.iderioja.org"
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

res <- "20"

all_countries <- gisco_get_countries(resolution = res) %>%
  st_transform(3035)

eu_countries <- gisco_get_countries(resolution = res, region = "EU") %>%
  st_transform(3035)

ccaa <- esp_get_ccaa(moveCAN = FALSE, resolution = res) %>%
  st_transform(3035)

library(ggplot2)

ggplot(all_countries) +
  geom_sf(fill = "#DFDFDF", color = "#656565") +
  geom_sf(data = eu_countries, fill = "#FDFBEA", color = "#656565") +
  geom_sf(data = ccaa, fill = "#C12838", color = "grey80", linewidth = .1) +
  # Center in Europe: EPSG 3035
  coord_sf(xlim = c(2377294, 7453440), ylim = c(1313597, 5628510)) +
  theme(
    panel.background = element_blank(),
    panel.grid = element_line(colour = "#DFDFDF", linetype = "dotted")
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
  [**tidyterra**](https://github.com/dieghernan/tidyterra).
- [**leaflet**](https://rstudio.github.io/leaflet/)

## Citation

<p>
Hernangómez D (2025). <em>mapSpain: Administrative Boundaries of
Spain</em>.
<a href="https://doi.org/10.5281/zenodo.5366622">doi:10.5281/zenodo.5366622</a>,
<a href="https://ropenspain.github.io/mapSpain/">https://ropenspain.github.io/mapSpain/</a>.
</p>

A BibTeX entry for LaTeX users is:

    @Manual{R-mapspain,
      title = {{mapSpain}: Administrative Boundaries of Spain},
      year = {2025},
      version = {0.10.0},
      author = {Diego Hernangómez},
      doi = {10.5281/zenodo.5366622},
      url = {https://ropenspain.github.io/mapSpain/},
      abstract = {Administrative Boundaries of Spain at several levels (Autonomous Communities, Provinces, Municipalities) based on the GISCO Eurostat database <https://ec.europa.eu/eurostat/web/gisco> and CartoBase SIANE from Instituto Geografico Nacional <https://www.ign.es/>. It also provides a leaflet plugin and the ability of downloading and processing static tiles.},
    }

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
[(FAQ)](https://ec.europa.eu/eurostat/web/gisco) is a geospatial open
data repository including several data sets at several resolution
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

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

All contributions to this project are gratefully acknowledged using the
[`allcontributors` package](https://github.com/ropensci/allcontributors)
following the [allcontributors](https://allcontributors.org)
specification. Contributions of any kind are welcome!

### Code

<table class="table allctb-table">
<tr>
<td align="center">
<a href="https://github.com/dieghernan">
<img src="https://avatars.githubusercontent.com/u/25656809?v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/commits?author=dieghernan">dieghernan</a>
</td>
</tr>
</table>

### Issue Authors

<table class="table allctb-table">
<tr>
<td align="center">
<a href="https://github.com/pedrotercero3">
<img src="https://avatars.githubusercontent.com/u/90156958?v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+author%3Apedrotercero3">pedrotercero3</a>
</td>
<td align="center">
<a href="https://github.com/ajcanepa">
<img src="https://avatars.githubusercontent.com/u/10628672?u=f474ccb4da200b642706382fa2a7e946454af9ab&v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+author%3Aajcanepa">ajcanepa</a>
</td>
<td align="center">
<a href="https://github.com/fgoerlich">
<img src="https://avatars.githubusercontent.com/u/6486324?u=e04fd58f9dcc4c4e092895594eb70d7b5960b50b&v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+author%3Afgoerlich">fgoerlich</a>
</td>
<td align="center">
<a href="https://github.com/perezcalderon">
<img src="https://avatars.githubusercontent.com/u/8152544?v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+author%3Aperezcalderon">perezcalderon</a>
</td>
<td align="center">
<a href="https://github.com/Cidree">
<img src="https://avatars.githubusercontent.com/u/96820235?u=dce53cf1dedbfbb89dc55bc2472fa2493a2c9281&v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+author%3ACidree">Cidree</a>
</td>
<td align="center">
<a href="https://github.com/catbru">
<img src="https://avatars.githubusercontent.com/u/2419189?u=d8fd560c3e349236450bdd9669f9d2ef1176d8d9&v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+author%3Acatbru">catbru</a>
</td>
<td align="center">
<a href="https://github.com/ana-m-m">
<img src="https://avatars.githubusercontent.com/u/78867570?u=e82579f7b35ca989a167342ad18e5c003980943a&v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+author%3Aana-m-m">ana-m-m</a>
</td>
</tr>
</table>

### Issue Contributors

<table class="table allctb-table">
<tr>
<td align="center">
<a href="https://github.com/mpizarrotig">
<img src="https://avatars.githubusercontent.com/u/18368413?u=a85f35a53cf336f532b6e939b68ebf430669d2f5&v=4" width="100px;" class="allctb-avatar" alt=""/>
</a><br>
<a href="https://github.com/rOpenSpain/mapSpain/issues?q=is%3Aissue+commenter%3Ampizarrotig">mpizarrotig</a>
</td>
</tr>
</table>
<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
