# Create square grid:
# See https://github.com/hafen/grid-designer/tree/master/grids
rm(list = ls())


library(mapSpain)
library(sf)

# CCAA ----

mygrid <- data.frame(
  code = c(
    "3",
    "6",
    "12",
    "16",
    "15",
    "7",
    "17",
    "9",
    "2",
    "10",
    "13",
    "11",
    "4",
    "14",
    "8",
    "1",
    "5",
    "18",
    "19"
  ),
  name = c(
    "Asturias",
    "Cantabria",
    "Galicia",
    "País Vasco",
    "Navarra",
    "Castilla y León",
    "La Rioja",
    "Cataluña",
    "Aragón",
    "Comunitat Valenciana",
    "Madrid",
    "Extremadura",
    "Balears",
    "Murcia",
    "Castilla - La Mancha",
    "Andalucía",
    "Canarias",
    "Ceuta",
    "Melilla"
  ),
  row = c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 5, 7, 7, 7),
  col = c(3, 4, 2, 5, 5, 3, 4, 6, 5, 6, 4, 3, 8, 5, 4, 4, 1, 4, 5),
  stringsAsFactors = FALSE
)


#Create grid

ccaa.init <- esp_get_ccaa(epsg = 3857, res = 20)
ccaa.init$area <- as.double(st_area(ccaa.init))
marea <- mean(ccaa.init$area)


expand_bbox <- st_bbox(ccaa.init)
expand <-
  max(expand_bbox[3] - expand_bbox[1], expand_bbox[4] - expand_bbox[2])
expand_bbox <- expand_bbox + expand * c(-0.2,-0.2, 0.2, 0.2)

grid <-
  st_make_grid(st_as_sfc(st_bbox(expand_bbox), crs = st_crs(ccaa.init)), cellsize = sqrt(marea))


plot(st_geometry(grid))
plot(st_geometry(ccaa.init), add = TRUE)

# Number grids
bbox_grid <- st_bbox(grid)

x <- round((bbox_grid[3] - bbox_grid[1]) / sqrt(marea), 0)
y <- length(grid) / x

ncol <- rep(seq_len(x), y)
df <- data.frame(ncol = ncol)

store <- c()
for (i in seq_len(y)) {
  store <- c(store, rep(i, x))
}

df$nrow <- store

grid.df <- st_sf(df, geometry = grid)

grid.df$row <- -1 * (grid.df$nrow - 9)
grid.df$col <- grid.df$ncol - 3
grid.df$lab <- paste0(grid.df$row, ",", grid.df$col)

cartography::labelLayer(grid.df, txt = "lab")

grid.df <- merge(grid.df, mygrid)

plot(st_geometry(grid.df))

# Get df
dfend <- st_drop_geometry(esp_get_hex_ccaa())

nam <- names(dfend)

grid.df$codauto <-
  esp_dict_region_code(grid.df$name, destination = "codauto")

m <- merge(grid.df, dfend)

m$label <- gsub("ES-", "", m$iso2.ccaa.code)

nam2 <- c("label", nam)
m <- m[, nam2]

m <- m[order(m$codauto),]

esp_grid_ccaa <- st_transform(m, 4258)
esp_grid_ccaa <- st_make_valid(esp_grid_ccaa)
all(st_is_valid(esp_grid_ccaa))


#names(esp_get_ccaa()) == names(esp_grid_ccaa)

plot(st_geometry(esp_grid_ccaa))
plot(st_geometry(esp_get_ccaa()), add = TRUE)
rm(list = ls()[which("esp_grid_ccaa" != ls())])



#names(esp_get_ccaa()) == names(esp_grid_ccaa)

# Provinces----


#Create grid

prov.init <- esp_get_prov(epsg = 3857, res = 20)
prov.init$area <- as.double(st_area(prov.init))
marea <- mean(prov.init$area)

expand_bbox <- st_bbox(prov.init)
expand <-
  max(expand_bbox[3] - expand_bbox[1], expand_bbox[4] - expand_bbox[2])
expand_bbox <- expand_bbox + expand * c(-0.2,-0.2, 0.2, 0.2)


grid <-
  st_make_grid(st_as_sfc(st_bbox(expand_bbox), crs = st_crs(prov.init)), cellsize = sqrt(marea))

plot(grid)
plot(st_geometry(prov.init), add = TRUE)


# Number grids
bbox_grid <- st_bbox(grid)

x <- round((bbox_grid[3] - bbox_grid[1]) / sqrt(marea), 0)
y <- length(grid) / x



ncol <- rep(seq_len(x), y)
df <- data.frame(ncol = ncol)



store <- c()
for (i in seq_len(y)) {
  store <- c(store, rep(i, x))
}


