# =========================================================================
# Product classification auxiliary tables
# (GET /tables/ncm, /tables/nbm, /tables/hs)
# =========================================================================

# ---- NCM - Mercosur Common Nomenclature ---------------------------------

#' Get NCM (Mercosur Common Nomenclature) table
#'
#' Returns the NCM codes table with descriptions. NCM is the product
#' classification used by Mercosur countries, based on the Harmonized
#' System (HS) with 8 digits.
#'
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param search Optional search term to filter results (e.g. `"animal"`).
#' @param add Optional related table to include in results. Options:
#'   `"sh"`, `"cuci"`, `"cgce"`.
#' @param page Page number for pagination. Default: `NULL` (all results).
#' @param per_page Number of results per page. Default: `NULL`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with NCM codes and descriptions.
#'
#' @examples
#' \dontrun{
#' ncm <- comex_ncm()
#' comex_ncm(search = "animal", per_page = 10)
#' comex_ncm(add = "cuci")
#' }
#'
#' @export
comex_ncm <- function(language = "en", search = NULL, add = NULL,
                      page = NULL, per_page = NULL, verbose = FALSE) {
  data <- comex_get("/tables/ncm",
                    query = list(language = language, search = search,
                                 add = add, page = page,
                                 perPage = per_page),
                    verbose = verbose)
  response_to_df(data)
}

#' Get NCM code details
#'
#' Returns details for a specific NCM code, including product description
#' and its HS classification hierarchy.
#'
#' @param ncm_code NCM code (8 digits, as character, e.g. `"02042200"`).
#' @param verbose Logical. Default: `FALSE`.
#' @return A list with NCM details.
#'
#' @examples
#' \dontrun{
#' comex_ncm_detail("02042200")
#' }
#'
#' @export
comex_ncm_detail <- function(ncm_code, verbose = FALSE) {
  endpoint <- paste0("/tables/ncm/", ncm_code)
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

# ---- NBM - Brazilian Nomenclature of Goods (Historical) -----------------

#' Get NBM (Brazilian Nomenclature of Goods) table
#'
#' Returns the NBM codes table with descriptions. NBM was the nomenclature
#' used in Brazil before NCM adoption and is used only for historical
#' data (1989-1996).
#'
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param search Optional search term to filter results.
#' @param add Optional related table to include (e.g. `"ncm"`).
#' @param page Page number for pagination. Default: `NULL`.
#' @param per_page Number of results per page. Default: `NULL`.
#' @param verbose Logical. Default: `FALSE`.
#' @return A data.frame with NBM codes and descriptions.
#'
#' @examples
#' \dontrun{
#' comex_nbm()
#' comex_nbm(search = "encomendas", per_page = 5)
#' comex_nbm(add = "ncm")
#' }
#'
#' @export
comex_nbm <- function(language = "en", search = NULL, add = NULL,
                      page = NULL, per_page = NULL, verbose = FALSE) {
  data <- comex_get("/tables/nbm",
                    query = list(language = language, search = search,
                                 add = add, page = page,
                                 perPage = per_page),
                    verbose = verbose)
  response_to_df(data)
}

#' Get NBM code details
#'
#' Returns details for a specific NBM code.
#'
#' @param nbm_code NBM code (e.g. `"2924101100"`).
#' @param verbose Logical. Default: `FALSE`.
#' @return A list with NBM details.
#'
#' @examples
#' \dontrun{
#' comex_nbm_detail("2924101100")
#' }
#'
#' @export
comex_nbm_detail <- function(nbm_code, verbose = FALSE) {
  endpoint <- paste0("/tables/nbm/", nbm_code)
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

# ---- HS - Harmonized System --------------------------------------------

#' Get Harmonized System (HS) tables
#'
#' Returns Harmonized System classification tables. The HS is an
#' international product nomenclature developed by the World Customs
#' Organization (WCO).
#'
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param add Optional related table to include (e.g. `"ncm"`).
#' @param page Page number for pagination. Default: `NULL`.
#' @param per_page Number of results per page. Default: `NULL`.
#' @param verbose Logical. Default: `FALSE`.
#' @return A data.frame with HS codes and descriptions.
#'
#' @details
#' The Harmonized System is organized hierarchically:
#' - **Section**: 21 sections (broadest grouping)
#' - **Chapter (HS2)**: ~97 chapters (2 digits)
#' - **Heading (HS4)**: 4 digits
#' - **Subheading (HS6)**: 6 digits (most detailed)
#'
#' The NCM adds 2 more digits to the HS6 code.
#'
#' @examples
#' \dontrun{
#' # All HS classifications
#' comex_hs()
#'
#' # With related NCM codes
#' comex_hs(add = "ncm", per_page = 10)
#' }
#'
#' @export
comex_hs <- function(language = "en", add = NULL,
                     page = NULL, per_page = NULL, verbose = FALSE) {
  data <- comex_get("/tables/hs",
                    query = list(language = language, add = add,
                                 page = page, perPage = per_page),
                    verbose = verbose)
  response_to_df(data)
}
