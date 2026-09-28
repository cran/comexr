## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## ----load---------------------------------------------------------------------
# library(comexr)

## ----states-------------------------------------------------------------------
# states <- comex_states()
# states[states$uf == "PE", ]
# #>      text id uf
# #>  Pernambuco 26 PE

## ----params-------------------------------------------------------------------
# state_code <- 26                       # Pernambuco
# period_from <- "2026-01"
# period_to   <- "2026-12"               # API returns up to the latest update
# 
# # These names are user-friendly aliases. The package translates each
# # to the underlying API name (see `getting-started` vignette for the
# # full mapping table):
# #   hs4     -> heading
# #   hs2     -> chapter
# detalhes <- c("state", "city", "hs4", "section", "hs2", "country")
# 
# filtros <- list(state = state_code)

## ----fetch--------------------------------------------------------------------
# exp_pe <- comex_query_city(
#   flow         = "export",
#   start_period = period_from,
#   end_period   = period_to,
#   details      = detalhes,
#   filters      = filtros,
#   month_detail = TRUE,
#   metric_fob   = TRUE,
#   metric_kg    = TRUE
# )
# exp_pe$flow <- "export"
# 
# imp_pe <- comex_query_city(
#   flow         = "import",
#   start_period = period_from,
#   end_period   = period_to,
#   details      = detalhes,
#   filters      = filtros,
#   month_detail = TRUE,
#   metric_fob   = TRUE,
#   metric_kg    = TRUE
# )
# imp_pe$flow <- "import"
# 
# pe <- rbind(exp_pe, imp_pe)

## ----preview------------------------------------------------------------------
# str(pe)
# head(pe)

## ----cast---------------------------------------------------------------------
# pe$date <- as.Date(sprintf("%d-%02d-01", pe$year, pe$monthNumber))

## ----monthly------------------------------------------------------------------
# monthly <- aggregate(metricFOB ~ date + flow, data = pe, FUN = sum)
# monthly_wide <- reshape(monthly, idvar = "date", timevar = "flow",
#                         direction = "wide")
# names(monthly_wide) <- c("date", "exports", "imports")
# monthly_wide$balance <- monthly_wide$exports - monthly_wide$imports
# monthly_wide
# 
# # Base-R plot
# with(monthly_wide, {
#   plot(date, exports / 1e6, type = "b", pch = 19, col = "steelblue",
#        ylim = range(c(exports, imports), na.rm = TRUE) / 1e6,
#        xlab = "Month", ylab = "US$ millions",
#        main = "Pernambuco: exports vs imports, 2026")
#   lines(date, imports / 1e6, type = "b", pch = 17, col = "tomato")
#   legend("topleft", legend = c("Exports", "Imports"),
#          col = c("steelblue", "tomato"), pch = c(19, 17), bty = "n")
# })

## ----top-cities---------------------------------------------------------------
# exports_by_city <- aggregate(metricFOB ~ noMunMinsgUf,
#                              data = subset(pe, flow == "export"),
#                              FUN = sum)
# head(exports_by_city[order(-exports_by_city$metricFOB), ], 10)
# 
# imports_by_city <- aggregate(metricFOB ~ noMunMinsgUf,
#                              data = subset(pe, flow == "import"),
#                              FUN = sum)
# head(imports_by_city[order(-imports_by_city$metricFOB), ], 10)

## ----top-hs4------------------------------------------------------------------
# exp_hs4 <- aggregate(
#   metricFOB ~ headingCode + heading,
#   data = subset(pe, flow == "export"),
#   FUN  = sum
# )
# head(exp_hs4[order(-exp_hs4$metricFOB), ], 10)
# 
# imp_hs4 <- aggregate(
#   metricFOB ~ headingCode + heading,
#   data = subset(pe, flow == "import"),
#   FUN  = sum
# )
# head(imp_hs4[order(-imp_hs4$metricFOB), ], 10)

## ----top-partners-------------------------------------------------------------
# exp_country <- aggregate(metricFOB ~ country,
#                          data = subset(pe, flow == "export"),
#                          FUN  = sum)
# head(exp_country[order(-exp_country$metricFOB), ], 10)
# 
# imp_country <- aggregate(metricFOB ~ country,
#                          data = subset(pe, flow == "import"),
#                          FUN  = sum)
# head(imp_country[order(-imp_country$metricFOB), ], 10)

## ----cross-cuts---------------------------------------------------------------
# # Top product for each top destination
# exp_country_hs4 <- aggregate(
#   metricFOB ~ country + heading,
#   data = subset(pe, flow == "export"),
#   FUN  = sum
# )
# exp_country_hs4 <- exp_country_hs4[
#   order(exp_country_hs4$country, -exp_country_hs4$metricFOB),
# ]
# do.call(rbind, lapply(
#   split(exp_country_hs4, exp_country_hs4$country),
#   function(x) head(x, 1)
# ))
# 
# # Top destination for each Pernambuco municipality
# exp_city_country <- aggregate(
#   metricFOB ~ noMunMinsgUf + country,
#   data = subset(pe, flow == "export"),
#   FUN  = sum
# )
# exp_city_country <- exp_city_country[
#   order(exp_city_country$noMunMinsgUf, -exp_city_country$metricFOB),
# ]
# do.call(rbind, lapply(
#   split(exp_city_country, exp_city_country$noMunMinsgUf),
#   function(x) head(x, 1)
# ))

## ----yearly-------------------------------------------------------------------
# yearly_exp <- comex_query_city(
#   flow         = "export",
#   start_period = "2019-01",
#   end_period   = "2026-12",
#   details      = "state",
#   filters      = list(state = state_code),
#   month_detail = FALSE
# )
# yearly_imp <- comex_query_city(
#   flow         = "import",
#   start_period = "2019-01",
#   end_period   = "2026-12",
#   details      = "state",
#   filters      = list(state = state_code),
#   month_detail = FALSE
# )
# yearly_exp$flow <- "export"; yearly_imp$flow <- "import"
# yearly <- rbind(yearly_exp, yearly_imp)
# yearly  # one row per year × flow

## ----adapt--------------------------------------------------------------------
# comex_filter_values("state", type = "city")

