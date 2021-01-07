# 1. Config----

rm(list = ls())
library(sf)
library(dplyr)
lastdist <- 2020



# 2. Clean ----

# Clean output dirs

folderfiles <- list.files("dist/")
gpkg <- folderfiles[grep(".gpkg", folderfiles)]
gpkg <- file.path("dist", gpkg)
file.remove(gpkg)

# pngs

folderfiles <- list.files("img/")
png <- file.path("img", folderfiles)
file.remove(png)

# 3. CartoBase 3M----

basedir <-
  file.path("data-raw", lastdist, "SIANE_CARTO_BASE_S_3M", "todo")


# List files
shp <- list.files(basedir)
shp <- shp[grep(".shp", shp)]


# Create geopackages

for (i in seq_len(length(shp))) {
  path <- file.path(basedir, shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dist", shp[i]))

  if (file.exists(outpath)) {
    print(paste0("Skipping ", outpath ,", already in dist"))
    next()
  }
  input <-
    st_read(path, stringsAsFactors = FALSE) %>% st_make_valid()

  write_sf(input,
           outpath,
           factorsAsCharacter = FALSE,
           overwrite = TRUE)

}


# 4. CartoBase 6M5----

basedir <-
  file.path("data-raw", lastdist, "SIANE_CARTO_BASE_S_6M5", "todo")


# List files
shp <- list.files(basedir)
shp <- shp[grep(".shp", shp)]




# Create geopackages

for (i in seq_len(length(shp))) {
  path <- file.path(basedir, shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dist", shp[i]))

  if (file.exists(outpath)) {
    print(paste0("Skipping ", outpath ,", already in dist"))
    next()
  }

  input <-
    st_read(path, stringsAsFactors = FALSE) %>% st_make_valid()

  write_sf(input,
           outpath,
           factorsAsCharacter = FALSE,
           overwrite = TRUE)

}



# 5. CartoBase 10M----

basedir <-
  file.path("data-raw", lastdist, "SIANE_CARTO_BASE_S_10M", "todo")


# List files
shp <- list.files(basedir)
shp <- shp[grep(".shp", shp)]




# Create geopackages

for (i in seq_len(length(shp))) {
  path <- file.path(basedir, shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dist", shp[i]))

  if (file.exists(outpath)) {
    print(paste0("Skipping ", outpath ,", already in dist"))
    next()
  }

  input <-
    st_read(path, stringsAsFactors = FALSE) %>% st_make_valid()

  write_sf(input,
           outpath,
           factorsAsCharacter = FALSE,
           overwrite = TRUE)

}


# # 6. CartoBase 14M----
#
# basedir <-
#   file.path("data-raw", lastdist, "SIANE_CARTO_BASE_E_14M",
#             "todo")
#
#
# # List files
# shp <- list.files(basedir)
# shp <- shp[grep(".shp", shp)]
#
#
#
#
# # Create geopackages
#
# for (i in seq_len(length(shp))) {
#   path <- file.path(basedir, shp[i])
#   outpath <- gsub(".shp", ".gpkg", file.path("dist", shp[i]))
#
#   if (file.exists(outpath)) {
#     print(paste0("Skipping ", outpath ,", already in dist"))
#     next()
#   }
#
#   input <-
#     st_read(path, stringsAsFactors = FALSE) %>% st_make_valid()
#
#   write_sf(input,
#            outpath,
#            factorsAsCharacter = FALSE,
#            overwrite = TRUE)
# }
#
#
#
#
# # 7. CartoBase 60M----
#
# basedir <-
#   file.path("data-raw", lastdist, "SIANE_CARTO_BASE_W_60M",
#             "todo")
#
#
# # List files
# shp <- list.files(basedir)
# shp <- shp[grep(".shp", shp)]
#
#
#
# i = 1
#
# # Create geopackages
#
# for (i in seq_len(length(shp))) {
#   path <- file.path(basedir, shp[i])
#   outpath <- gsub(".shp", ".gpkg", file.path("dist", shp[i]))
#
#   if (file.exists(outpath)) {
#     print(paste0("Skipping ", outpath ,", already in dist"))
#     next()
#   }
#
#   input <-
#     st_read(path, stringsAsFactors = FALSE) %>% st_make_valid()
#
#   write_sf(input,
#            outpath,
#            factorsAsCharacter = FALSE,
#            overwrite = TRUE)
#
# }

# 8 Update README----

rmarkdown::render(
  "README.Rmd",
  clean = TRUE,
  params = list(last_year = lastdist)
)


