# Build from official ZIP files downloaded through the CNIG website.
# Run: Rscript R/create_dist.R <download-directory> [edition]
create_dist <- function(input_dir, edition = 2026, output_dir = "dist") {
  products <- c("W_60M", "E_14M", "S_10M", "S_6M5", "S_3M")
  archives <- file.path(
    input_dir,
    paste0("SIANE_CARTO_BASE_", products, ".zip")
  )
  if (!all(file.exists(archives))) {
    stop("All five official CartoBase ZIP files are required.")
  }
  legacy <- c(
    "se89_10_vias_ffcc_e_x.gpkg",
    "se89_10_vias_ffcc_l_x.gpkg",
    "se89_10_vias_ffcc_p_x.gpkg",
    "se89_3_urban_capimuni_a_x.gpkg",
    "se89_3_urban_capimuni_a_y.gpkg"
  )
  stage <- tempfile("cartobase-")
  dir.create(stage)
  on.exit(unlink(stage, recursive = TRUE), add = TRUE)
  built <- file.path(stage, "dist")
  dir.create(built)
  manifest <- list()
  for (archive in archives) {
    archive_hash <- digest::digest(file = archive, algo = "sha256")
    entries <- utils::unzip(archive, list = TRUE)$Name
    selected <- entries[grepl("/todo/[^/]+\\.(shp|shx|dbf|prj|cpg)$", entries)]
    if (!any(grepl("\\.shp$", selected))) {
      stop("No historical shapefiles found in ", basename(archive))
    }
    if (any(grepl("(^|/)\\.\\.(/|$)|^[/\\\\]|^[A-Za-z]:", selected))) {
      stop("Unsafe archive paths in ", basename(archive))
    }
    extracted <- file.path(stage, tools::file_path_sans_ext(basename(archive)))
    utils::unzip(archive, files = selected, exdir = extracted)
    shapes <- list.files(
      extracted,
      "\\.shp$",
      recursive = TRUE,
      full.names = TRUE
    )
    for (shape in shapes) {
      name <- paste0(tools::file_path_sans_ext(basename(shape)), ".gpkg")
      data <- sf::read_sf(shape)
      if ("fecha_baja" %in% names(data)) {
        data$fecha_baja[data$fecha_baja < as.Date("1970-01-01")] <- NA
      }
      if (grepl("ccaa_", name)) {
        data$nombres_f <- data$rotulo
      }
      # Preserve the geometry column name used by the existing CDN.
      geometry <- attr(data, "sf_column")
      names(data)[names(data) == geometry] <- "geom"
      sf::st_geometry(data) <- "geom"
      data <- data[, c(setdiff(names(data), "geom"), "geom")]
      destination <- file.path(built, name)
      if (file.exists(destination)) {
        previous <- sf::read_sf(destination)
        if (!isTRUE(all.equal(previous, data, check.attributes = FALSE))) {
          stop("Conflicting copies of layer ", name)
        }
        next
      }
      sf::write_sf(data, destination)
      check <- sf::read_sf(destination)
      stopifnot(nrow(check) == nrow(data), identical(names(check), names(data)))
      manifest[[name]] <- data.frame(
        file = name,
        edition = edition,
        source = basename(archive),
        sha256 = archive_hash,
        rows = nrow(data)
      )
    }
  }
  existing <- list.files(output_dir, "\\.gpkg$")
  missing <- setdiff(existing, names(manifest))
  if (length(setdiff(missing, legacy))) {
    stop(
      "Unexpected missing layers: ",
      paste(setdiff(missing, legacy), collapse = ", ")
    )
  }
  for (name in missing) {
    path <- file.path(output_dir, name)
    stopifnot(file.copy(path, built))
    manifest[[name]] <- data.frame(
      file = name,
      edition = 2024,
      source = "Retained from the 2024 CDN",
      sha256 = digest::digest(file = path, algo = "sha256"),
      rows = nrow(sf::read_sf(path))
    )
  }
  files <- sort(list.files(built, "\\.gpkg$", full.names = TRUE))
  zip::zipr(file.path(built, "CartoBase.zip"), files)
  stopifnot(setequal(
    zip::zip_list(file.path(built, "CartoBase.zip"))$filename,
    basename(files)
  ))
  inventory <- do.call(rbind, manifest)
  rownames(inventory) <- NULL
  utils::write.csv(
    inventory,
    file.path(built, "manifest.csv"),
    row.names = FALSE
  )
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  stopifnot(all(file.copy(
    list.files(built, full.names = TRUE),
    output_dir,
    overwrite = TRUE
  )))
  invisible(inventory)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args)) {
    stop("Usage: Rscript R/create_dist.R <download-directory> [edition]")
  }
  edition <- if (length(args) >= 2L) as.integer(args[2]) else 2026L
  create_dist(args[1], edition)
}
