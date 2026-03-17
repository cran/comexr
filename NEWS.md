# comexr 0.2.0

## Breaking Changes

* `comex_historical()` no longer accepts `metric_statistic`, `metric_freight`,
  `metric_insurance`, or `metric_cif` parameters. The historical API endpoint
  only supports FOB and KG metrics.
* `month_detail` default changed from `FALSE` to `TRUE` in all query functions.

## Bug Fixes

* Fixed `bloc` detail mapping: now correctly maps to `economicBlock` (API name).
* Added missing detail mappings: `heading`, `chapter` (city endpoint),
  `nbm` (historical endpoint), `economic_block` (alias).
* Fixed `comex_metrics("general")` returning 0 rows when the `depends` field
  contained NULL values.
* Fixed `comex_ncm_detail()`, `comex_nbm_detail()`, and other detail functions
  returning empty lists instead of named lists.
* Fixed `comex_historical()` endpoint path (added required trailing slash).
* Fixed `response_to_tibble()` failing on responses containing NULL or nested
  list values in row fields.

## New Features

* SSL auto-fallback: the package now detects SSL certificate failures
  (common with the ICP-Brasil chain) and automatically retries without
  verification, issuing a one-time warning. Set
  `options(comex.ssl_verifypeer = FALSE)` to suppress.

## Documentation

* Corrected `comex_query_city()` documentation: city endpoint uses
  `heading`, `chapter`, `section` — not `hs4`, `hs2`, `hs6`.
* Corrected `comex_historical()` documentation: only `country`, `state`,
  and `nbm` details are available (not `ncm` or `section`).
* Updated `comex_filter_values()` documentation with the actual filters
  that have value endpoints (6 for general, 7 for city, 2 for historical).
* Renamed package from `comex` to `comexr`.

# comexr 0.1.0

## Initial Release

* 30 exported functions covering all ComexStat API endpoints.
* General trade queries: `comex_query()`, `comex_export()`, `comex_import()`.
* City-level queries: `comex_query_city()`.
* Historical queries (1989-1996): `comex_historical()`.
* Metadata: `comex_last_update()`, `comex_available_years()`, `comex_filters()`,
  `comex_filter_values()`, `comex_details()`, `comex_metrics()`.
* Auxiliary tables for geography, products, and classifications.