df$nrow <- store
grid.df <- st_sf(df, geometry = grid)


grid.df$row <- -1 * (grid.df$nrow - 14)
grid.df$col <- grid.df$ncol - 5
grid.df$lab <- paste0(grid.df$row, ",", grid.df$col)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(grid.df))
cartography::labelLayer(grid.df, txt = "lab")
plot(st_geometry(prov.init), add = TRUE)


mygrid <- data.frame(
  row = c(
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    4,
    4,
    4,
    4,
    4,
    4,
    5,
    5,
    5,
    5,
    5,
    5,
    6,
    6,
    6,
    6,
    6,
    7,
    7,
    7,
    7,
    7,
    8,
    8,
    8,
    10,
    10,
    10,
    10
  ),
  col = c(
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    7,
    10,
    4,
    3,
    5,
    2,
    6,
    8,
    9,
    10,
    7,
    5,
    4,
    6,
    8,
    9,
    7,
    4,
    5,
    8,
    9,
    6,
    12,
    5,
    4,
    7,
    8,
    6,
    7,
    4,
    6,
    8,
    5,
    6,
    4,
    8,
    5,
    7,
    7,
    6,
    5,
    5,
    2,
    1,
    7
  ),
  code = c(
    "15",
    "27",
    "33",
    "39",
    "48",
    "20",
    "31",
    "01",
    "17",
    "24",
    "32",
    "34",
    "36",
    "09",
    "22",
    "25",
    "08",
    "26",
    "47",
    "49",
    "42",
    "50",
    "43",
    "19",
    "37",
    "40",
    "44",
    "12",
    "28",
    "07",
    "05",
    "10",
    "16",
    "46",
    "45",
    "02",
    "06",
    "13",
    "03",
    "14",
    "23",
    "21",
    "30",
    "41",
    "18",
    "04",
    "29",
    "11",
    "51",
    "35",
    "38",
    "52"
  ),
  name = c(
    "Coruña",
    "Lugo",
    "Asturias",
    "Cantabria",
    "Bizkaia",
    "Gipuzkoa",
    "Navarra",
    "Álava",
    "Girona",
    "León",
    "Ourense",
    "Palencia",
    "Pontevedra",
    "Burgos",
    "Huesca",
    "Lleida",
    "Barcelona",
    "La Rioja",
    "Valladolid",
    "Zamora",
    "Soria",
    "Zaragoza",
    "Tarragona",
    "Guadalajara",
    "Salamanca",
    "Segovia",
    "Teruel",
    "Castellón",
    "Madrid",
    "Balears",
    "Ávila",
    "Cáceres",
    "Cuenca",
    "Valencia",
    "Toledo",
    "Albacete",
    "Badajoz",
    "Ciudad Real",
    "Alicante",
    "Córdoba",
    "Jaén",
    "Huelva",
    "Murcia",
    "Sevilla",
    "Granada",
    "Almería",
    "Málaga",
    "Cádiz",
    "Ceuta",
    "Las Palmas",
    "Santa Cruz de Tenerife",
    "Melilla"
  ),
  stringsAsFactors = FALSE
)


final <- merge(grid.df, mygrid)

final$cpro <- esp_dict_region_code(final$name, destination = "cpro")



# Get df

esp <- st_drop_geometry(esp_get_hex_prov())
n <- names(esp)

end <- merge(final, esp)

end$label <- gsub("ES-", "", end$iso2.prov.code)

nam2 <- unique(c("label", n))

end <- end[, nam2]

end <- sf::st_make_valid(end)
end <- st_transform(end, st_crs(4258))
end <- end[order(end$cpro),]


esp_grid_prov <- end

plot(st_geometry(esp_grid_prov))
plot(st_geometry(esp_get_prov()), add = TRUE)



ls()[!(ls() %in% c("esp_grid_ccaa", "esp_grid_prov"))]
"esp_grid_ccaa" != ls()


rm(list = ls()[!(ls() %in% c("esp_grid_ccaa", "esp_grid_prov"))])
# Regenerate hex grids based on the square grids----

# CCAA hex ----

#Create grid

ccaa.init <- esp_get_ccaa(epsg = 3857, res = 20)
ccaa.init$area <- as.double(st_area(ccaa.init))
marea <- mean(ccaa.init$area)


expand_bbox <- st_bbox(ccaa.init)
expand <-
  max(expand_bbox[3] - expand_bbox[1], expand_bbox[4] - expand_bbox[2])
expand_bbox <- expand_bbox + expand * c(-0.2,-0.2, 0.2, 0.2)

marea <- sqrt((2 * marea) / sqrt(3))

