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

simp_file <- shp[grep("spain_provinces_img_ag_2.shp", shp)]


prov_simp <- st_read(simp_file)

prov_simp <- prov_simp %>%
  mutate(
    cpro = PROV,
    cpro = if_else(NOMBRE99 == "Ceuta",
      "51", if_else(NOMBRE99 == "Melilla", "52", cpro)
    )
  )


# Agrupa provs
prov_simp_end <- prov_simp %>%
  select(cpro) %>%
  group_by(cpro) %>%
  summarise(n = n()) %>%
  select(-n)


df_codes <- esp_codelist %>%
  select(
    cpro, codauto,
    ine.ccaa.name, ine.prov.name
  ) %>%
  distinct_all()

prov_simp_end <- prov_simp_end %>%
  left_join(df_codes) %>%
  st_make_valid()

ggplot(prov_simp_end) +
  geom_sf(fill = "red") +
  geom_sf_text(aes(label = ine.prov.name))


st_write(prov_simp_end, "./INE/ine_prov_simplified.gpkg", append = FALSE)


# CCAAs

simp_file <- shp[grep("spain_regions_img_ag.shp", shp)]


ccaa_simp <- st_read(simp_file)
plot(ccaa_simp$geometry)

ccaa_simp$codauto <- gsub("CA", "", ccaa_simp$COM)

ccaa_simp_end <- ccaa_simp %>%
  mutate(codauto = if_else(NOMBRE == "Ceuta",
    "18", if_else(NOMBRE == "Melilla", "19", codauto)
  )) %>%
  select(codauto) %>%
  group_by(codauto) %>%
  summarise(n = n()) %>%
  select(-n) %>%
  left_join(df_codes %>% select(codauto, ine.ccaa.name) %>% distinct()) %>%
  st_make_valid()


ggplot(ccaa_simp_end) +
  geom_sf(fill = "red") +
  geom_sf_text(aes(label = ine.ccaa.name), check_overlap = TRUE)

st_write(ccaa_simp_end, "./INE/ine_ccaa_simplified.gpkg", append = FALSE)
