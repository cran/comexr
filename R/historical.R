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
#'   `"country"`, `"state"`, `"ncm"` (actually NBM for this period).
#' @param filters Named list of filters.
#' @param month_detail Logical. If `TRUE`, break down by month.
#'   Default: `FALSE`.
#' @param metric_fob Logical. Include FOB value (US$). Default: `TRUE`.
#' @param metric_kg Logical. Include net weight (kg). Default: `TRUE`.
#' @param metric_statistic Logical. Include statistical quantity.
#'   Default: `FALSE`.
#' @param metric_freight Logical. Include freight value (US$). Default: `FALSE`.
#' @param metric_insurance Logical. Include insurance value (US$).
#'   Default: `FALSE`.
#' @param metric_cif Logical. Include CIF value (US$). Default: `FALSE`.
#' @param language Response language: `"pt"`, `"en"`, or `"es"`.
#'   Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `TRUE`.
#'
#' @return A data.frame (or tibble) with query results.
#'
#' @details
#' Historical data differs from general data:
#' - Available period: **1989 to 1996** only
#' - Limited details: `"country"`, `"state"`, `"ncm"`
#' - Product classification is **NBM** (not NCM)
#' - All six metrics are available (FOB, KG, Statistic, Freight, Insurance, CIF)
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
#'
#' # Historical imports with CIF value
#' comex_historical(
#'   flow = "import",
#'   start_period = "1990-01",
#'   end_period = "1992-12",
#'   details = c("ncm", "country"),
#'   metric_cif = TRUE
#' )
#' }
#'
#' @export
comex_historical <- function(flow = "export",
                             start_period,
                             end_period,
                             details = NULL,
                             filters = NULL,
                             month_detail = FALSE,
                             metric_fob = TRUE,
                             metric_kg = TRUE,
                             metric_statistic = FALSE,
                             metric_freight = FALSE,
                             metric_insurance = FALSE,
                             metric_cif = FALSE,
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

  body <- list(
    flow        = flow_api,
    monthDetail = month_detail,
    period      = list(from = start_period, to = end_period),
    filters     = build_filters(filters),
    details     = build_details(details),
    metrics     = build_metrics(
      metric_fob       = metric_fob,
      metric_kg        = metric_kg,
      metric_statistic = metric_statistic,
      metric_freight   = metric_freight,
      metric_insurance = metric_insurance,
      metric_cif       = metric_cif
    )
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
