## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----countries----------------------------------------------------------------
# library(comexr)
# 
# # Full list (281 entries)
# countries <- comex_countries()
# countries
# #> # A tibble: 281 × 2
# #>    id    text
# #>    <chr> <chr>
# #>  1 994   A Designar
# #>  2 132   Afeganistão
# #>  3 175   Albânia
# #>  ...
# 
# # Search by name
# comex_countries(search = "United")
# #> # A tibble: 5 × 2
# #>    id    text
# #>    <chr> <chr>
# #>  1 249   Estados Unidos
# #>  2 ...

## ----country_detail-----------------------------------------------------------
# comex_country_detail(105)
# #> $id
# #> [1] "105"
# #> $country
# #> [1] "Brasil"
# #> $coPaisIson3
# #> [1] "076"
# #> $coPaisIsoa3
# #> [1] "BRA"

## ----blocs--------------------------------------------------------------------
# # In Portuguese
# comex_blocs(language = "pt")
# #> # A tibble: 12 × 2
# #>    id    text
# #>    <chr> <chr>
# #>  1 105   América Central e Caribe
# #>  2 107   América do Norte
# #>  3 48    América do Sul
# #>  ...
# 
# # In English
# comex_blocs(language = "en")

## ----blocs_add----------------------------------------------------------------
# comex_blocs(language = "en", add = TRUE)

## ----states-------------------------------------------------------------------
# states <- comex_states()
# states
# #> # A tibble: 34 × 3
# #>    text              id    uf
# #>    <chr>             <chr> <chr>
# #>  1 Acre              12    AC
# #>  2 Alagoas           27    AL
# #>  3 Amapá             16    AP
# #>  ...
# 
# # Detail for a specific state
# comex_state_detail(26)
# #> $coUf
# #> [1] "26"
# #> $sgUf
# #> [1] "PE"
# #> $noUf
# #> [1] "Pernambuco"
# #> $noRegiao
# #> [1] "REGIAO NORDESTE"

## ----cities-------------------------------------------------------------------
# # Full list (5,570 municipalities)
# cities <- comex_cities()
# cities
# #> # A tibble: 5,570 × 3
# #>    id      text                   noMunMin
# #>    <chr>   <chr>                  <chr>
# #>  1 5300050 Abadia de Goiás - GO   Abadia de Goiás
# #>  ...
# 
# # Detail for a specific city
# comex_city_detail(2611606)
# #> $coMunGeo
# #> [1] "2611606"
# #> $noMun
# #> [1] "RECIFE"
# #> $noMunMin
# #> [1] "Recife"
# #> $sgUf
# #> [1] "PE"

## ----transport----------------------------------------------------------------
# comex_transport_modes()
# #> # A tibble: 17 × 2
# #>    id    text
# #>    <chr> <chr>
# #>  1 00    VIA NAO DECLARADA
# #>  2 01    MARITIMA
# #>  3 02    FLUVIAL
# #>  4 04    AEREA
# #>  5 05    POSTAL
# #>  ...
# 
# # Note: use string codes with leading zeros
# comex_transport_mode_detail("01")
# #> $coVia
# #> [1] "01"
# #> $noVia
# #> [1] "MARITIMA"

## ----customs------------------------------------------------------------------
# customs <- comex_customs_units()
# customs
# #> # A tibble: 278 × 2
# #>    id      text
# #>    <chr>   <chr>
# #>  1 0000000 0000000 - NAO INFORMADO
# #>  2 0117600 0117600 - ALF - PORTO DE MANAUS
# #>  ...
# 
# comex_customs_unit_detail(817600)

## ----ncm----------------------------------------------------------------------
# # Paginated — use page and per_page
# ncm <- comex_ncm(language = "en", page = 1, per_page = 10)
# ncm
# #> # A tibble: 10 × 3
# #>    noNCM                       unit     coNcm
# #>    <chr>                       <chr>    <chr>
# #>  1 Adhesives based on rubber   KILOGRAM 35069110
# #>  ...
# 
# # Search by keyword
# comex_ncm(language = "en", search = "soybean")
# 
# # Get detail for a specific NCM code
# comex_ncm_detail("02042200")
# #> $id
# #> [1] "02042200"
# #> $text
# #> [1] "Outras peças não desossadas de ovino, frescas ou refrigeradas"

## ----nbm----------------------------------------------------------------------
# nbm <- comex_nbm(language = "en", page = 1, per_page = 5)
# nbm
# #> # A tibble: 5 × 2
# #>    nbm                                    coNbm
# #>    <chr>                                  <chr>
# #>  1 3-IODO-1-PROPENO (IODETO DE ALILA)    2903300305
# #>  ...
# 
# comex_nbm_detail("2924101100")
# #> $coNBM
# #> [1] "2924101100"
# #> $noNBM
# #> [1] "ETILENO BIS ESTEARAMIDA"

## ----hs-----------------------------------------------------------------------
# hs <- comex_hs(language = "en", page = 1, per_page = 5)
# hs
# #> # A tibble: 5 × 6
# #>    subHeadingCode subHeading                     headingCode heading
# #>    <chr>          <chr>                          <chr>       <chr>
# #>  1 010110         Pure-bred breeding horses ...  0101        Live horses, ...
# #>  ...

## ----cgce---------------------------------------------------------------------
# cgce <- comex_cgce(language = "en", page = 1, per_page = 5)
# cgce
# #> # A tibble: 5 × 6
# #>    coBECLevel3 BECLevel3                       coBECLevel2 BECLevel2
# #>    <chr>       <chr>                           <chr>       <chr>
# #>  1 110         Capital goods, except indust... 11          Capital goods, exce...
# #>  ...

## ----sitc---------------------------------------------------------------------
# sitc <- comex_sitc(language = "en", page = 1, per_page = 3)
# sitc
# #> # A tibble: 3 × 10
# #>    coSITCBasicHeading SITCBasicHeading coSITCSubGroup SITCSubGroup ...
# #>    <chr>              <chr>            <chr>          <chr>        ...
# #>  1 I                  Gold, monetary   9710           Gold, non-m... ...
# #>  ...

## ----isic---------------------------------------------------------------------
# isic <- comex_isic(language = "en", page = 1, per_page = 5)

## ----lookup_workflow----------------------------------------------------------
# # 1. Find country code for Argentina
# countries <- comex_countries(search = "Argentina")
# # id = "021"
# 
# # 2. Find state code for Rio Grande do Sul
# states <- comex_states()
# # RS = id "43"
# 
# # 3. Query: Exports from RS to Argentina, grouped by HS4
# result <- comex_export(
#   start_period = "2024-01",
#   end_period   = "2024-12",
#   details      = c("state", "country", "hs4"),
#   filters      = list(
#     country = 21,
#     state   = 43
#   )
# )

## ----pagination---------------------------------------------------------------
# # Get all NCM codes (13,730 entries), 500 at a time
# all_ncm <- list()
# page <- 1
# 
# repeat {
#   batch <- comex_ncm(language = "en", page = page, per_page = 500)
#   if (nrow(batch) == 0) break
#   all_ncm[[page]] <- batch
#   page <- page + 1
# }
# 
# all_ncm_df <- do.call(rbind, all_ncm)
# nrow(all_ncm_df)
# #> [1] 13730

## ----runtime------------------------------------------------------------------
# # What filters can I use for city queries?
# comex_filters("city")
# 
# # What values does filter "state" accept for city queries?
# comex_filter_values("state", type = "city")
# 
# # What metrics are available for historical queries?
# comex_metrics("historical")

