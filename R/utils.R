# =========================================================================
# Internal utility functions
# =========================================================================

# -------------------------------------------------------------------------
# HTTP helpers
# -------------------------------------------------------------------------

#' Null-coalescing operator (base R only has it from 4.4.0)
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Apply SSL options to request
#'
#' SSL peer verification is only disabled when the user opts in with
#' `options(comexr.ssl_verifypeer = FALSE)` (or the legacy
#' `comex.ssl_verifypeer`).
#' @noRd
comex_req_options <- function(req) {
  verify <- getOption("comexr.ssl_verifypeer",
                      getOption("comex.ssl_verifypeer", TRUE))
  if (isFALSE(verify)) {
    return(req |> httr2::req_options(ssl_verifypeer = 0))
  }
  req
}

#' Perform request, turning SSL failures into an actionable error
#' @noRd
safe_perform <- function(req) {
  tryCatch(
    httr2::req_perform(req),
    error = function(e) {
      # httr2 wraps curl errors: e$message = "Failed to perform HTTP request."
      # The actual SSL message is in e$parent$message
      full_msg <- paste(
        conditionMessage(e),
        if (!is.null(e$parent)) conditionMessage(e$parent) else ""
      )
      if (grepl("SSL|certificate", full_msg, ignore.case = TRUE)) {
        cli::cli_abort(c(
          "x" = "SSL certificate verification failed.",
          "i" = "Some systems do not recognise the API's ICP-Brasil certificate chain.",
          "i" = "To skip verification, run {.code options(comexr.ssl_verifypeer = FALSE)}."
        ), parent = e)
      }
      stop(e)
    }
  )
}

#' Build, perform and parse a request to the ComexStat API
#' @noRd
comex_request <- function(req, endpoint, query, default_timeout) {
  req <- req |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_timeout(getOption("comexr.timeout", default_timeout)) |>
    # 10 seconds appears to be the recommended amount of time based on errors from the API
    httr2::req_retry(
      max_tries = getOption("comexr.max_tries", 3),
      backoff = ~ getOption("comexr.retry_time", 10)
    ) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    comex_req_options()

  # Append query params (dropping NULLs)
  query <- Filter(Negate(is.null), query)
  if (length(query) > 0) {
    req <- do.call(httr2::req_url_query, c(list(req), query))
  }

  resp <- safe_perform(req)
  status <- httr2::resp_status(resp)

  if (status >= 400) {
    body <- tryCatch(
      httr2::resp_body_json(resp),
      error = function(e) list(message = paste("HTTP", status))
    )
    msg <- body$message %||% body$error$message %||% paste("HTTP", status)
    cli::cli_abort(c(
      "x" = "API request failed (HTTP {status})",
      "i" = "Endpoint: {endpoint}",
      "i" = "Message: {msg}"
    ))
  }

  httr2::resp_body_json(resp)
}

#' Perform a GET request to the ComexStat API
#'
#' @param endpoint Relative path (e.g. "/tables/countries").
#' @param query Named list of query-string parameters.
#' @param verbose Logical. Show progress messages.
#' @return Parsed JSON response as a list.
#' @noRd
comex_get <- function(endpoint, query = list(), verbose = TRUE) {
  if (verbose) {
    cli::cli_progress_step("GET {endpoint}")
  }
  req <- httr2::request(paste0(.base_url, endpoint))
  comex_request(req, endpoint, query, default_timeout = 60)
}

#' Perform a POST request to the ComexStat API
#'
#' @param endpoint Relative path (e.g. "/general").
#' @param body List to send as JSON body.
#' @param query Named list of query-string parameters.
#' @param verbose Logical. Show progress messages.
#' @return Parsed JSON response as a list.
#' @noRd
comex_post <- function(endpoint, body, query = list(), verbose = TRUE) {
  if (verbose) {
    cli::cli_progress_step("POST {endpoint}")
  }
  req <- httr2::request(paste0(.base_url, endpoint)) |>
    httr2::req_body_json(body, auto_unbox = TRUE)
  comex_request(req, endpoint, query, default_timeout = 120)
}

# -------------------------------------------------------------------------
# Response conversion
# -------------------------------------------------------------------------

