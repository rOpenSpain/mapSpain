# Comarcas IGN
# https://atlasnacional.ign.es/wane/Organizaci%C3%B3n_territorial_e_institucional_del_Estado

library(dplyr)
library(sf)
library(mapSpain)
library(ggplot2)
library(leaflet)

# Unzip and read
com <- list.files("data-raw/comarcas", ".zip$", full.names = TRUE)

unzip(com[1], exdir = tempdir())
unzip(com[2], exdir = tempdir())
unzip(com[3], exdir = tempdir())

shps <- list.files(tempdir(), pattern = ".shp$", full.names = TRUE)

c1 <- read_sf(shps[1]) %>% st_transform(4258)
c2 <- read_sf(shps[2]) %>% st_transform(4258)
c3 <- read_sf(shps[3]) %>% st_transform(4258)

# Une todo

comarcas <- c1 %>%
  bind_rows(c2, c3) %>%
  st_make_valid() %>%
  mutate(name = g1_s1_txt)


#id de cruce, quitar luego
comarcas$kkid <- seq_len(nrow(comarcas))

leaflet(comarcas) %>%
  addTiles() %>%
  addPolygons()

# Identifica provincia por superficie de overlapping

provs <- mapSpain::esp_get_prov_siane() %>%
  st_transform(3857) %>%
  select(cpro, ine.prov.name)


comarcas2 <- st_intersection(comarcas %>% st_transform(3857) %>%
                               st_buffer(dist = 5),
                             provs %>% st_buffer(dist = 5))

comarcas2$area <- as.integer(st_area(comarcas2) /1000^2)

dt_f <- comarcas2 %>%
  st_drop_geometry() %>%
  group_by(kkid) %>%
  mutate(nprovs = n(),
         maxarea = max(area)) %>%
  arrange(desc(nprovs), kkid, desc(area)) %>%
  filter(area == maxarea) %>%
  select(kkid, cpro)


# Pega
comarcas <- comarcas %>%
  left_join(dt_f) %>%
  select(-kkid)

df_codes <- esp_codelist %>%
  select(
    cpro, codauto,
    ine.ccaa.name, ine.prov.name
  ) %>%
  distinct_all()


comarcas <- comarcas %>%
  left_join(df_codes) %>%
  arrange(codauto, cpro, OBJECTID)

ggplot(comarcas) +
  geom_sf(aes(fill=ine.prov.name))


leaflet(comarcas) %>%
  addProviderEspTiles("IGNBase") %>%
  addPolygons(popup = ~ine.prov.name)

unlink("IGNComarcas/comarcas_ign.gpkg")
st_write(comarcas, "IGNComarcas/comarcas_ign.gpkg")

