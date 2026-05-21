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
#' @param details Character vector of detail/grouping fields. The city
#'   endpoint accepts only a subset of the general-endpoint fields:
#'
#'   **Geographic:** `"country"`, `"bloc"` (`"economic_block"`), `"state"`,
#'   `"city"`
#'
#'   **Products:** `"hs4"` / `"sh4"` (API: `heading`), `"hs2"` / `"sh2"`
#'   (API: `chapter`), `"section"`
#'
#' @param filters Named list of filters. Accepts the same names as `details`.
#'   Example: `list(city = "3550308", state = "26")`
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
#' City-level data differs from general data:
#' - Full NCM is **not** available; product detail goes only down to HS4
#'   (heading). HS6 (subheading) is also **not** available.
#' - Classifications like CGCE, SITC, and ISIC are **not** available
#' - Transport mode (`via`) and customs unit (`urf`) are **not** available
#' - Only **FOB** and **KG** metrics are supported; statistical quantity,
#'   freight, insurance, and CIF metrics are **not** available
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
                             month_detail = TRUE,
                             metric_fob = TRUE,
                             metric_kg = TRUE,
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

  # City endpoint supports only FOB and KG (per /cities/metrics)
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

  data <- comex_post("/cities", body,
                     query = list(language = language), verbose = verbose)
  result <- response_to_df(data)

  if (verbose && nrow(result) > 0) {
    cli::cli_alert_success("{nrow(result)} records found")
  }

  result
}
