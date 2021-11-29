# 1. Config----

rm(list = ls())
library(sf)
library(dplyr)
library(zip)


initwd <- getwd()

setwd("MTN")

# 2. Clean ----

# Clean output dirs

folderfiles <- list.files("dist/")
all <- file.path("dist", folderfiles)
file.remove(all)


# MTN ----

basedir <-
  file.path("source")


# List files
shp <- list.files(basedir)
shp <- shp[grep(".shp", shp)]


# Create geopackages

for (i in seq_len(length(shp))) {
  path <- file.path(basedir, shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dist", shp[i]))

  if (file.exists(outpath)) {
    print(paste0("Skipping ", outpath, ", already in dist"))
    next()
  }
  input <-
    st_read(path, stringsAsFactors = FALSE, quiet = TRUE) %>% st_make_valid()

  write_sf(input,
    outpath,
    factorsAsCharacter = FALSE,
    overwrite = TRUE
  )
}


# 8. Create zip----
# https://stackoverflow.com/questions/23668395/creating-zip-file-from-folders-in-r




files2zip <- dir("dist", full.names = TRUE)
zipr(zipfile = "dist/MTN_grids.zip", files = files2zip)

# Reset wd

setwd(initwd)

rm(list = ls())
