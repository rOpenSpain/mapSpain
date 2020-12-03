# Create grid sequentially
rm(list = ls())
library(geogrid)
library(sf)
library(mapSpain)
library(cartography)
library(dplyr)





# CCAA - Hex----
CCAA <- st_transform(esp_get_ccaa(), 3857)
PENIN <- CCAA[!CCAA$iso2.ccaa.code %in%
                c("ES-CN", "ES-CE", "ES-ML", "ES-IB")
              , ]

REST <- CCAA[CCAA$iso2.ccaa.code %in%
               c("ES-CN", "ES-CE", "ES-ML", "ES-IB")
             , ]

# Grid for penin
cells <- calculate_grid(PENIN,
                        grid_type = "hexagonal",
                        seed = 100,
                        learning_rate = 0.5)

PENINNEW <- assign_polygons(PENIN, cells)
PENINNEW  <- st_transform(PENINNEW, 3857)

plot(st_geometry(PENINNEW))
labelLayer(PENINNEW, txt = "iso2.ccaa.code")

plot(st_geometry(CCAA), add = TRUE)

# Now create an expanded grid aligned with the original

marea <- as.double(st_area(PENINNEW[1,]))
marea <- sqrt((2 * marea) / sqrt(3))

bbox <- st_bbox(CCAA)
maxdist <- max(bbox[3] - bbox[1], bbox[4] - bbox[1]) * 0.05


grid <-
  st_make_grid(
    st_as_sfc(bbox + c(-maxdist, -maxdist, maxdist, maxdist)),
    crs = st_crs(3857),
    cellsize = marea,
    square = FALSE
  )

grid <- st_sf(id = 1:length(grid), geometry = grid)


plot(st_geometry(grid))
plot(st_geometry(PENINNEW), add = TRUE, col = "red")
labelLayer(grid, txt = "id")

# Align visually Galicia

init <-
  grid %>% filter(id == 39) %>% st_centroid() %>% st_coordinates()

end <-
  PENINNEW %>% filter(iso2.ccaa.code == "ES-GA") %>% st_centroid() %>% st_coordinates()

offset <- c(init[1] - end[1], end[2] - init[2])

newgrid <- sf::st_sf(
  sf::st_drop_geometry(grid),
  geometry = sf::st_geometry(grid) - offset,
  crs = sf::st_crs(grid)
) %>% st_transform(3857)

plot(st_geometry(newgrid))
plot(st_geometry(PENINNEW), add = TRUE, col = "red")
plot(st_geometry(REST), col = "blue", add = TRUE)
labelLayer(newgrid, txt = "id")

df <-
  data.frame(
    iso2.ccaa.code = c("ES-CN", "ES-CE", "ES-ML", "ES-IB"),
    id = c(22, 46, 56, 83)
  )

finalgrid <- newgrid %>% inner_join(df) %>% select(iso2.ccaa.code)

CCAA_END <- rbind(PENINNEW[, "iso2.ccaa.code"],
                  finalgrid)


plot(st_geometry(CCAA_END))

finaldf <- st_drop_geometry(CCAA)

esp_hexbin_ccaa <- merge(CCAA_END, finaldf)

esp_hexbin_ccaa$label <-
  gsub("ES-", "", esp_hexbin_ccaa$iso2.ccaa.code, fixed = TRUE)

newnames <- c("label", names(finaldf))
esp_hexbin_ccaa <- esp_hexbin_ccaa[, newnames]

esp_hexbin_ccaa <- st_transform(esp_hexbin_ccaa, 4258)
esp_hexbin_ccaa <- st_make_valid(esp_hexbin_ccaa)

rm(list = ls()[!(ls() %in% c(
  "esp_grid_ccaa",
  "esp_grid_prov",
  "esp_hexbin_ccaa",
  "esp_hexbin_prov"
))])

plot(st_geometry(esp_hexbin_ccaa))
labelLayer(esp_hexbin_ccaa, txt = "label")


# Provs - Hex-----

PROV <- st_transform(esp_get_prov(), 3857)

ncod <-
  esp_dict_region_code(c("Canarias", "Ceuta", "Melilla", "Baleares"), destination = "codauto")

PENIN <- PROV[!PROV$codauto %in%
                ncod
              , ]

REST <- PROV[PROV$codauto %in%
               ncod
             , ]

cells <- calculate_grid(PENIN,
                        grid_type = "hexagonal",
                        seed = 50,
                        learning_rate = 0.2)

PENINNEW <-
  assign_polygons(PENIN, cells) %>% st_transform(3857) %>% select(cpro)


PENINNEW <- assign_polygons(PENIN, cells)
PENINNEW  <- st_transform(PENINNEW, 3857)

plot(st_geometry(PENINNEW))
labelLayer(PENINNEW, txt = "iso2.prov.code")
plot(st_geometry(PROV), add = TRUE)


# Now create an expanded grid aligned with the original

marea <- as.double(st_area(PENINNEW[1,]))
marea <- sqrt((2 * marea) / sqrt(3))

