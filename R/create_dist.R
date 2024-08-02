# 1. Config----

rm(list = ls())
library(sf)
library(dplyr)
library(zip)


lastdist <- 2024



# 2. Clean ----

# Clean output dirs
#
# folderfiles <- list.files("dist/")
# all <- file.path("dist", folderfiles)
# file.remove(all)


# 3. CartoBase 60W----

basedir <- file.path(
  "dev", "SIANE_CARTO_BASE_W_60M", "SIANE_CARTO_BASE_W_60M",
  "todo"
)


# List files
shp <- list.files(basedir, pattern = ".shp", full.names = TRUE, recursive = TRUE)


# Create geopackages
i <- 1
for (i in seq_len(length(shp))) {
  path <- file.path(shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dev", basename(shp[i])))

  input <- read_sf(path, stringsAsFactors = FALSE, quiet = TRUE)
  # Is ccaa?
  is_ccaa <- grepl("ccaa_", outpath)
  if (is_ccaa) {
    input$nombres_f <- input$rotulo
  }
  if ("fecha_baja" %in% names(input)) {
    input$fecha_baja[input$fecha_baja < 0] <- NA
  }


  message(outpath)

  write_sf(input,
    outpath,
    factorsAsCharacter = FALSE,
    overwrite = TRUE
  )
}


# 4. CartoBase 14M----

basedir <- file.path(
  "dev", "SIANE_CARTO_BASE_E_14M", "SIANE_CARTO_BASE_E_14M",
  "todo"
)


# List files
shp <- list.files(basedir, pattern = ".shp", full.names = TRUE, recursive = TRUE)


# Create geopackages
i <- 1
for (i in seq_len(length(shp))) {
  path <- file.path(shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dev", basename(shp[i])))

  input <- read_sf(path, stringsAsFactors = FALSE, quiet = TRUE)
  # Is ccaa?
  is_ccaa <- grepl("ccaa_", outpath)
  if (is_ccaa) {
    input$nombres_f <- input$rotulo
  }
  if ("fecha_baja" %in% names(input)) {
    input$fecha_baja[input$fecha_baja < 0] <- NA
  }


  message(outpath)

  write_sf(input,
    outpath,
    factorsAsCharacter = FALSE,
    overwrite = TRUE
  )
}

# 5. CartoBase 10M----

basedir <- file.path(
  "dev", "SIANE_CARTO_BASE_S_10M", "SIANE_CARTO_BASE_S_10M",
  "todo"
)


# List files
shp <- list.files(basedir, pattern = ".shp$", full.names = TRUE, recursive = TRUE)

# Create geopackages
i <- 1
for (i in seq_len(length(shp))) {
  path <- file.path(shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dev", basename(shp[i])))

  input <- read_sf(path, stringsAsFactors = FALSE, quiet = TRUE)
  # Is ccaa?
  is_ccaa <- grepl("ccaa_", outpath)
  if (is_ccaa) {
    input$nombres_f <- input$rotulo
  }
  if ("fecha_baja" %in% names(input)) {
    input$fecha_baja[input$fecha_baja < 0] <- NA
  }


  message(outpath)

  write_sf(input,
    outpath,
    factorsAsCharacter = FALSE,
    overwrite = TRUE
  )
}

# 6. CartoBase 6M5----

basedir <- file.path(
  "dev", "SIANE_CARTO_BASE_S_6M5", "SIANE_CARTO_BASE_S_6M5",
  "todo"
)


# List files
shp <- list.files(basedir, pattern = ".shp$", full.names = TRUE, recursive = TRUE)

# Create geopackages
i <- 1
for (i in seq_len(length(shp))) {
  path <- file.path(shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dev", basename(shp[i])))

  input <- read_sf(path, stringsAsFactors = FALSE, quiet = TRUE)
  # Is ccaa?
  is_ccaa <- grepl("ccaa_", outpath)
  if (is_ccaa) {
    input$nombres_f <- input$rotulo
  }
  if ("fecha_baja" %in% names(input)) {
    input$fecha_baja[input$fecha_baja < 0] <- NA
  }


  message(outpath)

  write_sf(input,
    outpath,
    factorsAsCharacter = FALSE,
    overwrite = TRUE
  )
}
# 7. CartoBase 3M----

basedir <- file.path(
  "dev", "SIANE_CARTO_BASE_S_3M", "SIANE_CARTO_BASE_S_3M",
  "todo"
)


# List files
shp <- list.files(basedir, pattern = ".shp$", full.names = TRUE, recursive = TRUE)

# Create geopackages
i <- 1
for (i in seq_len(length(shp))) {
  path <- file.path(shp[i])
  outpath <- gsub(".shp", ".gpkg", file.path("dev", basename(shp[i])))

  input <- read_sf(path, stringsAsFactors = FALSE, quiet = TRUE)
  # Is ccaa?
  is_ccaa <- grepl("ccaa_", outpath)
  if (is_ccaa) {
    input$nombres_f <- input$rotulo
  }
  if ("fecha_baja" %in% names(input)) {
    input$fecha_baja[input$fecha_baja < 0] <- NA
  }


  message(outpath)

  write_sf(input,
    outpath,
    factorsAsCharacter = FALSE,
    overwrite = TRUE
  )
}
# 8. Create zip----
# https://stackoverflow.com/questions/23668395/creating-zip-file-from-folders-in-r




files2zip <- dir("dev", full.names = TRUE, pattern = ".gpkg$")
zipr(zipfile = "dev/CartoBase.zip", files = files2zip)

# Move to dist
file.copy("dev/CartoBase.zip", "dist")

allgpkg <- list.files("dev", pattern = ".gpkg$", full.names = TRUE)

file.copy(allgpkg, to = "dist", overwrite = TRUE)

# 9 Update README----

rmarkdown::render(
  "README.Rmd",
  clean = TRUE,
  params = list(last_year = 2024)
)
