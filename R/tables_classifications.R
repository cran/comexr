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

#' Get ISIC (International Standard Industrial Classification) values
#'
#' Retrieves ISIC classification values at a chosen hierarchical level by
#' calling the corresponding `/general/filters/{filter}` endpoint, which
#' is the only place the ComexStat API exposes ISIC codes (there is no
#' `/tables/isic` endpoint).
#'
#' ISIC is the international classification of economic activities
#' maintained by the United Nations.
#'
#' @param level Hierarchical level. One of `"section"`, `"division"`,
#'   `"group"`, or `"class"`. Default: `"section"`.
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with ISIC codes and descriptions for the given level.
#'
#' @examples
#' \dontrun{
#' comex_isic("section")
#' comex_isic("division", language = "pt")
#' }
#'
#' @export
comex_isic <- function(level = c("section", "division", "group", "class"),
                       language = "en", verbose = FALSE) {
  level <- match.arg(level)
  filter <- switch(level,
    section  = "ISICSection",
    division = "ISICDivision",
    group    = "ISICGroup",
    class    = "ISICClass"
  )
  comex_filter_values(filter, type = "general",
                      language = language, verbose = verbose)
}
