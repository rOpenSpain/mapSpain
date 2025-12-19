## code to prepare `sysdata` dataset goes here

rm(list = ls())


library(tidyverse)
library(dplyr)
library(reshape2)
library(gsubfn)
source("./data-raw/helperfuns.R")


# Load ----

nuts1 <- read_csv("./data-raw/dict/esp_nuts1.csv")
# write_csv(nuts,"./data-raw/dict/esp_nuts1.csv")

ccaa <- read_csv("./data-raw/dict/esp_ccaa.csv")

# write_csv(ccaa,"./data-raw/dict/esp_ccaa.csv", na = "")

# prov <- readxl::read_xlsx("./data-raw/dict/helper.xlsx", sheet = "provs")
# prov$cpro <- str_pad(prov$cpro, width = 2, pad = "0")
# prov$codauto <- str_pad(prov$codauto, width = 2, pad = "0")
# write_csv(prov,"./data-raw/dict/esp_prov.csv", na = "")

prov <- read_csv("./data-raw/dict/esp_prov.csv")

nuts3 <- read_csv("./data-raw/dict/esp_nuts3.csv")

# names_full----

# Create individual dictionaries
dict_nuts1 <- nuts1 |>
  mutate(key = nuts1.shortname.es) |>
  distinct()

dict_ccaa <- ccaa |>
  mutate(key = ccaa.shortname.es) |>
  distinct()

dict_prov <- prov |>
  mutate(key = prov.shortname.es) |>
  distinct()

dict_nuts3 <- nuts3 |>
  mutate(key = nuts3.shortname.es) |>
  distinct()


# Create full translator

dict_nuts1all <- melt(
  dict_nuts1,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_nuts1)
) |>
  unique()
dict_ccaaall <- melt(
  dict_ccaa,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_ccaa)
) |>
  unique()

dict_provall <- melt(
  dict_prov,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_prov)
) |>
  unique()


dict_nuts3all <- melt(
  dict_nuts3,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_nuts3)
) |>
  unique()


names_full <- bind_rows(
  dict_ccaaall,
  dict_nuts1all,
  dict_provall,
  dict_nuts3all
) |>
  unique() |>
  mutate(variable = as.character(variable)) |>
  as_tibble()

# Add versions without accents, etc.

names_alt <- names_full |>
  mutate(
    value = iconv(value, from = "UTF-8", to = "ASCII//TRANSLIT"),
    variable = paste0("clean.", variable)
  )

names_full <- bind_rows(names_full, names_alt) |> distinct()

# Version UPCASE and lowercase

upcase <- names_full |>
  mutate(
    value = toupper(value),
    variable = paste0("upcase.", variable)
  )
locase <- names_full |>
  mutate(
    value = tolower(value),
    variable = paste0("locase.", variable)
  )

names_full <- bind_rows(names_full, upcase) |>
  bind_rows(locase) |>
  distinct()


# Tests names_full

names_dict <- unique(names_full[
  grep("name", names_full$variable),
  c("key", "value")
])


test <- c(
  "Xaén",
  "Jaen",
  "Leon",
  "Girona",
  "Errioxa",
  "Madril",
  "Vizcaya",
  "Andalusia",
  "Kanariak"
)
ret <- countrycode::countrycode(
  test,
  origin = "value",
  destination = "key",
  custom_dict = names_dict,
  nomatch = NULL
)


toen <- names_full[names_full$key == "Madrid", ]
unique(toen[grep("name.ca", toen$variable), "value"])

# Translate all

countrycode::countrycode(
  ret,
  "key",
  "nuts1.code",
  custom_dict = dict_nuts1,
  nomatch = "XXX"
)

countrycode::countrycode(
  ret,
  "key",
  "nuts2.code",
  custom_dict = dict_ccaa,
  nomatch = "XX"
)

countrycode::countrycode(
  ret,
  "key",
  "nuts.prov.code",
  custom_dict = dict_prov,
  nomatch = "XX"
)

countrycode::countrycode(
  ret,
  "key",
  "nuts3.code",
  custom_dict = dict_nuts3,
  nomatch = "XX"
)


# names2nuts----

names2nuts <- esp_hlp_names2nuts()

# Test

var <- c(
  "Madrid",
  "Valencia",
  "Menorca",
  "Tenerife",
  "Las Palmas",
  "Santa Cruz de Tenerife",
  "Madrid",
  "Andalucía"
)

f <- countrycode::countrycode(
  var,
  "key",
  "nuts",
  custom_dict = names2nuts,
  nomatch = "XX"
)
f
countrycode::countrycode(
  f,
  "nuts",
  "key",
  custom_dict = names2nuts,
  nomatch = "XX"
)


# code2code----

code2code <- esp_hlp_code2code()


# Test

countrycode::countrycode(
  f,
  "nuts",
  "iso2",
  custom_dict = code2code,
  nomatch = "XX"
)
countrycode::countrycode(
  f,
  "nuts",
  "codauto",
  custom_dict = code2code,
  nomatch = "XX"
)

countrycode::countrycode(
  f,
  "nuts",
  "cpro",
  custom_dict = code2code,
  nomatch = "XX"
)

countrycode::countrycode(
  c("ES-AN"),
  "iso2",
  "nuts",
  custom_dict = code2code,
  nomatch = "XX"
)


dict_ccaa <- dict_ccaa |> as.data.frame()
dict_prov <- dict_prov |> as.data.frame()
code2code <- code2code |> as.data.frame()
names2nuts <- names2nuts |> as.data.frame()
names_full <- names_full |> as.data.frame()

# Add grid files

library(sf)
esp_hexbin_prov <- read_geo_file_sf("./data-raw/esp_hexbin_prov.gpkg") |>
  sanitize_sf()

esp_hexbin_ccaa <- read_geo_file_sf("./data-raw/esp_hexbin_ccaa.gpkg") |>
  sanitize_sf()


esp_grid_prov <- read_geo_file_sf("./data-raw/esp_grid_prov.gpkg")

esp_grid_ccaa <- read_geo_file_sf("./data-raw/esp_grid_ccaa.gpkg")


usethis::use_data(
  # dict_nuts1,
  # dict_ccaa,
  # dict_prov,
  # dict_nuts3,
  code2code,
  names2nuts,
  names_full,
  esp_hexbin_ccaa,
  esp_hexbin_prov,
  esp_grid_ccaa,
  esp_grid_prov,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

tools::checkRdaFiles("./R")
