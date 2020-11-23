## code to prepare `pobmun19` dataset goes here


rm(list = ls())

source("./data-raw/helperfuns.R")

library(readxl)
library(dplyr)
pobmun19 <- read_xlsx("./data-raw/input/pobmun19.xlsx",
                      range = "A2:G8133") %>% esp_hlp_utf8()

names(pobmun19) <-
  c("cpro", "provincia", "cmun", "name", "pob19", "men", "women")

usethis::use_data(pobmun19, overwrite = TRUE, compress = "xz")
