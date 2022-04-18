library(dplyr)
library(sf)
library(mapSpain)
library(ggplot2)

tmpzip <- tempfile(fileext = ".zip")

download.file(
  "https://www.ine.es/pcaxis/mapas_completo_municipal.zip",
  tmpzip
)

unzip(tmpzip,
  exdir = tempdir(),
  junkpaths = TRUE
)


shp <- list.files(tempdir(), pattern = ".shp$", full.names = TRUE)

comfile <- shp[grep("esp_com_99.shp", shp)]

# Comarcas
com <- st_read(comfile)

# Guess crs
com <- st_set_crs(com, 25830)
com

# Extract nombres and provs

library(stringr)


com_df <- com %>%
  st_drop_geometry() %>%
  mutate(
    cpro = str_sub(COMARCA99, 1, 2),
    name = trimws(str_remove(COMARCA99, COMAGR))
  )


df_codes <- esp_codelist %>%
  select(
    cpro, codauto,
    ine.ccaa.name, ine.prov.name
  ) %>%
  distinct_all()

com_df <- com_df %>%
  left_join(df_codes) %>%
  select(OBJECTID, name, codauto, ine.ccaa.name, cpro, ine.prov.name)


# Final dataset
final_sf <- com %>%
  left_join(com_df) %>%
  st_make_valid()

final_sf$idorder <- 1:nrow(final_sf)


# Arregla Canarias

nuts3_codes <- esp_codelist %>%
  filter(ine.ccaa.name == "Canarias") %>%
  select(nuts3.code)


nuts3_can <- esp_get_nuts(nuts_level = 3, moveCAN = FALSE) %>%
  filter(NUTS_ID %in% nuts3_codes$nuts3.code) %>%
  st_transform(st_crs(final_sf))


# Municipios de Tenerife
munis_tenef <- esp_get_munic(region = "Canarias", moveCAN = FALSE) %>%
  st_transform(st_crs(final_sf))



munis_tenef <- st_filter(munis_tenef, nuts3_can %>% filter(NUTS_NAME == "Tenerife"))
plot(munis_tenef$geometry)


com_tenef <- final_sf[grep("Tenerife", final_sf$name), ]

# From https://www.ine.es/daco/daco42/agricultura/comarcas99_metodologia.xls

norte <- c(
  "010",
  "015",
  "018",
  "022",
  "025",
  "026",
  "028",
  "031",
  "023",
  "034",
  "039",
  "041",
  "042",
  "043",
  "044",
  "046",
  "051"
)

com_tenef_new <- munis_tenef %>%
  mutate(id = if_else(cmun %in% norte, "248", "249")) %>%
  select(id) %>%
  group_by(id) %>%
  summarise(n = n())

plot(com_tenef_new$geometry)



# Ahora reorganiza el nuevo sf
can_no_tenef <- nuts3_can %>%
  filter(FID != "ES709") %>%
  mutate(id = NUTS_NAME)
st_geometry(can_no_tenef) <- "geometry"
st_geometry(com_tenef_new) <- "geometry"

can_new_com <- bind_rows(can_no_tenef, com_tenef_new) %>%
  select(id)


# Añade ids

com_df %>% filter(ine.ccaa.name == "Canarias")

can_new_com$OBJECTID <- lapply(can_new_com$id, function(x) {
  switch(x,
    "Gran Canaria" = 233,
    "Fuerteventura" = 234,
    "Lanzarote" = 235,
    "248" = 248,
    "249" = 249,
    "La Palma" = 250,
    "La Gomera" = 251,
    "El Hierro" = 252,
    NA
  )
}) %>% unlist()

can_new_com <- can_new_com %>%
  select(OBJECTID) %>%
  left_join(st_drop_geometry(final_sf))



ggplot(can_new_com) +
  geom_sf() +
  geom_sf_text(aes(label = name))


# Une todo al final

final_sf_end <- final_sf %>%
  filter(!OBJECTID %in% can_new_com$OBJECTID) %>%
  bind_rows(can_new_com %>% st_transform(st_crs(final_sf))) %>%
  arrange(idorder) %>%
  select(-idorder) %>%
  st_transform(4326)



final_sf_end <- st_make_valid(final_sf_end)

if (!dir.exists("./INE")) dir.create("./INE")

st_write(final_sf_end, "./INE/esp_com_99.gpkg", append = FALSE)
