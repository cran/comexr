## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----install------------------------------------------------------------------
# # Install from GitHub:
# remotes::install_github("StrategicProjects/comexr")

## ----discover-----------------------------------------------------------------
# library(comex)
# 
# # What is the most recent data available?
# comex_last_update("general")
# #> $updated
# #> [1] "2026-02-05"
# #> $year
# #> [1] "2026"
# #> $monthNumber
# #> [1] "01"
# 
# # What years are covered?
# comex_available_years("general")
# #> $max
# #> [1] "2026"
# #> $min
# #> [1] "1997"
# 
# # What detail/grouping fields can I use?
# comex_details("general")
# #> # A tibble: 22 × 2
# #>    filter        text
# #>    <chr>         <chr>
# #>  1 country       Countries
# #>  2 economicBlock Economic Blocks
# #>  3 state         States
# #>  4 ...

## ----simple_query-------------------------------------------------------------
# # Top export destinations in January 2024
# exports <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-01",
#   details      = "country"
# )
# 
# exports
# #> # A tibble: 219 × 4
# #>    year  country                   metricFOB metricKG
# #>    <chr> <chr>                         <dbl>    <dbl>
# #>  1 2024  China                    7812623070    ...
# #>  2 2024  United States            3254810234    ...
# #>  3 2024  Argentina                 916456789    ...
# #>  ...

## ----filtered_query-----------------------------------------------------------
# # Exports to China and USA, broken down by HS4 product group
# exports_filtered <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-06",
#   details      = c("country", "hs4"),
#   filters      = list(country = c(160, 249)),
#   month_detail = TRUE
# )

## ----tables-------------------------------------------------------------------
# # All countries
# countries <- comex_countries()
# countries
# #> # A tibble: 281 × 2
# #>    id    text
# #>    <chr> <chr>
# #>  1 994   A Designar
# #>  2 132   Afeganistão
# #>  ...
# 
# # Search for a specific country
# comex_countries(search = "Brazil")

## ----language-----------------------------------------------------------------
# comex_blocs(language = "pt")
# #> # A tibble: 12 × 2
# #>    id    text
# #>    <chr> <chr>
# #>  1 105   América Central e Caribe
# #>  2 107   América do Norte
# #>  ...
# 
# comex_blocs(language = "en")
# #> # A tibble: 12 × 2
# #>    id    text
# #>    <chr> <chr>
# #>  1 105   Central America and Caribbean
# #>  2 107   North America
# #>  ...

