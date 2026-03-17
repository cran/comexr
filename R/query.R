# =========================================================================
# General foreign trade data queries (POST /general)
# =========================================================================

#' Query general foreign trade data
#'
#' @description
#' Query the main ComexStat API endpoint to retrieve Brazilian export and
#' import data. Supports filtering and grouping by multiple classifications
#' such as NCM, Harmonized System, countries, states, etc.
#'
#' Data is available monthly from 1997 to the most recent complete month.
#'
#' @param flow Trade flow: `"export"` or `"import"`.
#' @param start_period Start period in `"YYYY-MM"` format (e.g. `"2023-01"`).
#' @param end_period End period in `"YYYY-MM"` format (e.g. `"2023-12"`).
#' @param details Character vector of detail/grouping fields. Options:
#'
#'   **Geographic:** `"country"`, `"bloc"`, `"state"`, `"city"`,
#'   `"transport_mode"`, `"customs_unit"`
#'
#'   **Products:** `"ncm"`, `"hs6"` (or `"sh6"`), `"hs4"` (or `"sh4"`),
#'   `"hs2"` (or `"sh2"`), `"section"`
#'
#'   **CGCE:** `"cgce_n1"`, `"cgce_n2"`, `"cgce_n3"`
#'
#'   **SITC/CUCI:** `"sitc_section"`, `"sitc_chapter"`, `"sitc_position"`,
#'   `"sitc_subposition"`, `"sitc_item"`
#'
#'   **ISIC:** `"isic_section"`, `"isic_division"`, `"isic_group"`,
#'   `"isic_class"`
#'
#'   **Other:** `"company_size"` (imports only)
#'
#' @param filters Named list of filters. Names should match detail field names.
#'   Example: `list(country = c(160, 249), state = c(26, 13))`
#' @param month_detail Logical. If `TRUE`, break down results by month.
#'   Default: `FALSE`.
#' @param metric_fob Logical. Include FOB value (US$). Default: `TRUE`.
#' @param metric_kg Logical. Include net weight (kg). Default: `TRUE`.
#' @param metric_statistic Logical. Include statistical quantity. Default: `FALSE`.
#' @param metric_freight Logical. Include freight value (US$, imports only).
#'   Default: `FALSE`.
#' @param metric_insurance Logical. Include insurance value (US$, imports only).
#'   Default: `FALSE`.
#' @param metric_cif Logical. Include CIF value (US$, imports only).
#'   Default: `FALSE`.
#' @param language Response language: `"pt"`, `"en"`, or `"es"`.
#'   Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `TRUE`.
#'
#' @return A data.frame (or tibble if available) with query results.
#'
#' @examples
#' \dontrun{
#' # Brazilian exports in 2023, by country
#' comex_query(
#'   flow = "export",
#'   start_period = "2023-01",
#'   end_period = "2023-12",
#'   details = "country"
#' )
#'
#' # Imports 2023 by NCM + country, filtered by specific countries
#' comex_query(
#'   flow = "import",
#'   start_period = "2023-01",
#'   end_period = "2023-12",
#'   details = c("ncm", "country"),
#'   filters = list(country = c(160, 249)),
#'   month_detail = TRUE,
#'   metric_cif = TRUE
#' )
#' }
#'
#' @export
comex_query <- function(flow = "export",
                        start_period,
                        end_period,
                        details = NULL,
                        filters = NULL,
                        month_detail = TRUE,
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

  if (verbose) {
    type_label <- if (flow_api == "export") "exports" else "imports"
    cli::cli_alert_info(
      "Querying {type_label} from {start_period} to {end_period}"
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

  data <- comex_post("/general", body,
                     query = list(language = language), verbose = verbose)
  result <- response_to_df(data)

  if (verbose && nrow(result) > 0) {
    cli::cli_alert_success("{nrow(result)} records found")
  }

  result
}

#' Query exports
#'
#' Shortcut for [comex_query()] with `flow = "export"`.
#'
#' @inheritParams comex_query
#' @return A data.frame (or tibble) with export data.
#'
#' @examples
#' \dontrun{
#' comex_export(
#'   start_period = "2023-01",
#'   end_period = "2023-12",
#'   details = "country"
#' )
#' }
#'
#' @export
comex_export <- function(start_period,
                         end_period,
                         details = NULL,
                         filters = NULL,
                         month_detail = TRUE,
                         metric_fob = TRUE,
                         metric_kg = TRUE,
                         metric_statistic = FALSE,
                         metric_freight = FALSE,
                         metric_insurance = FALSE,
                         metric_cif = FALSE,
                         language = "en",
                         verbose = TRUE) {
  comex_query(
    flow             = "export",
    start_period     = start_period,
    end_period       = end_period,
    details          = details,
    filters          = filters,
    month_detail     = month_detail,
    metric_fob       = metric_fob,
    metric_kg        = metric_kg,
    metric_statistic = metric_statistic,
    metric_freight   = metric_freight,
    metric_insurance = metric_insurance,
    metric_cif       = metric_cif,
    language         = language,
    verbose          = verbose
  )
}

#' Query imports
#'
#' Shortcut for [comex_query()] with `flow = "import"`.
#'
#' @inheritParams comex_query
#' @return A data.frame (or tibble) with import data.
#'
#' @examples
#' \dontrun{
#' comex_import(
#'   start_period = "2023-01",
#'   end_period = "2023-12",
#'   details = "country",
#'   metric_cif = TRUE
#' )
#' }
#'
#' @export
comex_import <- function(start_period,
                         end_period,
                         details = NULL,
                         filters = NULL,
                         month_detail = TRUE,
                         metric_fob = TRUE,
                         metric_kg = TRUE,
                         metric_statistic = FALSE,
                         metric_freight = FALSE,
                         metric_insurance = FALSE,
                         metric_cif = FALSE,
                         language = "en",
                         verbose = TRUE) {
  comex_query(
    flow             = "import",
    start_period     = start_period,
    end_period       = end_period,
    details          = details,
    filters          = filters,
    month_detail     = month_detail,
    metric_fob       = metric_fob,
    metric_kg        = metric_kg,
    metric_statistic = metric_statistic,
    metric_freight   = metric_freight,
    metric_insurance = metric_insurance,
    metric_cif       = metric_cif,
    language         = language,
    verbose          = verbose
  )
}
