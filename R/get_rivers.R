library(dplyr)
library(foreign)
library(stringr)

url <- "https://ceh-flumen64.cedex.es/clasificacion/descargas/Pfafrios.zip"
destfolder <- "data-raw"
destfile <- file.path(destfolder, "Pfafrios.zip")
download.file(url = url, destfile = destfile)

# Extract ----
dir <- tempdir()
list <- unzip(destfile, list = TRUE, exdir = dir)

unzip(destfile, exdir = dir)

# Read ----

rawfile <- file.path(dir, list[grep(".dbf", list), ]$Name)
rawriver <- read.dbf(rawfile)


# Write ---
riosend <- rawriver %>%
  select(PFAFRIO, NOM_RIO) %>%
  mutate(PFAFRIO = as.character(PFAFRIO)) %>%
  mutate(NOM_RIO = as.character(NOM_RIO))


riosend$NOM_RIO <- stringr::str_to_title(riosend$NOM_RIO, "es")
riosend[riosend$NOM_RIO == "Sin Nombre", ]$NOM_RIO <- NA

# Save

saveRDS(riosend, "data-raw/rivernames.rda", compress = "xz")