grid <-
  st_make_grid(st_as_sfc(st_bbox(expand_bbox), crs = st_crs(ccaa.init)),
               cellsize = marea,
               square = FALSE)
st_area(grid[1])

grid.df <- st_sf(id_hex = seq_len(length(grid)), geometry = grid)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(grid.df))
plot(st_geometry(ccaa.init), add = TRUE)
cartography::labelLayer(grid.df, txt = "id_hex")


ccaa <- data.frame(
  id_hex = c(
    53,
    65,
    77,
    89,
    70,
    82,
    94,
    106,
    76,
    88,
    100,
    69,
    81,
    93,
    75,
    124,
    74,
    86,
    38
  ),
  codauto = c(
    "12",
    "03",
    "06",
    "16",
    '07',
    '17',
    '15',
    '09',
    '13',
    '02',
    '10',
    '11',
    '08',
    '14',
    '01',
    '04',
    '18',
    '19',
    '05'
  )
)

grid.df2 <- merge(grid.df, ccaa)
plot(st_geometry(grid.df2))

df <- st_drop_geometry(esp_grid_ccaa)

nam <- names(df)




dfend <- merge(grid.df2, df)
dfend <- dfend[, nam]
dfend <- st_transform(dfend, st_crs(esp_grid_ccaa))

esp_hexbin_ccaa <- st_make_valid(dfend)

rm(list = ls()[!(ls() %in% c("esp_grid_ccaa", "esp_grid_prov",
                             "esp_hexbin_ccaa"))])


dev.off()



# Hex provinces-----

prov.init <- esp_get_prov(epsg = 3857, res = 20)
prov.init$area <- as.double(st_area(prov.init))
marea <- mean(prov.init$area)

expand_bbox <- st_bbox(prov.init)
expand <-
  max(expand_bbox[3] - expand_bbox[1], expand_bbox[4] - expand_bbox[2])
expand_bbox <- expand_bbox + expand * c(-0.02,-0.02, 0.02, 0.02)

marea <- sqrt((2 * marea) / sqrt(3))

grid <-
  st_make_grid(st_as_sfc(st_bbox(expand_bbox), crs = st_crs(ccaa.init)),
               cellsize = marea,
               square = FALSE)
grid.df <- st_sf(key_hex = seq_len(length(grid)), geometry = grid)

#grid.df <- st_transform(grid.df,4326)

f <- esp_get_hex_prov()
cent <- st_centroid(f, of_largest_polygon = TRUE)
f <- st_set_crs(f, NA)
f <- st_set_crs(f, st_crs(4326))
f <- st_transform(f, 3857)
cent <- st_centroid(f, of_largest_polygon = TRUE)
cent <- cent[,"iso2.prov.code"]
par(mar = c(0, 0, 0, 0))
plot(st_geometry(grid.df))
cartography::labelLayer(grid.df, txt = "key_hex")
plot(st_geometry(prov.init), add = TRUE)
plot(st_geometry(cent), add = TRUE)

join <- st_drop_geometry(st_join(grid.df, cent))
join <- as.data.frame(join)

# Replace CANARIAS
join$key_hex <- ifelse(join$iso2.prov.code == "ES-TF", 21, join$key_hex)
join$key_hex <- ifelse(join$iso2.prov.code == "ES-GC", 47, join$key_hex)


join <-
  join[!is.na(join$iso2.prov.code), c("key_hex", "iso2.prov.code")]

grid.end <- merge(grid.df, join)

# Dataset

dfend <- st_drop_geometry(esp_grid_prov)

enddata <- merge(grid.end, dfend)

enddata <- enddata[, names(dfend)]
enddata <- enddata[order(enddata$cpro), ]

esp_hexbin_prov <- st_transform(enddata, st_crs(esp_hexbin_ccaa))
esp_hexbin_prov <- st_make_valid(esp_hexbin_prov)

rm(list = ls()[!(ls() %in% c(
  "esp_grid_ccaa",
  "esp_grid_prov",
  "esp_hexbin_ccaa",
  "esp_hexbin_prov"
))])


plot(st_geometry(esp_get_country()))
plot(st_geometry(esp_grid_ccaa), add = TRUE)
plot(st_geometry(esp_grid_prov), add = TRUE)

plot(st_geometry(esp_get_country()))
plot(st_geometry(esp_hexbin_ccaa), add = TRUE)
plot(st_geometry(esp_hexbin_prov), add = TRUE)

dev.off()

# Overwrite

esp_hexbin_ccaa_new <- esp_hexbin_ccaa
esp_hexbin_prov_new <- esp_hexbin_prov

load("./R/sysdata.rda")

esp_hexbin_ccaa <- esp_hexbin_ccaa_new
esp_hexbin_prov <- esp_hexbin_prov_new


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


