# comexr 0.3.0

## Breaking Changes

* Many user-friendly detail/filter aliases now map to the correct API
  names. Previous releases sent names that the ComexStat API rejects
  with HTTP 400 "Invalid detail item". Behaviour now matches the live
  API as verified against `/general/details` and `/general/filters`:
    - `"transport_mode"` → `via` (was `transportMode`)
    - `"hs6"` / `"sh6"` → `subHeading` (was `sh6`)
    - `"hs4"` / `"sh4"` → `heading` (was `sh4`)
    - `"hs2"` / `"sh2"` → `chapter` (was `sh2`)
    - `"cgce_n1"`/`"cgce_n2"`/`"cgce_n3"` → `BECLevel1`/`2`/`3`
    - `"sitc_*"` / `"cuci_*"` → `SITCSection`/`SITCDivision`/`SITCGroup`/
      `SITCSubGroup`/`SITCBasicHeading`
    - `"isic_*"` → `ISICSection`/`ISICDivision`/`ISICGroup`/`ISICClass`
* `comex_query_city()`: removed `metric_statistic` parameter. The
  city endpoint only supports `metricFOB` and `metricKG`.
* `comex_isic()`: rewritten to query `/general/filters/ISIC*` (the only
  place the API exposes ISIC values). Now takes a `level` argument
  (`"section"`, `"division"`, `"group"`, `"class"`) and no longer
  duplicates `comex_sitc()` output.

## Bug Fixes

* Removed `"company_size"` from documented details — the API does not
  support a company-size detail/filter.

## Documentation

* `comex_query()`: detail list rewritten to show the user-friendly
  alias **and** the underlying API name for every option.
* `comex_query_city()`: corrected — HS6 (subheading) is **not**
  available for the city endpoint; product detail goes only down to
  HS4 (heading). Added `bloc`/`economic_block` to documented details.
* `comex_historical()`: documented the available filter names
  (`country`, `bloc`, `state`, `nbm`).
* `comex_filter_values()`: clarified that the `filter` argument is
  case-sensitive and must match `comex_filters()` output verbatim
  (e.g. `"BECLevel1"`, `"SITCSection"`, `"ISICSection"`).
* New vignette `city-profile`: reproduces the panels of the public
  ComexStat municipality page (`comexstat.mdic.gov.br/{lang}/municipio/`)
  — totals, top countries, top blocs, top HS4 products, monthly time
  series, year-over-year — using `comex_query_city()`.
* New vignette `state-trade-profile`: full state-level extract
  (Pernambuco example) combining the "By Municipality" panel filters
  — exports + imports, monthly detail, state filter, details by
  state / city / HS4 / section / HS2 / country — and showing how to
  derive trade balance, top municipalities, top products, top
  partners and year-over-year comparisons from the result.

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