#' Check if an object has meaningful names
#' Handles NULL, character(0), and all-empty-string names
#' @noRd
has_names <- function(x) {
  nm <- names(x)
  !is.null(nm) && length(nm) > 0 && !all(nm == "")
}

#' Convert an API response to a data.frame
#'
#' Handles all known ComexStat API response patterns found empirically:
#'
#' **Pattern 1 — named list with "list" key:**
#' `{"data": {"list": [...rows...], "count": N}}`
#' Used by: `/tables/countries`, `/tables/ncm`, POST `/general`, POST `/cities`,
#' `/general/filters`, `/general/details`, `/general/metrics`, etc.
#'
#' **Pattern 2 — direct unnamed array:**
#' `{"data": [...rows...]}`
#' Used by: `/tables/uf`, `/tables/cities`, `/tables/ways`, `/tables/urf`,
#' POST `/historical-data/`
#'
#' **Pattern 3 — double-wrapped unnamed array:**
#' `{"data": [[...rows...]]}`
#' Used by: `/general/filters/{filter}` (filter values)
#'
#' @param response List returned by the API.
#' @param path Name of the field containing the data. Default: `"data"`.
#' @return A data.frame or tibble.
#' @noRd
response_to_df <- function(response, path = "data") {
  # Step 1: Extract the top-level data field
  data <- if (!is.null(path) && path %in% names(response)) {
    response[[path]]
  } else {
    response
  }

  if (is.null(data) || length(data) == 0) {
    return(data.frame())
  }

  # Step 2: Unwrap nested structures to get a flat list of rows

  # Pattern 1: {"data": {"list": [...], "count": N}}
  if (is.list(data) && has_names(data) && "list" %in% names(data)) {
    data <- data[["list"]]
    if (is.null(data) || length(data) == 0) return(data.frame())
  }

  # Pattern 3: {"data": [[...rows...]]} — unnamed list wrapping rows
  # Keep unwrapping single-element unnamed lists until we reach rows
  while (is.list(data) && !has_names(data) && length(data) == 1 &&
         is.list(data[[1]]) && !is.data.frame(data[[1]])) {
    data <- data[[1]]
  }

  # Check if we ended up with a data.frame after unwrapping
  if (is.data.frame(data)) {
    return(as_comex_df(data))
  }

  # Step 3: Convert list of records to data.frame
  if (is.list(data) && length(data) > 0) {

    # List of rows (each a named list) -> one column per field
    if (is.list(data[[1]]) && has_names(data[[1]])) {
      return(as_comex_df(rows_to_df(data)))
    }

    # Named list that's not a list of rows -> single-row data.frame
    if (has_names(data)) {
      return(as_comex_df(rows_to_df(list(data))))
    }
  }

  data.frame()
}

#' Flatten a JSON value to a length-1 atomic
#' @noRd
scalarize <- function(val) {
  if (is.null(val) || length(val) == 0) {
    NA
  } else if (is.list(val) || length(val) > 1) {
    paste0(unlist(val), collapse = ", ")
  } else {
    val
  }
}

#' Convert a list of records (named lists) to a data.frame, column-wise
#'
#' Fields missing from some records become `NA`. Column names are kept
#' verbatim (no `make.names()` mangling).
#' @noRd
rows_to_df <- function(rows) {
  cols <- unique(unlist(lapply(rows, names), use.names = FALSE))
  cols <- cols[nzchar(cols)]
  out <- lapply(cols, function(nm) {
    unlist(lapply(rows, function(row) scalarize(row[[nm]])),
           use.names = FALSE)
  })
  names(out) <- cols
  list2DF(out, nrow = length(rows))
}

#' Coerce query-result columns to proper types
#'
#' The API returns every value as a JSON string. Metric columns
#' (`metric*`) become double, `year` and `monthNumber` become integer.
#' A column is left untouched if any non-missing value fails to parse.
#' @noRd
convert_query_types <- function(df) {
  if (!is.data.frame(df) || ncol(df) == 0) return(df)
  convert <- function(x, fun) {
    if (!is.character(x)) return(x)
    y <- suppressWarnings(fun(x))
    if (any(is.na(y) & !is.na(x))) x else y
  }
  for (nm in names(df)) {
    if (startsWith(nm, "metric")) {
      df[[nm]] <- convert(df[[nm]], as.numeric)
    } else if (nm %in% c("year", "monthNumber")) {
      df[[nm]] <- convert(df[[nm]], as.integer)
    }
  }
  df
}

