## code to prepare `sysdata` dataset goes here

rm(list = ls())

library(dplyr)
library(reshape2)
library(gsubfn)
source("./data-raw/helperfuns.R")


nuts1 <- read.csv(
  "./data-raw/dict/esp_nuts1.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8",
  colClasses = "character"
) |>
  esp_hlp_utf8()

ccaa <- read.csv(
  "./data-raw/dict/esp_ccaa.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8",
  colClasses = "character"
) |>
  esp_hlp_utf8()

prov <- read.csv(
  "./data-raw/dict/esp_prov.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8",
  colClasses = "character"
) |>
  esp_hlp_utf8()

nuts3 <- read.csv(
  "./data-raw/dict/esp_nuts3.csv",
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8",
  colClasses = "character"
) |>
  esp_hlp_utf8()

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


names_full <- dict_ccaaall |>
  bind_rows(dict_nuts1all, dict_provall, dict_nuts3all) |>
  unique() |>
  mutate(variable = as.character(variable))


# Add extra used names
# Ciudad de Ceuta
ceuta <- names_full[grepl("^ceuta", names_full$value, ignore.case = TRUE), ]
ceuta$variable <- paste0("alt.", ceuta$variable)
ceuta$value <- paste0("Ciudad de ", ceuta$value)

# Ciudad de Melilla
melilla <- names_full[grepl("^melilla", names_full$value, ignore.case = TRUE), ]
melilla$variable <- paste0("alt.", melilla$variable)
melilla$value <- paste0("Ciudad de ", melilla$value)

# Santa Cruz de Tenerife
tfe <- names_full[grepl("^santa cruz", names_full$value, ignore.case = TRUE), ]
tfe$variable <- paste0("alt.", tfe$variable)
tfe$value <- gsub("Santa", "Sta.", tfe$value)

las <- names_full[grepl("^la |^las ", names_full$value, ignore.case = TRUE), ]
las$variable <- paste0("alt.las.", las$variable)

las$value <- gsub("^la |^las ", "", las$value, ignore.case = TRUE)


names_full <- unique(rbind(names_full, ceuta, melilla, tfe, las))
names_full$value <- trimws(names_full$value)

# Add versions without accents, etc.

names_alt <- names_full |>
  mutate(
    value = iconv(value, from = "UTF-8", to = "ASCII//TRANSLIT"),
    variable = paste0("clean.", variable)
  )

names_full <- rbind(names_full, names_alt) |> distinct()

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

names_full <- rbind(names_full, upcase) |>
  rbind(locase) |>
  unique()

names_full <- names_full |>
  filter(value != "") |>
  as.data.frame()

# Add grid files

library(sf)
esp_hexbin_prov <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_hexbin_prov.gpkg"
) |>
  mapSpain:::sanitize_sf()

esp_hexbin_ccaa <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_hexbin_ccaa.gpkg"
) |>
  mapSpain:::sanitize_sf()


esp_grid_prov <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_grid_prov.gpkg"
) |>
  mapSpain:::sanitize_sf()

esp_grid_ccaa <- mapSpain:::read_geo_file_sf(
  "./data-raw/esp_grid_ccaa.gpkg"
) |>
  mapSpain:::sanitize_sf()


# Databases
dbs <- list.files(
  "data-raw/listas_de_valores_enumerados/",
  pattern = "dbf",
  full.names = TRUE
)


db_valores <- lapply(dbs, function(x) {
  f <- tibble::as_tibble(foreign::read.dbf(x))
  clean_x <- gsub("lve_", "", basename(x))
  clean_x <- gsub(".dbf", "", clean_x)
  clean_x <- tolower(clean_x)
  f$campo <- clean_x
  f[, unique(c("campo", colnames(f)))]
}) |>
  dplyr::bind_rows() |>
  dplyr::as_tibble() |>
  dplyr::mutate(descrip = as.character(descrip))


usethis::use_data(
  db_valores,
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
tools::resaveRdaFiles("./R")

rm(list = ls())
