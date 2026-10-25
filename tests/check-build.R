# Run with Rscript tests/check-build.R from the repository root.
source("R/create_dist.R")
source("R/check_dist.R")

missing <- tempfile("missing-archives-")
error <- tryCatch(create_dist(missing), error = identity)
stopifnot(
  inherits(error, "error"),
  grepl("five official", conditionMessage(error))
)

# Reject a manifest that disagrees with the actual layer inventory.
fixture <- tempfile("invalid-dist-")
dir.create(fixture)
utils::write.csv(
  data.frame(file = "missing.gpkg"),
  file.path(fixture, "manifest.csv"),
  row.names = FALSE
)
error <- tryCatch(check_dist(fixture), error = identity)
stopifnot(inherits(error, "error"))
unlink(fixture, recursive = TRUE)

inventory <- check_dist()
stopifnot(
  sum(inventory$edition == 2026) == 74L,
  sum(inventory$edition == 2024) == 5L
)
message("Build guards and distribution checks passed.")