#' Extract a single record from an API response
#'
#' Handles all detail endpoint patterns found empirically:
#'
#' **Named object:** `{"data": {"id": 105, "country": "Brasil", ...}}`
#' Used by: `/tables/countries/105`, `/tables/uf/26`, `/tables/cities/5300050`,
#' `/tables/urf/8110000`, `/general/dates/updated`, `/general/dates/years`
#'
#' **Unnamed list of 1:** `{"data": [{"id": "02042200", "text": "..."}]}`
#' Used by: `/tables/ncm/{code}`, `/tables/nbm/{code}`
#'
#' **Named with "list" key:** `{"data": {"list": [{...}], "count": 1}}`
#' (possible but not seen in practice)
#'
#' **NULL:** `{"data": null}`
#' Used by: `/tables/ways/5` (invalid ID)
#'
#' @param response List returned by the API.
#' @return The extracted data (list, character, or NULL).
#' @noRd
extract_single <- function(response) {
  data <- response[["data"]]
  if (is.null(data)) return(NULL)

  # Named list with "list" key: unwrap
  if (is.list(data) && has_names(data) && "list" %in% names(data)) {
    lst <- data[["list"]]
    if (is.null(lst) || length(lst) == 0) return(NULL)
    return(lst[[1]])
  }

  # Unnamed list: unwrap first element
  # Covers NCM/NBM detail: {"data": [{"id": "02042200", ...}]}
  if (is.list(data) && !has_names(data) && length(data) >= 1) {
    return(data[[1]])
  }

  # Named object or scalar: return directly
  data
}

#' Convert to tibble if available, otherwise data.frame
#' @noRd
as_comex_df <- function(df) {
  if (requireNamespace("tibble", quietly = TRUE)) {
    tibble::as_tibble(df)
  } else {
    df
  }
}

# -------------------------------------------------------------------------
# Validation
# -------------------------------------------------------------------------

#' Validate period format (YYYY-MM)
#' @noRd
validate_period <- function(start_period, end_period) {
  pattern <- "^\\d{4}-(0[1-9]|1[0-2])$"

  if (!is_period(start_period, pattern)) {
    cli::cli_abort(c(
      "x" = "Invalid start period: {start_period}",
      "i" = "Use format 'YYYY-MM' (e.g. '2023-01')"
    ))
  }

  if (!is_period(end_period, pattern)) {
    cli::cli_abort(c(
      "x" = "Invalid end period: {end_period}",
      "i" = "Use format 'YYYY-MM' (e.g. '2023-12')"
    ))
  }

  if (start_period > end_period) {
    cli::cli_abort("Start period must be before or equal to end period.")
  }

  invisible(TRUE)
}

#' @noRd
is_period <- function(x, pattern) {
  is.character(x) && length(x) == 1 && !is.na(x) && grepl(pattern, x)
}

#' Convert flow argument to API format
#' @noRd
convert_flow <- function(flow) {
  if (!is.character(flow) || length(flow) != 1 || is.na(flow)) {
    cli::cli_abort("{.arg flow} must be a single string: 'export' or 'import'.")
  }
  fl <- tolower(flow)
  if (fl %in% c("exp", "export", "exports")) return("export")
  if (fl %in% c("imp", "import", "imports")) return("import")
  cli::cli_abort(c(
    "x" = "Invalid flow: {flow}",
    "i" = "Use 'export' or 'import'"
  ))
}

# -------------------------------------------------------------------------
# Name mappings (user-friendly -> API names)
# -------------------------------------------------------------------------

