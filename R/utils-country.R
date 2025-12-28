#' Convert country names or codes to desired code
#'
#' @param names vector of names or codes
#'
#' @param out out code
#'
#' @return a vector of names
#'
#' @noRd
convert_country_code <- function(names, out = "iso3c") {
  names[tolower(names) == "antartica"] <- "Antarctica"

  # Vectorize
  outnames <- lapply(names, function(x) {
    if (
      any(grepl("kosovo", tolower(x)), "xk" == tolower(x), "xkx" == tolower(x))
    ) {
      code <- switch(out,
        "eurostat" = "XK",
        "iso3c" = "XKX"
      )
      return(code)
    }

    maxname <- max(nchar(x))
    if (maxname > 3) {
      outnames <- countrycode::countryname(x, out, warn = FALSE)
    } else if (maxname == 3) {
      outnames <- countrycode::countrycode(x, "iso3c", out, warn = FALSE)
    } else if (maxname == 2) {
      outnames <- countrycode::countrycode(x, "iso2c", out, warn = FALSE)
    } else {
      cli::cli_abort(
        paste0(
          "Invalid country name {.str {x}}. ",
          "Try a vector of names or ISO3/ISO2 codes"
        ),
        call = NULL
      )
    }
    outnames
  })

  outnames <- unlist(outnames)
  linit <- length(outnames)
  outnames2 <- outnames[!is.na(outnames)]
  lend <- length(outnames2)
  if (linit != lend) {
    ff <- names[is.na(outnames)] # nolint
    cli::cli_alert_warning(
      "Some country/codes were not matched unambiguously: {.str {ff}}"
    )
    cli::cli_alert_info("Review the names/codes or switch to ISO3 codes.")
  }

  outnames2
}