bbox <- st_bbox(PENIN)
maxdist <- max(bbox[3] - bbox[1], bbox[4] - bbox[1]) * 0.05


grid <-
  st_make_grid(
    st_as_sfc(bbox + c(-maxdist, -maxdist, maxdist, maxdist)),
    crs = st_crs(3857),
    cellsize = marea,
    square = FALSE
  )

grid <- st_sf(id = 1:length(grid), geometry = grid)

plot(st_geometry(grid))
plot(st_geometry(PENINNEW), add = TRUE, col = "red")
labelLayer(grid, txt = "id")

# Align visually Galicia

init <-
  grid %>% filter(id == 46) %>% st_centroid() %>% st_coordinates()

end <-
  PENINNEW %>% filter(iso2.prov.code == "ES-C") %>% st_centroid() %>% st_coordinates()

offset <- c(init[1] - end[1], end[2] - init[2])

newgrid <- sf::st_sf(
  sf::st_drop_geometry(grid),
  geometry = sf::st_geometry(grid) - offset,
  crs = sf::st_crs(grid)
) %>% st_transform(3857)



plot(st_geometry(newgrid))
plot(st_geometry(PENINNEW), add = TRUE, col = "red")
plot(st_geometry(REST), col = "blue", add = TRUE)
labelLayer(newgrid, txt = "id")

df <- data.frame(
  id = c(2, 34, 82, 114, 188),
  cpro = esp_dict_region_code(
    c(
      "Santa Cruz de Tenerife",
      "Las Palmas",
      "Ceuta",
      "Melilla",
      "Islas Baleares"
    ),
    destination = "cpro"
  ),
  stringsAsFactors = FALSE
)

REST <- newgrid %>% inner_join(df) %>% select(cpro)

PROVNEW <- rbind(PENINNEW[, "cpro"], REST)

# Create df

finaldf <- st_drop_geometry(PROV)

final <- merge(PROVNEW, finaldf)

final$label <- gsub("ES-", "", final$iso2.prov.code, fixed = TRUE)

newnames <- c("label", names(finaldf))

final <- final[, newnames]

final <- st_make_valid(final)
final <- st_transform(final, 4258)

esp_hexbin_prov <- st_make_valid(final)

rm(list = ls()[!(ls() %in% c(
  "esp_grid_ccaa",
  "esp_grid_prov",
  "esp_hexbin_ccaa",
  "esp_hexbin_prov"
))])

plot(st_geometry(esp_hexbin_prov))
typoLayer(esp_hexbin_prov, var = "codauto")
labelLayer(esp_hexbin_prov, txt = "label")



# CCAA Squares----
CCAA <- st_transform(esp_get_ccaa(), 3857)
PENIN <- CCAA[!CCAA$iso2.ccaa.code %in%
                c("ES-CN", "ES-CE", "ES-ML", "ES-IB")
              , ]

REST <- CCAA[CCAA$iso2.ccaa.code %in%
               c("ES-CN", "ES-CE", "ES-ML", "ES-IB")
             , ]
cells <- calculate_grid(PENIN,
                        grid_type = "regular",
                        seed = 59,
                        learning_rate = 0.5)

#3 4 15 10 59
PENINNEW <- assign_polygons(PENIN, cells)

PENINNEW <- st_transform(PENINNEW, 3857)


plot(st_geometry(PENINNEW))

marea <- as.double(st_area(PENINNEW[1,]))

bbox <- st_bbox(CCAA)
maxdist <- max(bbox[3] - bbox[1], bbox[4] - bbox[1]) * 0.05


grid <-
  st_make_grid(
    st_as_sfc(bbox + c(-maxdist, -maxdist, maxdist, maxdist)),
    crs = st_crs(3857),
    cellsize = sqrt(marea),
    square = TRUE
  )

grid <- st_sf(id = 1:length(grid), geometry = grid)


plot(st_geometry(grid))
plot(st_geometry(PENINNEW), add = TRUE, col = "red")
labelLayer(grid, txt = "id")


# Align visually Galicia

init <-
  grid %>% filter(id == 59) %>% st_centroid() %>% st_coordinates()

end <-
  PENINNEW %>% filter(iso2.ccaa.code == "ES-GA") %>% st_centroid() %>% st_coordinates()


offset <- c(init[1] - end[1], init[2] - end[2])

newgrid <- sf::st_sf(
  sf::st_drop_geometry(grid),
  geometry = sf::st_geometry(grid) - offset,
  crs = sf::st_crs(grid)
) %>% st_transform(3857)


plot(st_geometry(newgrid))
plot(st_geometry(PENINNEW), add = TRUE, col = "red")
plot(st_geometry(REST), col = "blue", add = TRUE)
labelLayer(newgrid, txt = "id")



df <-
  data.frame(
    iso2.ccaa.code = c("ES-CN", "ES-CE", "ES-ML", "ES-IB"),
    id = c(14, 5, 6, 43)
  )


finalgrid <- newgrid %>% inner_join(df) %>% select(iso2.ccaa.code)

