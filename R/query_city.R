# =========================================================================
# City-level foreign trade data queries (POST /cities)
# =========================================================================

#' Query city-level foreign trade data
#'
#' @description
#' Query the city endpoint of the ComexStat API. City-level data is more
#' aggregated than general data, with fewer available details and metrics.
#'
#' City information is based on the declarant of exports/imports, not the
#' producer or buyer.
#'
#' @param flow Trade flow: `"export"` or `"import"`.
#' @param start_period Start period in `"YYYY-MM"` format.
#' @param end_period End period in `"YYYY-MM"` format.
#' @param details Character vector of detail/grouping fields. Options:
#'
#'   **Geographic:** `"country"`, `"state"`, `"city"`
#'
#'   **Products:** `"hs6"` (or `"sh6"`), `"hs4"` (or `"sh4"`),
#'   `"hs2"` (or `"sh2"`), `"section"`
#'
#' @param filters Named list of filters.
#'   Example: `list(city = "3550308", state = "26")`
#' @param month_detail Logical. If `TRUE`, break down by month.
#'   Default: `FALSE`.
#' @param metric_fob Logical. Include FOB value (US$). Default: `TRUE`.
#' @param metric_kg Logical. Include net weight (kg). Default: `TRUE`.
#' @param metric_statistic Logical. Include statistical quantity.
#'   Default: `FALSE`.
#' @param language Response language: `"pt"`, `"en"`, or `"es"`.
#'   Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `TRUE`.
#'
#' @return A data.frame (or tibble) with query results.
#'
#' @details
#' City-level data differs from general data:
#' - Full NCM is **not** available (use HS6/SH4/SH2)
#' - Classifications like CGCE, SITC, and ISIC are **not** available
#' - Only FOB, KG, and Statistical quantity metrics are available
#' - Freight, Insurance, and CIF metrics are **not** available
#'
#' @examples
#' \dontrun{
#' # Exports from Pernambuco in 2023
#' comex_query_city(
#'   flow = "export",
#'   start_period = "2023-01",
#'   end_period = "2023-12",
#'   details = c("country", "state"),
#'   filters = list(state = 26)
#' )
#' }
#'
#' @export
comex_query_city <- function(flow = "export",
                             start_period,
                             end_period,
                             details = NULL,
                             filters = NULL,
                             month_detail = FALSE,
                             metric_fob = TRUE,
                             metric_kg = TRUE,
                             metric_statistic = FALSE,
                             language = "en",
                             verbose = TRUE) {

  validate_period(start_period, end_period)
  flow_api <- convert_flow(flow)

  if (verbose) {
    type_label <- if (flow_api == "export") "exports" else "imports"
    cli::cli_alert_info(
      "Querying city-level {type_label} from {start_period} to {end_period}"
    )
  }

  # City endpoint has a limited set of metrics
  metrics <- character()
  if (metric_fob)       metrics <- c(metrics, "metricFOB")
  if (metric_kg)        metrics <- c(metrics, "metricKG")
  if (metric_statistic) metrics <- c(metrics, "metricStatistic")

  if (length(metrics) == 0) {
    cli::cli_abort("At least one metric must be selected.")
  }

  body <- list(
    flow        = flow_api,
    monthDetail = month_detail,
    period      = list(from = start_period, to = end_period),
    filters     = build_filters(filters),
    details     = build_details(details),
    metrics     = as.list(metrics)
  )

  data <- comex_post("/cities", body,
                     query = list(language = language), verbose = verbose)
  result <- response_to_df(data)

  if (verbose && nrow(result) > 0) {
    cli::cli_alert_success("{nrow(result)} records found")
  }

  result
}
