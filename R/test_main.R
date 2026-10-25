# Run the unchanged main test suite against an isolated CDN revision.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L)
package <- normalizePath(args[1], winslash = "/", mustWork = TRUE)
ref <- Sys.getenv("DATA_REF")
stopifnot(grepl("^[0-9a-f]{40}$", ref))
files <- list.files(file.path(package, "R"), "\\.R$", full.names = TRUE)
changed <- 0L
for (file in files) {
  text <- readLines(file, warn = FALSE, encoding = "UTF-8")
  replacement <- gsub(
    "/raw/sianedata/",
    paste0("/raw/", ref, "/"),
    text,
    fixed = TRUE
  )
  if (!identical(text, replacement)) {
    writeLines(replacement, file, useBytes = TRUE)
    changed <- changed + 1L
  }
}
stopifnot(changed > 0L)
Sys.setenv(NOT_CRAN = "true", MAPSPAIN_CACHE_DIR = tempfile("siane-ci-cache-"))
setwd(package)
devtools::load_all()
# Fail instead of silently skipping the SIANE tests when the CDN is unavailable.
stopifnot(mapSpain::esp_check_access())
message(
  "Testing main with CDN commit ",
  ref,
  " (",
  changed,
  " R files redirected)."
)
devtools::test(stop_on_failure = TRUE)
