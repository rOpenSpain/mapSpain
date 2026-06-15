#' Create messages by type
#'
#' @param type A character string. Message type. Accepted values are
#'   `"generic"`, `"success"`, `"warning"`, `"danger"` or `"info"`.
#'
#' @param verbose A logical. Whether to print the message.
#' @param ... Character strings to be combined into the message.
#'
#' @return
#' Invisibly returns `NULL`. Prints messages to the console if `verbose` is
#' `TRUE`.
#'
#' @noRd
make_msg <- function(type = "generic", verbose, ...) {
  if (!verbose) {
    return(invisible())
  }
  dots <- list(...)
  msg <- paste(dots, collapse = " ")

  alert <- switch(type,
    generic = cli::cli_alert,
    success = cli::cli_alert_success,
    warning = cli::cli_alert_warning,
    danger = cli::cli_alert_danger,
    info = cli::cli_alert_info,
    cli::cli_alert
  )
  alert(msg)
  invisible()
}

#' Match argument with pretty error message
#'
#' @param arg The argument to match.
#' @param choices The possible choices for the argument.
#'
#' @return
#' The matched argument.
#'
#' @noRd
match_arg_pretty <- function(arg, choices) {
  arg_name <- as.character(substitute(arg)) # nolint

  if (missing(choices)) {
    formal_args <- formals(sys.function(sys_par <- sys.parent()))
    choices <- eval(
      formal_args[[as.character(substitute(arg))]],
      envir = sys.frame(sys_par)
    )
  }
  choices <- as.character(choices)

  if (is.null(arg)) {
    return(choices[1L])
  }

  arg <- as.character(arg)

  if (identical(arg, choices)) {
    return(arg[1])
  }

  if (length(arg) == 1 && arg %in% choices) {
    return(arg)
  }

  msg <- paste0(
    "{.arg {arg_name}} must be {.or {.str {choices}}}, not ",
    "{.or {.str {arg}}}."
  )

  hint <- NULL
  if (length(arg) == 1) {
    partial_match <- pmatch(arg, choices)[1]
    if (!is.na(partial_match)) {
      hint <- paste0("Did you mean {.str ", choices[partial_match], "}?")
    }
  }

  cli::cli_abort(c(msg, i = hint), call = NULL)
}

#' Row-bind data frames filling missing columns with `NA`
#'
#' @param a_list A list of data frames or lists to row bind.
#' @return
#' A data frame resulting from row binding the input data frames or `sf`
#' objects.
#'
#' @noRd
rbind_fill <- function(a_list) {
  # Drop NULL entries.
  is_null <- vapply(a_list, is.null, FUN.VALUE = logical(1))
  a_list <- a_list[!is_null]
  if (length(a_list) == 0) {
    return(NULL)
  }
  # Collect all column names across data frames.
  nms <- unique(unlist(lapply(a_list, names)))

  a_list <- lapply(a_list, function(x) {
    for (i in nms[!nms %in% names(x)]) {
      x[[i]] <- NA
    }
    x
  })
  names(a_list) <- NULL
  binded <- do.call(rbind, a_list)
  binded
}

siane_filter_year <- function(data_sf, year = Sys.Date()) {
  mindate <- min(data_sf$fecha_alta)
  maxdate <- Sys.Date() + 1
  year <- as.character(year)
  sel_date <- as.character(year)

  if (nchar(year) != 10) {
    sel_date <- paste(year, "12", "31", sep = "-")
  }

  if (nchar(sel_date) != 10) {
    cli::cli_abort(paste0(
      "Date {.val {sel_date}} is not valid. ",
      "Use the {.val YYYY} or {.val YYYY-MM-DD} format. ",
      "See {.fn base::as.Date}."
    ))
  }

  sel_date <- as.Date(sel_date, tryFormats = "%Y-%m-%d")

  check_date_range <- mindate <= sel_date & sel_date <= maxdate

  if (!check_date_range) {
    cli::cli_abort(paste0(
      "Year or date {.val {year}} is not available. Use a value between ",
      "{.val {mindate}} and {.val {maxdate}}."
    ))
  }

  df <- data_sf
  # Filter rows to those valid at the selected date.
  fecha_alta <- df$fecha_alta
  fecha_bajamod <- df$fecha_baja
  fecha_bajamod[is.na(fecha_bajamod)] <- maxdate

  df <- df[fecha_alta <= sel_date & sel_date <= fecha_bajamod, ]

  df
}
ensure_null <- function(x) {
  x_init <- x
  x <- as.vector(x)
  x[is.null(x)] <- NA
  x[is.na(x)] <- NA
  x[nchar(as.character(x)) == 0] <- NA
  if (all(is.na(x))) {
    return(NULL)
  }

  x_init
}

validate_non_empty_arg <- function(arg, call = parent.frame(1)) {
  arg_name <- as.character(substitute(arg)) # nolint

  if (missing(arg)) {
    cli::cli_abort("{.arg {arg_name}} must be supplied.", call = call)
  }

  arg
}

validate_epsg <- function(epsg, choices = c("4326", "4258", "3035", "3857")) {
  match_arg_pretty(epsg, choices)
}

is_moving_can <- function(moveCAN) {
  isTRUE(moveCAN) | length(moveCAN) > 1
}

merge_db_value_desc <- function(data_sf, field, names) {
  values <- db_valores[db_valores$campo == field, 2:3]
  names(values) <- names

  merge(data_sf, values, all.x = TRUE)
}

return_empty_sf <- function(data_sf, warning, .envir = parent.frame()) {
  cli::cli_alert_warning(warning, .envir = .envir)
  cli::cli_alert_info("Returning empty {.cls sf} object.")
  data_sf
}

return_empty_name_sf <- function(data_sf, name) {
  return_empty_sf(data_sf, "No results for {.arg name} {.str {name}}.")
}

return_empty_combination_sf <- function(data_sf, arg) {
  return_empty_sf(
    data_sf,
    paste0(
      "The selected {.arg region}, {.arg {arg}} or filter combination does ",
      "not return any results."
    )
  )
}

warn_no_spanish_codes <- function(code_type, values) {
  cli::cli_alert_warning(
    "No Spanish {code_type} codes found for {.str {values}}."
  )
}

abort_no_spanish_codes <- function(code_type, values, call = parent.frame()) {
  cli::cli_abort(
    "No Spanish {code_type} codes found for {.str {values}}.",
    call = call
  )
}

warn_no_match <- function(values, destination = NULL) {
  if (is.null(destination)) {
    cli::cli_alert_warning("No match found for {.str {values}}.")
    return(invisible())
  }

  cli::cli_alert_warning(paste0(
    "No match found for {.str {values}} with ",
    "{.arg destination = {.str {destination}}}."
  ))
  invisible()
}

alert_return_null <- function() {
  cli::cli_alert("Returning {.val NULL}.")
  NULL
}

alert_open_issue <- function() {
  cli::cli_alert_warning(c(
    "If you think this is a bug, please consider opening an issue at ",
    "{.url https://github.com/rOpenSpain/mapSpain/issues}"
  ))
}
