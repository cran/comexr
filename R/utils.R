# =========================================================================
# Internal utility functions
# =========================================================================

# -------------------------------------------------------------------------
# HTTP helpers
# -------------------------------------------------------------------------

#' Apply SSL options to request
#' @noRd
comex_req_options <- function(req) {
  if (isFALSE(getOption("comex.ssl_verifypeer", TRUE))) {
    return(req |> httr2::req_options(ssl_verifypeer = 0))
  }
  req
}

#' Perform request with SSL auto-fallback
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
      if (grepl("SSL|certificate|peer", full_msg, ignore.case = TRUE)) {
        cli::cli_warn(c(
          "!" = "SSL certificate verification failed.",
          "i" = "Retrying without SSL verification.",
          "i" = "To suppress: {.code options(comex.ssl_verifypeer = FALSE)}"
        ))
        options(comex.ssl_verifypeer = FALSE)
        req2 <- req |> httr2::req_options(ssl_verifypeer = 0)
        httr2::req_perform(req2)
      } else {
        stop(e)
      }
    }
  )
}


#' Perform a GET request to the ComexStat API
#'
#' @param endpoint Relative path (e.g. "/tables/countries").
#' @param query Named list of query-string parameters.
#' @param verbose Logical. Show progress messages.
#' @return Parsed JSON response as a list.
#' @noRd
comex_get <- function(endpoint, query = list(), verbose = TRUE) {
  url <- paste0(.base_url, endpoint)

  if (verbose) {
    cli::cli_progress_step("GET {endpoint}")
  }

  req <- httr2::request(url) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_timeout(60) |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2) |>
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

#' Perform a POST request to the ComexStat API
#'
#' @param endpoint Relative path (e.g. "/general").
#' @param body List to send as JSON body.
#' @param query Named list of query-string parameters.
#' @param verbose Logical. Show progress messages.
#' @return Parsed JSON response as a list.
#' @noRd
comex_post <- function(endpoint, body, query = list(), verbose = TRUE) {
  url <- paste0(.base_url, endpoint)

  if (verbose) {
    cli::cli_progress_step("POST {endpoint}")
  }

  req <- httr2::request(url) |>
    httr2::req_headers(
      Accept = "application/json",
      `Content-Type` = "application/json"
    ) |>
    httr2::req_body_json(body, auto_unbox = TRUE) |>
    httr2::req_timeout(120) |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    comex_req_options()

  query <- Filter(Negate(is.null), query)
  if (length(query) > 0) {
    req <- do.call(httr2::req_url_query, c(list(req), query))
  }

  resp <- safe_perform(req)
  status <- httr2::resp_status(resp)

  if (status >= 400) {
    body_err <- tryCatch(
      httr2::resp_body_json(resp),
      error = function(e) list(message = paste("HTTP", status))
    )
    msg <- body_err$message %||% body_err$error$message %||% paste("HTTP", status)
    cli::cli_abort(c(
      "x" = "API request failed (HTTP {status})",
      "i" = "Endpoint: {endpoint}",
      "i" = "Message: {msg}"
    ))
  }

  httr2::resp_body_json(resp)
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

    # Check first element to detect row structure
    first <- data[[1]]
    is_row_list <- is.list(first) && has_names(first)

    if (is_row_list) {
      df <- tryCatch({
        all_names <- unique(unlist(lapply(data, names)))
        rows <- lapply(data, function(row) {
          row_list <- lapply(all_names, function(nm) {
            val <- row[[nm]]
            if (is.null(val)) {
              NA
            } else if (is.list(val)) {
              paste0(val, collapse = ", ")
            } else {
              val
            }
          })
          names(row_list) <- all_names
          as.data.frame(row_list, stringsAsFactors = FALSE)
        })
        do.call(rbind, rows)
      }, error = function(e) {
        data.frame()
      })
      return(as_comex_df(df))
    }

    # Named list that's not a list of rows → single-row data.frame
    if (has_names(data)) {
      df <- tryCatch({
        flat <- lapply(data, function(val) {
          if (is.null(val)) NA
          else if (is.list(val)) paste0(val, collapse = ", ")
          else val
        })
        as.data.frame(flat, stringsAsFactors = FALSE)
      }, error = function(e) data.frame())
      return(as_comex_df(df))
    }
  }

  data.frame()
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
  pattern <- "^\\d{4}-\\d{2}$"

  if (!grepl(pattern, start_period)) {
    cli::cli_abort(c(
      "x" = "Invalid start period: {start_period}",
      "i" = "Use format 'YYYY-MM' (e.g. '2023-01')"
    ))
  }

  if (!grepl(pattern, end_period)) {
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

#' Convert flow argument to API format
#' @noRd
convert_flow <- function(flow) {
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

#' @noRd
.details_map <- c(
  # Geographic
  country        = "country",
  bloc           = "economicBlock",
  economic_block = "economicBlock",
  state          = "state",
  city           = "city",
  transport_mode = "transportMode",
  customs_unit   = "urf",
  # Products - NCM / HS (general)
  ncm            = "ncm",
  hs6            = "sh6",
  sh6            = "sh6",
  hs4            = "sh4",
  sh4            = "sh4",
  hs2            = "sh2",
  sh2            = "sh2",
  section        = "section",
  # Products - city endpoint names
  heading        = "heading",
  chapter        = "chapter",
  # CGCE
  cgce_n1        = "cgceN1",
  cgce_n2        = "cgceN2",
  cgce_n3        = "cgceN3",
  # CUCI / SITC
  sitc_section      = "cuciSection",
  sitc_chapter      = "cuciChapter",
  sitc_position     = "cuciPosition",

  sitc_subposition  = "cuciSubposition",
  sitc_item         = "cuciItem",
  cuci_section      = "cuciSection",
  cuci_chapter      = "cuciChapter",
  cuci_position     = "cuciPosition",
  cuci_subposition  = "cuciSubposition",
  cuci_item         = "cuciItem",
  # ISIC
  isic_section   = "isicSection",
  isic_division  = "isicDivision",
  isic_group     = "isicGroup",
  isic_class     = "isicClass",
  # NBM (historical)
  nbm            = "nbm",
  # Other
  company_size   = "companySize"
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
