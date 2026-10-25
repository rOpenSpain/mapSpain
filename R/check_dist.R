# Verify the published files and bulk ZIP without changing the distribution.
check_dist <- function(path = "dist") {
  inventory <- utils::read.csv(file.path(path, "manifest.csv"))
  files <- list.files(path, "\\.gpkg$")
  stopifnot(!anyDuplicated(inventory$file), setequal(files, inventory$file))
  archive <- file.path(path, "CartoBase.zip")
  stopifnot(setequal(zip::zip_list(archive)$filename, files))
  extracted <- tempfile("cartobase-check-")
  dir.create(extracted)
  on.exit(unlink(extracted, recursive = TRUE), add = TRUE)
  utils::unzip(archive, exdir = extracted)
  stopifnot(identical(
    unname(tools::md5sum(file.path(path, files))),
    unname(tools::md5sum(file.path(extracted, files)))
  ))
  for (i in seq_len(nrow(inventory))) {
    data <- sf::read_sf(file.path(path, inventory$file[i]))
    stopifnot(nrow(data) == inventory$rows[i], !is.na(sf::st_crs(data)))
    if (all(c("fecha_alta", "fecha_baja") %in% names(data))) {
      stopifnot(
        inherits(data$fecha_alta, "Date"),
        inherits(data$fecha_baja, "Date"),

        all(
          is.na(data$fecha_alta) |
            is.na(data$fecha_baja) |
            data$fecha_alta <= data$fecha_baja
        )
      )
    }
  }
  message(
    "Verified ",
    length(files),
    " layers and identical bulk ZIP contents."
  )
  invisible(inventory)
}

if (sys.nframe() == 0L) {
  check_dist()
}
