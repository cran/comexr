## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## ----load---------------------------------------------------------------------
# library(comexr)
# 
# city_code <- "2611606"  # Recife - PE (IBGE)
# year_from <- "2024-01"
# year_to   <- "2024-12"

## ----explore-city-------------------------------------------------------------
# comex_filters("city")    # 7 filters
# comex_details("city")    # 7 details (same names as filters)
# comex_metrics("city")    # only FOB and KG

## ----totals-------------------------------------------------------------------
# exports_total <- comex_query_city(
#   flow         = "export",
#   start_period = year_from,
#   end_period   = year_to,
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# 
# imports_total <- comex_query_city(
#   flow         = "import",
#   start_period = year_from,
#   end_period   = year_to,
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# 
# exports_total
# imports_total

## ----balance------------------------------------------------------------------
# balance <- as.numeric(exports_total$metricFOB) -
#            as.numeric(imports_total$metricFOB)

## ----top-countries------------------------------------------------------------
# top_export_countries <- comex_query_city(
#   flow         = "export",
#   start_period = year_from,
#   end_period   = year_to,
#   details      = "country",
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# 
# top_export_countries <- top_export_countries[
#   order(-as.numeric(top_export_countries$metricFOB)),
# ]
# head(top_export_countries, 10)
# 
# top_import_countries <- comex_query_city(
#   flow         = "import",
#   start_period = year_from,
#   end_period   = year_to,
#   details      = "country",
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# top_import_countries <- top_import_countries[
#   order(-as.numeric(top_import_countries$metricFOB)),
# ]
# head(top_import_countries, 10)

## ----top-blocs----------------------------------------------------------------
# exports_by_bloc <- comex_query_city(
#   flow         = "export",
#   start_period = year_from,
#   end_period   = year_to,
#   details      = "bloc",
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# 
# exports_by_bloc <- exports_by_bloc[
#   order(-as.numeric(exports_by_bloc$metricFOB)),
# ]
# exports_by_bloc

## ----top-products-------------------------------------------------------------
# top_export_products <- comex_query_city(
#   flow         = "export",
#   start_period = year_from,
#   end_period   = year_to,
#   details      = "hs4",   # → heading
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# 
# top_export_products <- top_export_products[
#   order(-as.numeric(top_export_products$metricFOB)),
# ]
# head(top_export_products, 10)

## ----top-sections-------------------------------------------------------------
# exports_by_section <- comex_query_city(
#   flow         = "export",
#   start_period = year_from,
#   end_period   = year_to,
#   details      = "section",
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# exports_by_section

## ----monthly------------------------------------------------------------------
# exports_monthly <- comex_query_city(
#   flow         = "export",
#   start_period = year_from,
#   end_period   = year_to,
#   filters      = list(city = city_code),
#   month_detail = TRUE
# )
# exports_monthly  # year, monthNumber, metricFOB, metricKG

## ----monthly-plot-------------------------------------------------------------
# # Example with base R
# exports_monthly$date <- as.Date(
#   sprintf("%s-%s-01", exports_monthly$year, exports_monthly$monthNumber)
# )
# exports_monthly$fob_musd <- as.numeric(exports_monthly$metricFOB) / 1e6
# 
# plot(
#   exports_monthly$date, exports_monthly$fob_musd,
#   type = "b", pch = 19,
#   xlab = "Month", ylab = "Exports (US$ millions)",
#   main = sprintf("Recife - PE exports, %s to %s", year_from, year_to)
# )

## ----yearly-------------------------------------------------------------------
# exports_yearly <- comex_query_city(
#   flow         = "export",
#   start_period = "2019-01",
#   end_period   = "2024-12",
#   filters      = list(city = city_code),
#   month_detail = FALSE
# )
# exports_yearly  # one row per year

## ----drilldown----------------------------------------------------------------
# # 1. Find the top HS4
# top_hs4 <- head(top_export_products, 1)$headingCode
# 
# # 2. Break that product down by destination
# top_destinations_for_product <- comex_query_city(
#   flow         = "export",
#   start_period = year_from,
#   end_period   = year_to,
#   details      = c("country", "hs4"),
#   filters      = list(city = city_code, hs4 = top_hs4),
#   month_detail = FALSE
# )
# top_destinations_for_product

## ----lookup-------------------------------------------------------------------
# recife <- comex_cities()
# recife[grepl("Recife", recife$text, ignore.case = TRUE), ]
# # Use the `id` column (IBGE coMunGeo) in subsequent filters.

## ----detail-------------------------------------------------------------------
# comex_city_detail(2611606)
# #> $coMunGeo  "2611606"
# #> $noMun     "RECIFE"
# #> $noMunMin  "Recife"
# #> $sgUf      "PE"

