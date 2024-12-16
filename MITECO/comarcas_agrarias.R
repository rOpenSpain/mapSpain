# Extrae comarcas agrarias
# https://www.mapa.gob.es/es/cartografia-y-sig/ide/descargas/agricultura/default.aspx

library(sf)
library(tidyverse)

cag <- read_sf("MITECO/source/ComarcasAgrarias.shp") %>%
  st_transform(4258) %>%
  mutate(name = DS_COMARCA)

df_codes <- esp_codelist %>%
  select(
    cpro, codauto,
    ine.ccaa.name, ine.prov.name
  ) %>%
  distinct_all()


cag_end <- cag %>%
  mutate(cpro = str_pad(CO_PROVINC, width = 2, pad = "0")) %>%
  left_join(df_codes) %>%
  st_make_valid()


library(leaflet)

cag_end %>%
  leaflet() %>%
  addTiles() %>%
  addPolygons()

unlink("MITECO/dist/comarcas_agrarias.gpkg")
write_sf(cag_end, "MITECO/dist/comarcas_agrarias.gpkg")

