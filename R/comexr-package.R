#' comexr: R Client for the ComexStat API
#'
#' @description
#' The `comexr` package provides a complete R interface to the ComexStat API
#' from the Brazilian Ministry of Development, Industry, Trade and Services
#' (MDIC).
#'
#' The API provides Brazilian foreign trade data from 1997 (general data) and
#' from 1989 (historical data), along with auxiliary tables for product
#' nomenclatures, countries, economic classifications, and more.
#'
#' @section Query functions (POST):
#' These functions query aggregated export and import data with configurable
#' filters, details, and metrics:
#'
#' - [comex_query()]: Query general foreign trade data
#' - [comex_export()]: Shortcut for export queries
#' - [comex_import()]: Shortcut for import queries
#' - [comex_query_city()]: Query city-level data
#' - [comex_historical()]: Query historical data (1989-1996)
#'
#' @section API metadata (GET):
#' Functions to retrieve information about the API itself:
#'
#' - [comex_last_update()]: Date of last data update
#' - [comex_available_years()]: Available years for queries
#' - [comex_filters()]: Available filters
#' - [comex_filter_values()]: Possible values for a filter
#' - [comex_details()]: Available detail/grouping fields
#' - [comex_metrics()]: Available metrics
#'
#' @section Auxiliary tables - Geography (GET):
#' - [comex_countries()], [comex_country_detail()]
#' - [comex_blocs()]
#' - [comex_states()], [comex_state_detail()]
#' - [comex_cities()], [comex_city_detail()]
#' - [comex_transport_modes()], [comex_transport_mode_detail()]
#' - [comex_customs_units()], [comex_customs_unit_detail()]
#'
#' @section Auxiliary tables - Products (GET):
#' - [comex_ncm()], [comex_ncm_detail()]
#' - [comex_nbm()], [comex_nbm_detail()]
#' - [comex_hs()]
#'
#' @section Auxiliary tables - Classifications (GET):
#' - [comex_cgce()]
#' - [comex_sitc()]
#' - [comex_isic()]
#'
#' @section Dependencies:
#' The package uses **only two dependencies**:
#' - `httr2` for all HTTP requests (no headless browser needed)
#' - `cli` for formatted console messages
#'
#' @docType package
#' @name comexr-package
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom httr2 request req_headers req_body_json req_method req_perform
#' @importFrom httr2 resp_body_json resp_status req_retry req_timeout req_error
#' @importFrom httr2 req_url_query
#' @importFrom cli cli_abort cli_warn cli_alert_info cli_alert_success
#' @importFrom cli cli_progress_step
## usethis namespace: end
NULL

# ---------------------------------------------------------------------------
# Internal constants
# ---------------------------------------------------------------------------

#' @noRd
.base_url <- "https://api-comexstat.mdic.gov.br"