CCAA_END <- rbind(PENINNEW[, "iso2.ccaa.code"],
                  finalgrid)

plot(st_geometry(CCAA_END))

CCAA_END <- st_make_valid(CCAA_END)
CCAA_END <- st_transform(CCAA_END, 4258)

df <- st_drop_geometry(esp_hexbin_ccaa)

final <- merge(CCAA_END, df)
final <- final[, names(final)]

esp_grid_ccaa <- final


rm(list = ls()[!(ls() %in% c(
  "esp_grid_ccaa",
  "esp_grid_prov",
  "esp_hexbin_ccaa",
  "esp_hexbin_prov"
))])

plot(st_geometry(esp_grid_ccaa))
labelLayer(esp_grid_ccaa, txt = "label")

# Provs Squares----

PROV <- st_transform(esp_get_prov(), 3857)

ncod <-
  esp_dict_region_code(c("Canarias", "Ceuta", "Melilla", "Baleares"), destination = "codauto")

PENIN <- PROV[!PROV$codauto %in%
                ncod
              , ]

REST <- PROV[PROV$codauto %in%
               ncod
             , ]


cells <- calculate_grid(PENIN,
                        grid_type = "regular",
                        seed = 42,
                        learning_rate = 0.5)


PENINNEW <-
  assign_polygons(PENIN, cells) %>% st_transform(3857) %>% select(cpro)


PENINNEW <- assign_polygons(PENIN, cells)
PENINNEW  <- st_transform(PENINNEW, 3857)

plot(st_geometry(PENINNEW))
labelLayer(PENINNEW, txt = "iso2.prov.code")

marea <- as.double(st_area(PENINNEW[1,]))

bbox <- st_bbox(PENIN)
maxdist <- max(bbox[3] - bbox[1], bbox[4] - bbox[1]) * 0.05


grid <-
  st_make_grid(
    st_as_sfc(bbox + c(-maxdist, -maxdist, maxdist, maxdist)),
    crs = st_crs(3857),
    cellsize = sqrt(marea),
    square = TRUE
  )

grid <- st_sf(id = 1:length(grid), geometry = grid)


plot(st_geometry(grid))
plot(st_geometry(PENINNEW), add = TRUE, col = "red")
labelLayer(grid, txt = "id")

init <-
  grid %>% filter(id == 164) %>% st_centroid() %>% st_coordinates()

end <-
  PENINNEW %>% filter(iso2.prov.code == "ES-C") %>% st_centroid() %>% st_coordinates()

offset <- c(init[1] - end[1], init[2] - end[2])

newgrid <- sf::st_sf(
  sf::st_drop_geometry(grid),
  geometry = sf::st_geometry(grid) - offset,
  crs = sf::st_crs(grid)
) %>% st_transform(3857)

par(mar=c(0,0,0,0))
plot(st_geometry(newgrid))
plot(st_geometry(PENINNEW), add=TRUE, col ="red")
labelLayer(newgrid, txt="id")
plot(st_geometry(PROV), add=TRUE)


df <- data.frame(
  id = c(33, 35, 22, 24, 109),
  cpro = esp_dict_region_code(
    c(
      "Santa Cruz de Tenerife",
      "Las Palmas",
      "Ceuta",
      "Melilla",
      "Islas Baleares"
    ),
    destination = "cpro"
  ),
  stringsAsFactors = FALSE
)


finalgrid <- newgrid %>% inner_join(df) %>% select(cpro)

PROV_END <- rbind(PENINNEW[, "cpro"],
                  finalgrid)


plot(st_geometry(PROV_END))

PROV_END <- st_make_valid(PROV_END)
PROV_END <- st_transform(PROV_END, 4258)


df <- st_drop_geometry(esp_hexbin_prov)

final <- merge(PROV_END, df)
final <- final[, names(final)]

esp_grid_prov <- final


rm(list = ls()[!(ls() %in% c(
  "esp_grid_ccaa",
  "esp_grid_prov",
  "esp_hexbin_ccaa",
  "esp_hexbin_prov"
))])


plot(st_geometry(esp_grid_prov))
labelLayer(esp_grid_prov, txt = "label")
plot(st_geometry(esp_get_prov()), add=TRUE)

dev.off()



# Overwrite----

esp_hexbin_ccaa_new <- esp_hexbin_ccaa
esp_hexbin_prov_new <- esp_hexbin_prov
esp_grid_ccaa_new <- esp_grid_ccaa
esp_grid_prov_new <- esp_grid_prov

load("./R/sysdata.rda")

esp_hexbin_ccaa <- esp_hexbin_ccaa_new
esp_hexbin_prov <- esp_hexbin_prov_new
esp_grid_prov <- esp_grid_prov_new
esp_grid_ccaa <- esp_grid_ccaa_new


usethis::use_data(
  code2code,
  dict_ccaa,
  dict_prov,
  names_full,
  names2nuts,
  esp_hexbin_ccaa,
  esp_hexbin_prov,
  esp_grid_ccaa,
  esp_grid_prov,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

tools::checkRdaFiles("./R")

rm(list = ls())




