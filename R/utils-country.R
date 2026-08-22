#' Convert country names or codes to the desired code
#'
#' @param names Character vector of country names or codes.
#'
#' @param out Output code.
#' @param call The execution environment to use in error messages.
#'
#' @return A character vector with converted country names or codes.
#'
#' @noRd
convert_country_code <- function(names, out = "iso3c", call = parent.frame()) {
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
          "Invalid country name or code {.str {x}}. ",
          "Use country names, {.code ISO3} codes or {.code ISO2} codes."
        ),
        call = call
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
    ff <- cli_vec_no_oxford(ff)
    cli::cli_warn(c(
      paste0(
        "Some country names or codes could not be matched ",
        "unambiguously: {.str {ff}}."
      ),
      i = "Review the names or codes, or switch to {.code ISO3} codes."
    ))
  }

  outnames2
}
