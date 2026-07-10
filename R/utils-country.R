#' Convert country names or codes to the desired code
#'
#' @param names Character vector of country names or codes.
#'
#' @param out Output code.
#'
#' @return A character vector with converted country names or codes.
#'
#' @noRd
convert_country_code <- function(names, out = "iso3c") {
  names[tolower(names) == "antartica"] <- "Antarctica"

  # Vectorize country code conversion.
  outnames <- lapply(names, function(x) {
    if (
      any(
        grepl("kosovo", tolower(x), fixed = TRUE),
        "xk" == tolower(x),
        "xkx" == tolower(x)
      )
    ) {
      code <- switch(out, "eurostat" = "XK", "iso3c" = "XKX")
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
          "Invalid country name or code {.str {x}}. ",
          "Use a vector of names, {.code ISO3} or {.code ISO2} codes."
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
    cli::cli_alert_warning(paste0(
      "Some country names or codes could not be matched ",
      "unambiguously: {.str {ff}}."
    ))
    cli::cli_alert_info(
      "Review the names or codes, or switch to {.code ISO3} codes."
    )
  }

  outnames2
}
