#' SIANE bulk download
#'
#' @description
#' Download zipped data from SIANE to the [`cache_dir`][esp_set_cache_dir()]
#' and extract the relevant ones.
#'
#' @encoding UTF-8
#' @family political
#' @family siane
#' @inheritParams esp_get_ccaa_siane
#' @inheritParams esp_get_prov
#' @inherit esp_get_ccaa_siane source return
#' @export
#'
#' @return
#' A (invisible) character vector with the full path of the files extracted.
#' See **Examples**.
#' @examplesIf esp_check_access()
#' tmp <- file.path(tempdir(), "testexample")
#' dest_files <- esp_siane_bulk_download(cache_dir = tmp)
#'
#' # Read one
#' library(sf)
#' read_sf(dest_files[1]) |> head()
#'
#' # Now we can connect the function with the downloaded data like:
#'
#' connect <- esp_get_munic_siane(cache_dir = tmp, verbose = TRUE)
#'
#' # Message shows that file is already cached ;)
#'
#' # Clean
#' unlink(tmp, force = TRUE, recursive = TRUE)
esp_siane_bulk_download <- function(
  cache_dir = NULL,
  update_cache = FALSE,
  verbose = FALSE
) {
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "CartoBase.zip"
  )
  zipname <- "CartoBase.zip"

  destfile <- download_url(
    url,
    zipname,
    cache_dir = cache_dir,
    subdir = "siane",
    update_cache = update_cache,
    verbose = verbose
  )

  if (is.null(destfile)) {
    return(NULL)
  }

  # Clean cache dir name for extracting
  unzip_dir <- gsub(paste0("/", zipname), "", destfile)

  infiles <- unzip(destfile, list = TRUE, junkpaths = TRUE)
  # Extract files
  outfiles <- infiles[grep("gpkg", infiles$Name), ]$Name

  if (verbose) {
    for_bullets <- outfiles
    names(for_bullets) <- rep(">", length(for_bullets))
    cli::cli_alert_info(c("Extracting files:"))
    cli::cli_bullets(for_bullets)
  }

  unlink(file.path(unzip_dir, outfiles))

  unzip(destfile, files = outfiles, exdir = unzip_dir)

  out_full <- file.path(unzip_dir, outfiles)

  invisible(out_full)
}
