rm(list = ls())
load("./R/sysdata.rda")

list <- ls()




library(sf)
data.sf <-
  st_read("./data-raw/input/esp_prov_hexgrid.gpkg", stringsAsFactors = FALSE)


data.sf <- data.sf[, "ISO3"]
names(data.sf) <- c("iso2.prov.code", "geometry")

st_geometry(data.sf) <- "geometry"


# Get df
df <- dict_prov
df <- df[, names(df) != "key"]

data.sf <- merge(data.sf, df, all.x = TRUE)

# Paste nuts2
dfnuts <- mapSpain::esp_codelist
dfnuts <-
  unique(dfnuts[, c(
    "cpro",
    "nuts2.code",
    "nuts2.name",
    "nuts1.code",
    "nuts1.name"
  )])
data.sf <- merge(data.sf, dfnuts, all.x = TRUE)
data.sf <-
  data.sf[, c(
    colnames(df),
    "nuts2.code",
    "nuts2.name",
    "nuts1.code",
    "nuts1.name"
  )]

# Order
data.sf <- data.sf[order(data.sf$codauto, data.sf$cpro), ]

esp_hexbin_prov <- data.sf
esp_hexbin_prov <-
  st_transform(esp_hexbin_prov, st_crs(esp_get_ccaa()))


# CCAA

data.sf <-
  st_read("./data-raw/input/esp_ccaa_hexgrid.gpkg", stringsAsFactors = FALSE)

data.sf <- data.sf[, "ISO2"]
names(data.sf) <- c("iso2.ccaa.code", "geometry")

st_geometry(data.sf) <- "geometry"

# Get df
df <- dict_ccaa
df <- df[, names(df) != "key"]

data.sf <- merge(data.sf, df, all.x = TRUE)

# Paste nuts1
dfnuts <- mapSpain::esp_codelist
dfnuts <-
  unique(dfnuts[, c("nuts2.code", "nuts1.code", "nuts1.name")])
data.sf <- merge(data.sf, dfnuts, all.x = TRUE)
data.sf <- data.sf[, c(colnames(df), "nuts1.code", "nuts1.name")]

# Order
data.sf <- data.sf[order(data.sf$codauto), ]

esp_hexbin_ccaa <- data.sf

esp_hexbin_ccaa <-
  st_transform(esp_hexbin_ccaa, st_crs(esp_get_ccaa()))

usethis::use_data(
  code2code,
  dict_ccaa,
  dict_prov,
  names_full,
  names2nuts,
  esp_hexbin_ccaa,
  esp_hexbin_prov,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

tools::checkRdaFiles("./R")

rm(list = ls())
