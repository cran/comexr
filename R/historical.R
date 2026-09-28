# =========================================================================
# Historical foreign trade data queries (POST /historical-data)
# =========================================================================

#' Query historical foreign trade data (1989-1996)
#'
#' @description
#' Query the historical data endpoint of the ComexStat API to retrieve
#' Brazilian export and import data from 1989 to 1996, before the SISCOMEX
#' system was implemented. Historical data uses the NBM (Brazilian
#' Nomenclature of Goods) classification.
#'
#' @param flow Trade flow: `"export"` or `"import"`.
#' @param start_period Start period in `"YYYY-MM"` format (e.g. `"1990-01"`).
#' @param end_period End period in `"YYYY-MM"` format (e.g. `"1996-12"`).
#' @param details Character vector of detail/grouping fields. The historical
#'   endpoint supports only: `"country"`, `"bloc"` (`"economic_block"`),
#'   `"state"`, `"nbm"`.
#' @param filters Named list of filters. Accepts the same names as `details`
#'   (`"country"`, `"bloc"`, `"state"`, `"nbm"`).
#' @param month_detail Logical. If `TRUE`, break down by month.
#'   Default: `TRUE`.
#' @param metric_fob Logical. Include FOB value (US$). Default: `TRUE`.
#' @param metric_kg Logical. Include net weight (kg). Default: `TRUE`.
#' @param language Response language: `"pt"`, `"en"`, or `"es"`.
#'   Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `TRUE`.
#'
#' @return A data.frame (or tibble if available) with query results.
#'   Metric columns (`metricFOB`, `metricKG`, ...) are numeric and
#'   `year` / `monthNumber` are integer; all other columns are character.
#'
#' @details
#' Historical data differs from general data:
#' - Available period: **1989 to 1996** only
#' - Limited details: `"country"`, `"state"`, `"nbm"`
#' - Product classification is **NBM** (not NCM)
#' - Only **FOB and KG** metrics are available (no statistic, freight,
#'   insurance, or CIF)
#' - The API ignores the months in the period and always returns whole
#'   years. With `month_detail = TRUE` the result is trimmed to the
#'   requested months; with `month_detail = FALSE` the yearly totals cover
#'   full years and a warning is issued if the period is not whole years.
#'
#' @examples
#' \dontrun{
#' # Historical exports 1995-1996 by country
#' comex_historical(
#'   flow = "export",
#'   start_period = "1995-01",
#'   end_period = "1996-12",
#'   details = "country"
#' )
#' }
#'
#' @export
comex_historical <- function(flow = "export",
                             start_period,
                             end_period,
                             details = NULL,
                             filters = NULL,
                             month_detail = TRUE,
                             metric_fob = TRUE,
                             metric_kg = TRUE,
                             language = "en",
                             verbose = TRUE) {

  validate_period(start_period, end_period)
  flow_api <- convert_flow(flow)

  start_year <- as.integer(substr(start_period, 1, 4))
  end_year   <- as.integer(substr(end_period, 1, 4))

  if (start_year < 1989 || end_year > 1996) {
    cli::cli_warn(c(
      "!" = "Historical data is available from 1989 to 1996.",
      "i" = "Requested period: {start_period} to {end_period}"
    ))
  }

  if (verbose) {
    type_label <- if (flow_api == "export") "exports" else "imports"
    cli::cli_alert_info(
      "Querying historical {type_label} from {start_period} to {end_period}"
    )
  }

  # Historical endpoint only supports FOB and KG metrics
  metrics <- character()
  if (metric_fob) metrics <- c(metrics, "metricFOB")
  if (metric_kg)  metrics <- c(metrics, "metricKG")
  if (length(metrics) == 0) {
    cli::cli_abort("At least one metric must be selected (metric_fob or metric_kg).")
  }

  body <- list(
    flow        = flow_api,
    monthDetail = month_detail,
    period      = list(from = start_period, to = end_period),
    filters     = build_filters(filters),
    details     = build_details(details),
    metrics     = as.list(metrics)
  )

  # No trailing slash: "/historical-data/" is blocked by Cloudflare (HTTP 403)
  data <- comex_post("/historical-data", body,
                     query = list(language = language), verbose = verbose)
  result <- convert_query_types(response_to_df(data))

  # The endpoint ignores the months in `period` and always returns whole
  # years, so trim to the requested months when they are available.
  whole_years <- substr(start_period, 6, 7) == "01" &&
    substr(end_period, 6, 7) == "12"
  if (!whole_years) {
    if (all(c("year", "monthNumber") %in% names(result))) {
      ym <- sprintf("%04d-%02d", as.integer(result$year),
                    as.integer(result$monthNumber))
      result <- result[ym >= start_period & ym <= end_period, , drop = FALSE]
    } else {
      cli::cli_warn(c(
        "!" = "The historical endpoint only aggregates whole years.",
        "i" = "Results cover {substr(start_period, 1, 4)}-01 to {substr(end_period, 1, 4)}-12.",
        "i" = "Use {.code month_detail = TRUE} to restrict to the requested months."
      ))
    }
  }

  if (verbose && nrow(result) > 0) {
    cli::cli_alert_success("{nrow(result)} records found")
  }

  result
}
