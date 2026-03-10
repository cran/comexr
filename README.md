
# comexr <img src="man/figures/logo.svg" align="right" height="139" alt="comex logo" />

<!-- badges: start -->
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/StrategicProjects/comexr)
![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/comexr)  
![CRAN Downloads](https://cranlogs.r-pkg.org/badges/grand-total/comexr)
  ![License](https://img.shields.io/badge/license-MIT-darkviolet.svg) 
![](https://img.shields.io/badge/dev%20version-0.2.0-blue.svg)
<!-- badges: end -->

R client for the [ComexStat API](https://comexstat.mdic.gov.br/) — Brazilian
foreign trade statistics from the Ministry of Development, Industry, Trade and
Services (MDIC).

## Features

- **30 functions** covering all 38 API endpoints
- **General trade data** (1997–present), **city-level** data, and **historical** records (1989–1996)
- **Auxiliary tables**: countries, economic blocs, NCM/NBM/HS product codes, CGCE/SITC/ISIC classifications, states, cities, transport modes, customs units
- **Multilingual**: Portuguese, English, Spanish
- User-friendly parameter names mapped automatically to API names

## Installation

```r
# From GitHub
remotes::install_github("StrategicProjects/comexr")
```

## Quick start

```r
library(comexr)

# Top export destinations in January 2024
exports <- comex_export(
  start_period = "2024-01",
  end_period   = "2024-01",
  details      = "country"
)
exports
#> # A tibble: 219 × 4
#>    year  country          metricFOB    metricKG
#>    <chr> <chr>                <dbl>       <dbl>
#>  1 2024  China           7812623070 19868234567
#>  2 2024  United States   3254810234  2547891234
#>  ...

# Imports with CIF value
imports <- comex_import(
  start_period = "2024-01",
  end_period   = "2024-01",
  details      = "country",
  metric_cif   = TRUE
)

# Filter: exports to China (160), grouped by HS4
soy <- comex_export(
  start_period = "2024-01",
  end_period   = "2024-12",
  details      = c("country", "hs4"),
  filters      = list(country = 160),
  month_detail = TRUE
)
```

## Discover available options

```r
# What grouping fields are available?
comex_details("general")

# What filters can I use?
comex_filters("general")

# Look up country codes
comex_countries(search = "China")

# Economic blocs in Portuguese
comex_blocs(language = "pt")
```

## Function overview

| Category | Functions |
|---|---|
| **Queries** | `comex_query()`, `comex_export()`, `comex_import()`, `comex_query_city()`, `comex_historical()` |
| **Metadata** | `comex_last_update()`, `comex_available_years()`, `comex_filters()`, `comex_filter_values()`, `comex_details()`, `comex_metrics()` |
| **Geography** | `comex_countries()`, `comex_country_detail()`, `comex_blocs()`, `comex_states()`, `comex_state_detail()`, `comex_cities()`, `comex_city_detail()`, `comex_transport_modes()`, `comex_transport_mode_detail()`, `comex_customs_units()`, `comex_customs_unit_detail()` |
| **Products** | `comex_ncm()`, `comex_ncm_detail()`, `comex_nbm()`, `comex_nbm_detail()`, `comex_hs()` |
| **Classifications** | `comex_cgce()`, `comex_sitc()`, `comex_isic()` |

## Documentation

- `vignette("getting-started")` — overview and first steps
- `vignette("querying-trade-data")` — advanced query patterns
- `vignette("auxiliary-tables")` — browsing product codes and classifications

## API Reference

This package wraps the official ComexStat API documented at
<https://api-comexstat.mdic.gov.br/docs>.

## License

MIT
