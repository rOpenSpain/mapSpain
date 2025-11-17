## code to prepare `sysdata` dataset goes here

rm(list = ls())


library(dplyr)
library(reshape2)
library(gsubfn)
source("./data-raw/helperfuns.R")


# Load ----

NUTS1 <-
  read.csv(
    "./data-raw/espNUTS1.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()

CCAA <-
  read.csv(
    "./data-raw/espCCAA.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()

PROV <-
  read.csv(
    "./data-raw/espPROV.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()

NUTS3 <-
  read.csv(
    "./data-raw/espNUTS3.csv",
    stringsAsFactors = FALSE,
    fileEncoding = "UTF-8",
    colClasses = "character"
  ) %>% esp_hlp_utf8()

# names_full----

# Create individual dictionaries
dict_nuts1 <-
  NUTS1 %>%
  mutate(key = nuts1.shortname.es) %>%
  distinct()
dict_ccaa <- CCAA %>%
  mutate(key = ccaa.shortname.es) %>%
  distinct()
dict_prov <- PROV %>%
  mutate(key = prov.shortname.es) %>%
  distinct()
dict_nuts3 <-
  NUTS3 %>%
  mutate(key = nuts3.shortname.es) %>%
  distinct()


# Create full translator

dict_nuts1all <- melt(
  dict_nuts1,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_nuts1)
) %>% unique()
dict_ccaaall <- melt(
  dict_ccaa,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_ccaa)
) %>% unique()

dict_provall <- melt(
  dict_prov,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_prov)
) %>% unique()


dict_nuts3all <- melt(
  dict_nuts3,
  id = "key",
  na.rm = TRUE,
  measure.vars = colnames(dict_nuts3)
) %>% unique()


names_full <-
  bind_rows(dict_ccaaall, dict_nuts1all, dict_provall, dict_nuts3all) %>%
  unique() %>%
  mutate(variable = as.character(variable))

# Add versions without accents, etc.


names_alt <-
  names_full %>% mutate(
    value = iconv(value, from = "UTF-8", to = "ASCII//TRANSLIT"),
    variable = paste0("clean.", variable)
  )

names_full <- rbind(names_full, names_alt) %>% distinct()

# Version UPCASE and lowercase

upcase <- names_full %>% mutate(
  value = toupper(value),
  variable =
    paste0("upcase.", variable)
)
locase <- names_full %>% mutate(
  value = tolower(value),
  variable =
    paste0("locase.", variable)
)

names_full <-
  rbind(names_full, upcase) %>%
  rbind(locase) %>%
  distinct()

# Tests names_full

names_dict <-
  unique(names_full[grep("name", names_full$variable), c("key", "value")])


test <-
  c(
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
ret <-
  countrycode::countrycode(
    test,
    origin = "value",
    destination = "key",
    custom_dict = names_dict,
    nomatch = NULL
  )


toen <- names_full[names_full$key == "Madrid", ]
unique(toen[grep("name.ca", toen$variable), "value"])

# Translate all

countrycode::countrycode(ret,
  "key",
  "nuts1.code",
  custom_dict = dict_nuts1,
  nomatch = "XXX"
)

countrycode::countrycode(ret,
  "key",
  "nuts2.code",
  custom_dict = dict_ccaa,
  nomatch = "XX"
)

countrycode::countrycode(ret,
  "key",
  "nuts.prov.code",
  custom_dict = dict_prov,
  nomatch = "XX"
)

countrycode::countrycode(ret,
  "key",
  "nuts3.code",
  custom_dict = dict_nuts3,
  nomatch = "XX"
)


# names2nuts----

names2nuts <- esp_hlp_names2nuts()

# Test

var <-
  c(
    "Madrid",
    "Valencia",
    "Menorca",
    "Tenerife",
    "Las Palmas",
    "Santa Cruz de Tenerife",
    "Madrid",
    "Andalucía"
  )

f <- countrycode::countrycode(var,
  "key",
  "nuts",
  custom_dict = names2nuts,
  nomatch = "XX"
)
f
countrycode::countrycode(f,
  "nuts",
  "key",
  custom_dict = names2nuts,
  nomatch = "XX"
)


# code2code----

code2code <- esp_hlp_code2code()


# Test

countrycode::countrycode(f,
  "nuts",
  "iso2",
  custom_dict = code2code,
  nomatch = "XX"
)
countrycode::countrycode(f,
  "nuts",
  "codauto",
  custom_dict = code2code,
  nomatch = "XX"
)

countrycode::countrycode(f,
  "nuts",
  "cpro",
  custom_dict = code2code,
  nomatch = "XX"
)

countrycode::countrycode(c("ES-AN"),
  "iso2",
  "nuts",
  custom_dict = code2code,
  nomatch = "XX"
)


dict_ccaa <- dict_ccaa %>% as.data.frame()
dict_prov <- dict_prov %>% as.data.frame()
code2code <- code2code %>% as.data.frame()
names2nuts <- names2nuts %>% as.data.frame()
names_full <- names_full %>% as.data.frame()

# Add grid files

library(sf)
esp_hexbin_prov <-
  st_read("./data-raw/esp_hexbin_prov.gpkg",
    stringsAsFactors = FALSE
  ) %>%
  st_make_valid()

esp_hexbin_ccaa <-
  st_read("./data-raw/esp_hexbin_ccaa.gpkg",
    stringsAsFactors = FALSE
  ) %>%
  st_make_valid()


esp_grid_prov <-
  st_read("./data-raw/esp_grid_prov.gpkg",
    stringsAsFactors = FALSE
  ) %>%
  st_make_valid()

esp_grid_ccaa <-
  st_read("./data-raw/esp_grid_ccaa.gpkg",
    stringsAsFactors = FALSE
  ) %>%
  st_make_valid()

usethis::use_data(
  # dict_nuts1,
  dict_ccaa,
  dict_prov,
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
