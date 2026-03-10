# =========================================================================
# Economic classification auxiliary tables
# (GET /tables/classifications, /tables/product-categories)
# =========================================================================

# ---- CGCE - Classification by Broad Economic Categories -----------------

#' Get CGCE (Classification by Broad Economic Categories) table
#'
#' Returns the CGCE classification table from the `/tables/classifications`
#' endpoint. CGCE groups products by use or economic purpose (e.g. capital
#' goods, intermediate goods, consumer goods).
#'
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param search Optional search term to filter results.
#' @param add Optional related table to include (e.g. `"ncm"`).
#' @param page Page number for pagination. Default: `NULL` (all results).
#' @param per_page Number of results per page. Default: `NULL`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with CGCE codes and descriptions.
#'
#' @examples
#' \dontrun{
#' # All CGCE classifications
#' comex_cgce()
#'
#' # Search within CGCE
#' comex_cgce(search = "110")
#' }
#'
#' @export
comex_cgce <- function(language = "en", search = NULL, add = NULL,
                       page = NULL, per_page = NULL, verbose = FALSE) {
  data <- comex_get("/tables/classifications",
                    query = list(language = language, search = search,
                                 add = add, page = page,
                                 perPage = per_page),
                    verbose = verbose)
  response_to_df(data)
}

# ---- SITC / CUCI - Standard International Trade Classification ----------

#' Get SITC/CUCI (Standard International Trade Classification) table
#'
#' Returns the CUCI (Classificacao Uniforme para o Comercio Internacional)
#' table from the `/tables/product-categories` endpoint. CUCI is the
#' Portuguese name for SITC (Standard International Trade Classification).
#'
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param search Optional search term to filter results.
#' @param add Optional related table to include (e.g. `"ncm"`).
#' @param page Page number for pagination. Default: `NULL`.
#' @param per_page Number of results per page. Default: `NULL`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with CUCI/SITC codes and descriptions.
#'
#' @examples
#' \dontrun{
#' # All CUCI/SITC classifications
#' comex_sitc()
#'
#' # Search for products
#' comex_sitc(search = "carne")
#' }
#'
#' @export
comex_sitc <- function(language = "en", search = NULL, add = NULL,
                       page = NULL, per_page = NULL, verbose = FALSE) {
  data <- comex_get("/tables/product-categories",
                    query = list(language = language, search = search,
                                 add = add, page = page,
                                 perPage = per_page),
                    verbose = verbose)
  response_to_df(data)
}

# ---- ISIC - International Standard Industrial Classification ------------

#' Get ISIC (International Standard Industrial Classification) table
#'
#' Queries the `/tables/product-categories` endpoint to retrieve ISIC
#' classification data. ISIC is an international classification of economic
#' activities developed by the United Nations.
#'
#' @note
#' The OpenAPI specification does not define a dedicated ISIC table endpoint.
#' ISIC codes are available as detail/grouping fields in trade queries
#' (e.g. `"isic_section"`, `"isic_division"`). This convenience function
#' queries `/tables/product-categories`, which may return ISIC data
#' alongside CUCI/SITC classifications. You can also look up ISIC values
#' using [comex_filter_values()] with filter names like `"isicSection"`.
#'
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param search Optional search term to filter results.
#' @param add Optional related table to include (e.g. `"ncm"`).
#' @param page Page number for pagination. Default: `NULL`.
#' @param per_page Number of results per page. Default: `NULL`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with classification codes and descriptions.
#'
#' @examples
#' \dontrun{
#' # Browse product categories (includes ISIC)
#' comex_isic()
#'
#' # Alternatively, look up ISIC values via filters:
#' comex_filter_values("isicSection")
#' }
#'
#' @export
comex_isic <- function(language = "en", search = NULL, add = NULL,
                       page = NULL, per_page = NULL, verbose = FALSE) {
  data <- comex_get("/tables/product-categories",
                    query = list(language = language, search = search,
                                 add = add, page = page,
                                 perPage = per_page),
                    verbose = verbose)
  response_to_df(data)
}
