rm(list = ls())

library(readxl)
library(dplyr)

read_xlsx("./data-raw/input/esp_codes.xlsx",
          sheet = "NAMES_NUTS1") %>%
  write.csv("./data-raw/espNUTS1.csv",
            row.names = FALSE,
            fileEncoding = "UTF-8")

read_xlsx("./data-raw/input/esp_codes.xlsx",
          sheet = "NAMES_CCAA") %>%
  write.csv("./data-raw/espCCAA.csv",
            row.names = FALSE,
            fileEncoding = "UTF-8")

read_xlsx("./data-raw/input/esp_codes.xlsx",
          sheet = "NAMES_PROV") %>%
  write.csv("./data-raw/espPROV.csv",
            row.names = FALSE,
            fileEncoding = "UTF-8")

read_xlsx("./data-raw/input/esp_codes.xlsx",
          sheet = "NAMES_NUTS3") %>%
  write.csv("./data-raw/espNUTS3.csv",
            row.names = FALSE,
            fileEncoding = "UTF-8")

# source("./data-raw/esp_codelist.R")
# source("./data-raw/sysdata.R")



