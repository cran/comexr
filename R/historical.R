# =========================================================================
# Historical foreign trade data queries (POST /historical-data/)
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
#' @param details Character vector of detail/grouping fields. Options:
#'   `"country"`, `"state"`, `"nbm"`.
#' @param filters Named list of filters.
#' @param month_detail Logical. If `TRUE`, break down by month.
#'   Default: `TRUE`.
#' @param metric_fob Logical. Include FOB value (US$). Default: `TRUE`.
#' @param metric_kg Logical. Include net weight (kg). Default: `TRUE`.
#' @param language Response language: `"pt"`, `"en"`, or `"es"`.
#'   Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `TRUE`.
#'
#' @return A data.frame (or tibble) with query results.
#'
#' @details
#' Historical data differs from general data:
#' - Available period: **1989 to 1996** only
#' - Limited details: `"country"`, `"state"`, `"nbm"`
#' - Product classification is **NBM** (not NCM)
#' - Only **FOB and KG** metrics are available (no statistic, freight,
#'   insurance, or CIF)
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

  # Note: the API spec defines this endpoint with a trailing slash
  data <- comex_post("/historical-data/", body,
                     query = list(language = language), verbose = verbose)
  result <- response_to_df(data)

  if (verbose && nrow(result) > 0) {
    cli::cli_alert_success("{nrow(result)} records found")
  }

  result
}
