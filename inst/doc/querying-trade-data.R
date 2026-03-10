## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----exports_country----------------------------------------------------------
# library(comexr)
# 
# exports <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-12",
#   details      = "country"
# )
# #> ℹ Querying exports from 2024-01 to 2024-12
# #> ✔ POST /general [580ms]
# #> ✔ 219 records found

## ----imports_cif--------------------------------------------------------------
# imports <- comex_import(
#   start_period = "2024-01",
#   end_period   = "2024-06",
#   details      = "country",
#   metric_cif   = TRUE
# )
# # Returns columns: year, country, metricFOB, metricKG, metricCIF

## ----monthly------------------------------------------------------------------
# monthly <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-06",
#   details      = "country",
#   month_detail = TRUE
# )
# # Now each row also includes a month column

## ----multi_details------------------------------------------------------------
# by_country_product <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-03",
#   details      = c("country", "hs4"),
#   month_detail = TRUE
# )
# # Rows grouped by: year × month × country × HS4 product heading

## ----filtered-----------------------------------------------------------------
# # Step 1: Find the codes for China and USA
# countries <- comex_countries(search = "China")
# # id = 160 (China), 249 (United States)
# 
# # Step 2: Query only exports to these countries
# to_china_usa <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-12",
#   details      = c("country", "section"),
#   filters      = list(country = c(160, 249))
# )

## ----multi_filters------------------------------------------------------------
# # Exports of HS section 02 (Vegetable products) from São Paulo
# sp_veg <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-12",
#   details      = c("state", "hs2"),
#   filters      = list(state = 35, sh2 = "02")
# )

## ----generic------------------------------------------------------------------
# result <- comex_query(
#   flow         = "import",
#   start_period = "2023-01",
#   end_period   = "2023-12",
#   details      = c("country", "ncm"),
#   filters      = list(country = c(160)),
#   month_detail = FALSE,
#   metric_fob   = TRUE,
#   metric_kg    = TRUE,
#   metric_statistic = TRUE,
#   metric_freight   = TRUE,
#   metric_insurance = TRUE,
#   metric_cif       = TRUE,
#   language     = "en"
# )

## ----city_discover------------------------------------------------------------
# # Which details are available for city queries?
# comex_details("city")
# #> # A tibble: 7 × 2
# #>    filter        text
# #>    <chr>         <chr>
# #>  1 country       Countries
# #>  2 economicBlock Economic Blocks
# #>  3 state         States
# #>  4 city          Cities
# #>  5 heading       Headings
# #>  6 chapter       Chapters
# #>  7 section       Sections
# 
# # Which metrics?
# comex_metrics("city")
# #> # A tibble: 2 × 2
# #>    id          text
# #>    <chr>       <chr>
# #>  1 metricFOB   US$ FOB
# #>  2 metricKG    Net Weight (KG)

## ----city_query---------------------------------------------------------------
# # Exports from Pernambuco (state 26) by country
# pe_exports <- comex_query_city(
#   flow         = "export",
#   start_period = "2024-01",
#   end_period   = "2024-12",
#   details      = c("state", "country"),
#   filters      = list(state = 26)
# )
# 
# # Exports from Recife (city 2611606) by product section
# recife <- comex_query_city(
#   flow         = "export",
#   start_period = "2024-01",
#   end_period   = "2024-06",
#   details      = c("city", "section"),
#   filters      = list(city = 2611606)
# )

## ----historical_discover------------------------------------------------------
# comex_available_years("historical")
# #> $max
# #> [1] "1996"
# #> $min
# #> [1] "1989"
# 
# comex_details("historical")
# #> # A tibble: 4 × 2
# #>    filter  text
# #>    <chr>   <chr>
# #>  1 country Countries
# #>  2 state   States
# #>  3 nbm     NBM
# #>  4 section Sections

## ----historical_query---------------------------------------------------------
# # Historical exports by country in 1990
# hist_1990 <- comex_historical(
#   flow         = "export",
#   start_period = "1990-01",
#   end_period   = "1990-12",
#   details      = "country"
# )

## ----post_process-------------------------------------------------------------
# library(dplyr)
# 
# # Top 10 export destinations in 2024 by FOB value
# top10 <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-12",
#   details      = "country"
# ) |>
#   arrange(desc(metricFOB)) |>
#   head(10)
# 
# # Monthly export trend to China
# china_monthly <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-12",
#   details      = "country",
#   filters      = list(country = 160),
#   month_detail = TRUE
# )