#' API filter/detail names verified against the live endpoints
#' (/general/filters, /general/details, /cities/filters,
#' /historical-data/filters) on 2026-05-21.
#' @noRd
.details_map <- c(
  # Geographic
  country        = "country",
  bloc           = "economicBlock",
  economic_block = "economicBlock",
  economicBlock  = "economicBlock",
  state          = "state",
  city           = "city",
  transport_mode = "via",
  via            = "via",
  customs_unit   = "urf",
  urf            = "urf",
  # Products - NCM and Harmonized System (HS2/HS4/HS6)
  ncm            = "ncm",
  hs6            = "subHeading",
  sh6            = "subHeading",
  subheading     = "subHeading",
  subHeading     = "subHeading",
  hs4            = "heading",
  sh4            = "heading",
  heading        = "heading",
  hs2            = "chapter",
  sh2            = "chapter",
  chapter        = "chapter",
  section        = "section",
  # CGCE (a.k.a. BEC - Broad Economic Categories)
  cgce_n1        = "BECLevel1",
  cgce_n2        = "BECLevel2",
  cgce_n3        = "BECLevel3",
  BECLevel1      = "BECLevel1",
  BECLevel2      = "BECLevel2",
  BECLevel3      = "BECLevel3",
  # SITC / CUCI
  sitc_section      = "SITCSection",
  sitc_division     = "SITCDivision",
  sitc_chapter      = "SITCDivision",
  sitc_group        = "SITCGroup",
  sitc_position     = "SITCGroup",
  sitc_subgroup     = "SITCSubGroup",
  sitc_subposition  = "SITCSubGroup",
  sitc_basic_heading = "SITCBasicHeading",
  sitc_item         = "SITCBasicHeading",
  SITCSection       = "SITCSection",
  SITCDivision      = "SITCDivision",
  SITCGroup         = "SITCGroup",
  SITCSubGroup      = "SITCSubGroup",
  SITCBasicHeading  = "SITCBasicHeading",
  # ISIC
  isic_section   = "ISICSection",
  isic_division  = "ISICDivision",
  isic_group     = "ISICGroup",
  isic_class     = "ISICClass",
  ISICSection    = "ISICSection",
  ISICDivision   = "ISICDivision",
  ISICGroup      = "ISICGroup",
  ISICClass      = "ISICClass",
  # NBM (historical)
  nbm            = "nbm"
)

#' Convert user-friendly name to API name
#' @noRd
get_api_name <- function(name) {
  if (name %in% names(.details_map)) return(unname(.details_map[[name]]))
  if (name %in% .details_map) return(name)
  cli::cli_warn("Unknown detail/filter: {name}. Will be sent as-is.")
  name
}

#' Build details list for the API
#' @noRd
build_details <- function(details) {
  if (is.null(details) || length(details) == 0) return(list())
  as.list(vapply(details, get_api_name, character(1), USE.NAMES = FALSE))
}

#' Build filters list for the API
#' @noRd
build_filters <- function(filters) {
  if (is.null(filters) || length(filters) == 0) return(list())
  nm <- names(filters)
  if (!is.list(filters) || is.null(nm) || any(is.na(nm) | !nzchar(nm))) {
    cli::cli_abort(c(
      "x" = "{.arg filters} must be a named list.",
      "i" = "Example: {.code list(country = c(160, 249), state = 26)}"
    ))
  }
  lapply(names(filters), function(nm) {
    list(
      filter = get_api_name(nm),
      values = as.list(filters[[nm]])
    )
  })
}

#' Build metrics vector for the API
#' @noRd
build_metrics <- function(metric_fob = TRUE,
                          metric_kg = TRUE,
                          metric_statistic = FALSE,
                          metric_freight = FALSE,
                          metric_insurance = FALSE,
                          metric_cif = FALSE) {
  metrics <- character()
  if (metric_fob)       metrics <- c(metrics, "metricFOB")
  if (metric_kg)        metrics <- c(metrics, "metricKG")
  if (metric_statistic) metrics <- c(metrics, "metricStatistic")
  if (metric_freight)   metrics <- c(metrics, "metricFreight")
  if (metric_insurance) metrics <- c(metrics, "metricInsurance")
  if (metric_cif)       metrics <- c(metrics, "metricCIF")

  if (length(metrics) == 0) {
    cli::cli_abort("At least one metric must be selected.")
  }

  as.list(metrics)
}
