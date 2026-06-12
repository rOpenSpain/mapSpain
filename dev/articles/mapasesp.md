# mapSpain: maps of Spain in R

## Welcome to mapSpain

### Motivation

**mapSpain** helps you create maps for the main administrative levels of
Spain. It also supports static map tiles from WMS and WMTS services,
either as georeferenced rasters or as dynamic layers in leaflet maps.

The package also includes helpers to translate and convert Autonomous
Community and province names and codes. These helpers make it easier to
join, clean and transform data, whether or not the data is spatial.

The main data sources used by **mapSpain** are:

- [GISCO](https://ec.europa.eu/eurostat/web/gisco) (Eurostat), through
  the [**giscoR**](https://ropengov.github.io/giscoR/) package.
- [Instituto Geográfico Nacional](https://www.ign.es/) (IGN).
- Spanish public institutions that publish WMTS and WMS tile services
  (<https://www.idee.es/web/idee/segun-tipo-de-servicio>).

Most functions return `sf` objects from the **sf** package or
`SpatRaster` objects from the **terra** package.

Package website: <https://ropenspain.github.io/mapSpain/>.

### Installation

#### CRAN

``` r

install.packages("mapSpain", dependencies = TRUE)
```

#### Development version

Use [r-universe](https://ropenspain.r-universe.dev/ui#builds):

``` r

# Enable this universe.
install.packages(
  "mapSpain",
  repos = c(
    "https://ropenspain.r-universe.dev",
    "https://cloud.r-project.org"
  ),
  dependencies = TRUE
)
```

#### Installation with pak from GitHub

``` r

install.packages("pak")
pak::pak("rOpenSpain/mapSpain", dependencies = TRUE)
```

### A quick example

``` r

library(mapSpain)
library(tidyverse)

galicia <- esp_get_munic_siane(region = "Galicia") |>
  # Standardize labels.
  mutate(Provincia = esp_dict_translate(ine.prov.name, "es"))

ggplot(galicia) +
  geom_sf(aes(fill = Provincia), color = "grey70") +
  labs(title = "Provinces of Galicia") +
  scale_fill_discrete(type = hcl.colors(4, "Blues")) +
  theme_bw()
```

![](mapasesp_files/figure-html/fig-intro-1.png)

Figure 1: Municipalities of Galicia

You can also inspect the dataset interactively:

``` r

library(reactable)

reactable(
  galicia,
  searchable = TRUE,
  striped = TRUE,
  filterable = TRUE,
  height = 350,
  elementId = "munis-galicia"
)
```

### Comparing mapSpain with other alternatives

The next example compares **mapSpain** with other packages that provide
`sf` or `SpatVector` objects for country boundaries.

``` r

library(sf) # Spatial data manipulation.

# rnaturalearth
library(rnaturalearth)
esp_rnat <- ne_countries("large", country = "Spain", returnclass = "sf") |>
  st_transform(3857)

# mapSpain.
esp_mapspain <- esp_get_spain(epsg = 4326) |>
  st_transform(3857)

# geodata (GADM)
library(geodata)
esp_geodata <- geodata::gadm("ES",
  path = ".", level = 0
) |>
  # Convert from SpatVector to an sf object.
  sf::st_as_sf() |>
  st_transform(3857)

# geobounds
library(geobounds)
esp_geobounds <- geobounds::gb_get_adm0("ESP",
  cache_dir = "."
) |>
  st_transform(3857)

# Orthophoto of the Ferrol estuary.
tile <- esp_get_munic_siane(munic = "Ferrol", epsg = 3857) |>
  esp_get_tiles("PNOA", bbox_expand = 0.5, zoommin = 1)

# Prepare the plot.
library(tidyterra)

esp_all <- bind_rows(esp_rnat, esp_mapspain, esp_geodata, esp_geobounds)

esp_all$source <- as_factor(c(
  "rnaturalearth",
  "mapSpain",
  "geodata (GADM)",
  "geoBoundaries"
))

ggplot(esp_all) +
  geom_spatraster_rgb(data = tile, maxcell = Inf, alpha = 0.5) +
  geom_sf(
    aes(color = source, linetype = source),
    fill = NA,
    show.legend = "line",
    linewidth = 0.5,
    alpha = 0.7
  ) +
  coord_sf(
    crs = 4326,
    xlim = c(-8.384421, -8.154413),
    ylim = c(43.43201, 43.59545),
    expand = FALSE
  ) +
  scale_color_manual(values = c("red", "black", "blue", "orange")) +
  scale_linetype_manual(values = c("solid", "dotted", "dashed", "twodash")) +
  theme_void() +
  labs(title = "Ferrol estuary")
```

![](mapasesp_files/figure-html/fig-compara-1.png)

Figure 2: Comparison of boundary resolution across map sources. The
boundaries are shown over an orthophoto of the Ferrol estuary.

- **rnaturalearth**: lower boundary precision.
- **mapSpain**: good boundary precision for this use case.
- **GADM** (through **geodata**): very high boundary precision.
- **geoBoundaries** (through **geobounds**): good boundary precision for
  this use case.

### Caching

**mapSpain** uses web resources. By default, downloaded files are stored
in [`tempdir()`](https://rdrr.io/r/base/tempfile.html) for reuse during
the current session.

Use
[`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_set_cache_dir.md)
to choose a user-specific download directory. Add `install = TRUE` to
make that cache configuration persistent across sessions.

``` r

esp_set_cache_dir("~/R/mapslib/mapSpain", install = TRUE, verbose = TRUE)

#> ℹ mapSpain cache directory is C:/Users/XXXX/Documents/R/mapslib/mapSpain.

munic <- esp_get_munic_siane(verbose = TRUE)

#> ℹ Cache directory is C:/Users/XXXX/Documents/R/mapslib/mapSpain/siane.
#> ✔ File already cached: C:/Users/XXXX/Documents/R/mapslib/mapSpain/siane/se89_3_admin_muni_a_x.gpkg.
#> ℹ Cache directory is C:/Users/diego/Documents/R/mapslib/GISCO/siane.
#> ✔ File already cached: C:/Users/XXXX/Documents/R/mapslib/mapSpain/siane/se89_3_admin_muni_a_y.gpkg
```

## Dictionary

### Functions for working with text

**mapSpain** provides two related functions for working with names and
codes:

- [`esp_dict_region_code()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_dict.md)
  converts text labels into Autonomous Community and province codes.
  Supported coding standards are ISO2, NUTS and INE codes (`codauto` and
  `cpro`).
- [`esp_dict_translate()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_dict.md)
  translates text into Spanish, English, Catalan, Galician or Basque.

These functions are also useful outside spatial workflows, for example
when you need to standardize Autonomous Community and province codes in
ISCIII COVID data.

#### `esp_dict_region_code()`

``` r

vals <- c("Errioxa", "Coruna", "Gerona", "Madrid")

esp_dict_region_code(vals, destination = "nuts")
#> [1] "ES23"  "ES111" "ES512" "ES30"
esp_dict_region_code(vals, destination = "cpro")
#> [1] "26" "15" "17" "28"
esp_dict_region_code(vals, destination = "iso2")
#> [1] "ES-RI" "ES-C"  "ES-GI" "ES-MD"

# Convert from ISO2 to other codes.

iso2vals <- c("ES-M", "ES-S", "ES-SG")
esp_dict_region_code(iso2vals, origin = "iso2")
#> [1] "Madrid"    "Cantabria" "Segovia"

iso2vals <- c("ES-GA", "ES-CT", "ES-PV")

esp_dict_region_code(iso2vals, origin = "iso2", destination = "nuts")
#> [1] "ES11" "ES51" "ES21"

# Support mixed levels.
valsmix <- c("Centro", "Andalucia", "Seville", "Menorca")
esp_dict_region_code(valsmix, destination = "nuts")
#> [1] "ES4"   "ES61"  "ES618" "ES533"

esp_dict_region_code(c("Murcia", "Las Palmas", "Aragón"), destination = "iso2")
#> [1] "ES-MC" "ES-GC" "ES-AR"
```

#### `esp_dict_translate()`

``` r

vals <- c("La Rioja", "Sevilla", "Madrid", "Jaen", "Orense", "Baleares")

esp_dict_translate(vals, lang = "en")
#> [1] "La Rioja"         "Seville"          "Madrid"           "Jaén"            
#> [5] "Ourense"          "Balearic Islands"
esp_dict_translate(vals, lang = "es")
#> [1] "La Rioja" "Sevilla"  "Madrid"   "Jaén"     "Orense"   "Baleares"
esp_dict_translate(vals, lang = "ca")
#> [1] "La Rioja"      "Sevilla"       "Madrid"        "Jaén"         
#> [5] "Ourense"       "Illes Balears"

esp_dict_translate(vals, lang = "eu")
#> [1] "Errioxa"         "Sevilla"         "Madril"          "Jaén"           
#> [5] "Ourense"         "Balear Uharteak"
esp_dict_translate(vals, lang = "ga")
#> [1] "A Rioxa"        "Sevilla"        "Madrid"         "Xaén"          
#> [5] "Ourense"        "Illas Baleares"
```

## Political boundaries

**mapSpain** includes functions to retrieve political boundaries at
several levels:

- Whole country.
- [NUTS](https://ec.europa.eu/eurostat/web/nuts/background) (Eurostat).
  Eurostat statistical classification, with levels 0 (country), 1, 2
  (Autonomous Communities) and 3.
- Autonomous Communities.
- Provinces.
- Municipalities.

For Autonomous Communities, provinces and municipalities, there are two
families of functions: `esp_get_xxxx()` for GISCO data and
`esp_get_xxxx_siane()` for IGN data.

The information is available in different projections and resolution
levels.

``` r

esp <- esp_get_spain_siane(moveCAN = FALSE)

ggplot(esp) +
  geom_sf(fill = "#f9cd94") +
  theme_light()
```

![](mapasesp_files/figure-html/fig-pais-1.png)

Figure 3: Map of Spain

### Displacing the Canary Islands

By default, most **mapSpain** functions move the Canary Islands closer
to the mainland to improve visualization. Disable this behavior with
`moveCAN = FALSE` when you need geometries in their original position.

The package also provides helpers for drawing boxes around the inset
map. See the
[examples](https://ropenspain.github.io/mapSpain/reference/esp_get_can_box.html#examples)
in the reference page.

``` r

esp_can <- esp_get_spain()
can_prov <- esp_get_can_provinces()
can_box <- esp_get_can_box()

ggplot(esp_can) +
  geom_sf() +
  geom_sf(data = can_prov) +
  geom_sf(data = can_box)
```

![](mapasesp_files/figure-html/fig-can-1.png)

Figure 4: Map of Spain with displaced Canary Islands

**Use `moveCAN = FALSE` when working with static map tiles, interactive
maps or spatial analysis.**

### NUTS

``` r

nuts1 <- esp_get_nuts(resolution = 60, epsg = 3035, nuts_level = 1)

ggplot(nuts1) +
  geom_sf() +
  labs(title = "NUTS1: low resolution")
```

![](mapasesp_files/figure-html/fig-nuts-1.png)

Figure 5: NUTS 1 regions of Spain

``` r

# Balearic Islands NUTS3.
nuts3_baleares <- c("ES531", "ES532", "ES533")
paste(esp_dict_region_code(nuts3_baleares, "nuts"), collapse = ", ")
#> [1] "Eivissa y Formentera, Mallorca, Menorca"

nuts3_sf <- esp_get_nuts(region = nuts3_baleares, resolution = 1)

ggplot(nuts3_sf) +
  geom_sf(aes(fill = NAME_LATN)) +
  labs(fill = "Balearic Islands: NUTS3") +
  scale_fill_viridis_d() +
  theme_minimal()
```

![](mapasesp_files/figure-html/fig-nuts3-1.png)

Figure 6: NUTS 3 regions of Spain

### Autonomous Communities

``` r

ccaa <- esp_get_ccaa(
  ccaa = c(
    "Catalunya",
    "Comunidad Valenciana",
    "Aragón",
    "Baleares"
  ),
  resolution = 3
)

ccaa <- ccaa |>
  mutate(ccaa_cat = esp_dict_translate(ine.ccaa.name, "ca"))

ggplot(ccaa) +
  geom_sf(aes(fill = ccaa_cat)) +
  labs(fill = "Autonomous Communities") +
  theme_minimal() +
  scale_fill_discrete(type = hcl.colors(4, "Plasma"))
```

![](mapasesp_files/figure-html/fig-ccaa-1.png)

Figure 7: Autonomous Communities of Spain

### Provinces from SIANE

Passing a higher-level entity, such as Andalusia, returns all provinces
within that entity.

``` r

provs <- esp_get_prov_siane(c(
  "Andalucía",
  "Ciudad Real",
  "Murcia",
  "Ceuta",
  "Melilla"
))

ggplot(provs) +
  geom_sf(aes(fill = prov.shortname.es), alpha = 0.9) +
  scale_fill_discrete(type = hcl.colors(12, "Cividis")) +
  theme_minimal() +
  labs(fill = "Provinces")
```

![](mapasesp_files/figure-html/fig-prov-1.png)

Figure 8: Extracting multiple provinces through Autonomous Communities

### Municipalities

``` r

munic <- esp_get_munic_siane(region = "Segovia") |>
  # Example data: INE population.
  left_join(
    mapSpain::pobmun25 |>
      select(-name),
    by = c("cpro", "cmun")
  )

ggplot(munic) +
  geom_sf(aes(fill = pob25), alpha = 0.9, color = NA) +
  scale_fill_gradientn(
    colors = hcl.colors(100, "Inferno"),
    n.breaks = 10,
    labels = scales::label_comma(),
    guide = guide_legend()
  ) +
  labs(
    fill = "Population",
    title = "Population in Segovia",
    subtitle = "INE data (2025)"
  ) +
  theme_void() +
  theme(
    plot.background = element_rect("grey80"),
    text = element_text(face = "bold"),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )
```

![](mapasesp_files/figure-html/fig-munic-1.png)

Figure 9: Extracting municipalities

### Grid maps

Grid maps are available as squares and hexagons for provinces and
Autonomous Communities.

``` r

cuad <- esp_get_hex_ccaa()
hex <- esp_get_grid_prov()

ggplot(cuad) +
  geom_sf() +
  geom_sf_text(aes(label = iso2.ccaa.code)) +
  theme_void()

ggplot(hex) +
  geom_sf() +
  geom_sf_text(aes(label = iso2.prov.code)) +
  theme_void()
```

![](mapasesp_files/figure-html/fig-hex-1.png)

\(a\) Squares

![](mapasesp_files/figure-html/fig-hex-2.png)

\(b\) Hexagons

Figure 10: Grid maps with mapSpain

## Static map tiles and imagery

**mapSpain** can also use static map tiles, such as satellite imagery,
basemaps and roads, provided by different public institutions
(<https://www.idee.es/web/idee/segun-tipo-de-servicio>).

These tiles can be used to create static maps, as 3- or 4-band raster
layers, or as backgrounds for dynamic maps through the **leaflet**
package.

The providers are taken from the **leaflet**
[leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
plugin.

### Creating maps with static map tiles

Several options are available for composing maps with static map tiles:

``` r

madrid_munis <- esp_get_munic_siane(region = "Madrid", epsg = 3857)
base_pnoa <- esp_get_tiles(madrid_munis, "PNOA", bbox_expand = 0.1, zoommin = 1)

library(tidyterra)

ggplot() +
  geom_spatraster_rgb(data = base_pnoa) +
  geom_sf(
    data = madrid_munis,
    color = "blue",
    fill = "blue",
    alpha = 0.25,
    linewidth = 0.5
  ) +
  theme_minimal() +
  labs(title = "Municipalities in Madrid")

# Use the `mask` option.
madrid <- esp_get_munic_siane(munic = "^Madrid$", epsg = 3857)

madrid_mask <- esp_get_tiles(
  madrid,
  "IDErioja.Claro",
  mask = TRUE,
  crop = TRUE,
  zoommin = 2
)

ggplot() +
  geom_spatraster_rgb(data = madrid_mask) +
  theme_void() +
  labs(
    title = "Static map tiles of Madrid",
    caption = "CC BY 4.0 www.iderioja.org"
  )
```

![](mapasesp_files/figure-html/fig-imagesestaticos-1.png)

Figure 11: Static map tile extraction

![](mapasesp_files/figure-html/fig-imagesestaticos-2.png)

Figure 12: Static map tiles with a mask

### Dynamic maps with leaflet

Static map tiles can be used as backgrounds in static and interactive
maps.

``` r

stations <- esp_get_railway(spatialtype = "point", epsg = 4326)

library(leaflet)
# Create an icon.

iconurl <- "https://ropenspain.github.io/mapSpain/icons/train.png"

train_icon <- makeIcon(iconurl, iconurl, 18, 18)

leaflet(stations, elementId = "railway", width = "100%", height = "60vh") |>
  addProviderEspTiles("IDErioja.Claro", group = "Base") |>
  addProviderEspTiles("MTN", group = "MTN") |>
  addProviderEspTiles("RedTransporte.Carreteras", group = "Roads") |>
  addProviderEspTiles(
    "RedTransporte.Ferroviario",
    group = "Railway lines"
  ) |>
  addMarkers(
    icon = train_icon,
    group = "Stations",
    popup = sprintf(
      "<strong>%s</strong>",
      stations$rotulo
    ) |>
      lapply(htmltools::HTML)
  ) |>
  addLayersControl(
    baseGroups = c("Base", "MTN"),
    overlayGroups = c("Stations", "Railway lines", "Roads"),
    options = layersControlOptions(collapsed = FALSE)
  ) |>
  hideGroup(c("Railway lines", "Roads"))
```

## Other resources

**mapSpain** includes additional
[functions](https://ropenspain.github.io/mapSpain/reference/index.html#section-natural)
for retrieving elevation, rivers and river basin data for Spain, as well
as Spanish [transport
infrastructure](https://ropenspain.github.io/mapSpain/reference/index.html#section-transport-infrastructure)
lines and points, such as roads and railway lines.
