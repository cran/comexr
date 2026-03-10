# =========================================================================
# API metadata and geographic auxiliary tables (GET)
# =========================================================================

# ---- Metadata -----------------------------------------------------------

#' Get last data update date
#'
#' Returns the date of the last data update in the API.
#'
#' @param type Data type: `"general"`, `"city"`, or `"historical"`.
#'   Default: `"general"`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A list with last update information.
#'
#' @examples
#' \dontrun{
#' comex_last_update()
#' comex_last_update("city")
#' comex_last_update("historical")
#' }
#'
#' @export
comex_last_update <- function(type = "general", verbose = FALSE) {
  endpoint <- switch(type,
    general    = "/general/dates/updated",
    city       = "/cities/dates/updated",
    historical = "/historical-data/dates/updated",
    cli::cli_abort("Invalid type: {type}. Use 'general', 'city', or 'historical'.")
  )
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

#' Get available years for queries
#'
#' Returns the first and last years available for queries in the API.
#'
#' @inheritParams comex_last_update
#' @return A list with `min` and `max` year values.
#'
#' @examples
#' \dontrun{
#' comex_available_years()
#' comex_available_years("city")
#' comex_available_years("historical")
#' }
#'
#' @export
comex_available_years <- function(type = "general", verbose = FALSE) {
  endpoint <- switch(type,
    general    = "/general/dates/years",
    city       = "/cities/dates/years",
    historical = "/historical-data/dates/years",
    cli::cli_abort("Invalid type: {type}. Use 'general', 'city', or 'historical'.")
  )
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

#' Get available filters
#'
#' Returns the list of filter types available for API queries.
#'
#' @param type Data type: `"general"`, `"city"`, or `"historical"`.
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with available filters.
#'
#' @examples
#' \dontrun{
#' comex_filters()
#' comex_filters("city")
#' comex_filters("historical")
#' }
#'
#' @export
comex_filters <- function(type = "general", language = "en", verbose = FALSE) {
  base <- switch(type,
    general    = "/general/filters",
    city       = "/cities/filters",
    historical = "/historical-data/filters",
    cli::cli_abort("Invalid type: {type}.")
  )
  data <- comex_get(base, query = list(language = language), verbose = verbose)
  response_to_df(data)
}

#' Get values for a specific filter
#'
#' Returns the possible values for a given filter name.
#'
#' @param filter Filter name as returned by [comex_filters()]
#'   (e.g. `"country"`, `"state"`, `"ncm"`, `"economicBlock"`).
#' @param type Data type: `"general"`, `"city"`, or `"historical"`.
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with filter values.
#'
#' @examples
#' \dontrun{
#' comex_filter_values("country")
#' comex_filter_values("state", type = "city")
#' comex_filter_values("economicBlock")
#' }
#'
#' @export
comex_filter_values <- function(filter,
                                type = "general",
                                language = "en",
                                verbose = FALSE) {
  base <- switch(type,
    general    = "/general/filters",
    city       = "/cities/filters",
    historical = "/historical-data/filters",
    cli::cli_abort("Invalid type: {type}.")
  )
  endpoint <- paste0(base, "/", filter)
  data <- comex_get(endpoint, query = list(language = language),
                    verbose = verbose)
  response_to_df(data)
}

#' Get available detail/grouping fields
#'
#' Returns the list of detail fields that can be used to group query results.
#'
#' @inheritParams comex_filters
#' @return A data.frame with available details.
#'
#' @examples
#' \dontrun{
#' comex_details()
#' comex_details("city")
#' comex_details("historical")
#' }
#'
#' @export
comex_details <- function(type = "general", language = "en", verbose = FALSE) {
  base <- switch(type,
    general    = "/general/details",
    city       = "/cities/details",
    historical = "/historical-data/details",
    cli::cli_abort("Invalid type: {type}.")
  )
  data <- comex_get(base, query = list(language = language), verbose = verbose)
  response_to_df(data)
}

#' Get available metrics
#'
#' Returns the list of metrics (values) available for API queries.
#'
#' @inheritParams comex_filters
#' @return A data.frame with available metrics and their descriptions.
#'
#' @examples
#' \dontrun{
#' comex_metrics()
#' comex_metrics("city")
#' comex_metrics("historical")
#' }
#'
#' @export
comex_metrics <- function(type = "general", language = "en", verbose = FALSE) {
  base <- switch(type,
    general    = "/general/metrics",
    city       = "/cities/metrics",
    historical = "/historical-data/metrics",
    cli::cli_abort("Invalid type: {type}.")
  )
  data <- comex_get(base, query = list(language = language), verbose = verbose)
  response_to_df(data)
}

# ---- Auxiliary tables: Geography ----------------------------------------

#' Get countries table
#'
#' Returns the countries table with codes and names.
#'
#' @param search Optional search term to filter results (e.g. `"br"`).
#' @param verbose Logical. Show progress messages. Default: `FALSE`.
#' @return A data.frame with country codes and names.
#'
#' @examples
#' \dontrun{
#' comex_countries()
#' comex_countries(search = "bra")
#' }
#'
#' @export
comex_countries <- function(search = NULL, verbose = FALSE) {
  data <- comex_get("/tables/countries",
                    query = list(search = search),
                    verbose = verbose)
  response_to_df(data)
}

#' Get country details
#'
#' Returns details for a specific country by its code.
#'
#' @param id Country code (e.g. `105` for Brazil).
#' @param verbose Logical. Default: `FALSE`.
#' @return A list with country details.
#'
#' @examples
#' \dontrun{
#' comex_country_detail(105)
#' }
#'
#' @export
comex_country_detail <- function(id, verbose = FALSE) {
  endpoint <- paste0("/tables/countries/", id)
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

#' Get economic blocs table
#'
#' Returns the economic blocs table with codes and names. Economic blocs
#' represent trade agreements between countries and regions.
#'
#' @param language Language: `"pt"`, `"en"`, or `"es"`. Default: `"en"`.
#' @param search Optional search term to filter results.
#' @param add Optional related table to include (e.g. `"country"`).
#' @param verbose Logical. Default: `FALSE`.
#' @return A data.frame with economic bloc codes and names.
#'
#' @examples
#' \dontrun{
#' comex_blocs()
#' comex_blocs(search = "mercosul")
#' comex_blocs(add = "country")
#' }
#'
#' @export
comex_blocs <- function(language = "en", search = NULL, add = NULL,
                        verbose = FALSE) {
  data <- comex_get("/tables/economic-blocks",
                    query = list(language = language, search = search,
                                 add = add),
                    verbose = verbose)
  response_to_df(data)
}

#' Get Brazilian states (UF) table
#'
#' Returns the Brazilian states table with codes and names.
#'
#' @param verbose Logical. Default: `FALSE`.
#' @return A data.frame with state codes and names.
#'
#' @examples
#' \dontrun{
#' comex_states()
#' }
#'
#' @export
comex_states <- function(verbose = FALSE) {
  data <- comex_get("/tables/uf", verbose = verbose)
  response_to_df(data)
}

#' Get state details
#'
#' Returns details for a specific Brazilian state.
#'
#' @param uf_id State code (e.g. `26` for Pernambuco).
#' @param verbose Logical. Default: `FALSE`.
#' @return A list with state details.
#'
#' @examples
#' \dontrun{
#' comex_state_detail(26)
#' }
#'
#' @export
comex_state_detail <- function(uf_id, verbose = FALSE) {
  endpoint <- paste0("/tables/uf/", uf_id)
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

#' Get Brazilian cities table
#'
#' Returns the Brazilian cities table with codes and names.
#'
#' @param verbose Logical. Default: `FALSE`.
#' @return A data.frame with city (IBGE) codes and names.
#'
#' @examples
#' \dontrun{
#' comex_cities()
#' }
#'
#' @export
comex_cities <- function(verbose = FALSE) {
  data <- comex_get("/tables/cities", verbose = verbose)
  response_to_df(data)
}

#' Get city details
#'
#' Returns details for a specific Brazilian city.
#'
#' @param city_id IBGE city code (e.g. `5300050`).
#' @param verbose Logical. Default: `FALSE`.
#' @return A list with city details.
#'
#' @examples
#' \dontrun{
#' comex_city_detail(5300050)
#' }
#'
#' @export
comex_city_detail <- function(city_id, verbose = FALSE) {
  endpoint <- paste0("/tables/cities/", city_id)
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

#' Get transport modes table
#'
#' Returns the transport modes table with codes and names.
#'
#' @param verbose Logical. Default: `FALSE`.
#' @return A data.frame with transport mode codes and names.
#'
#' @examples
#' \dontrun{
#' comex_transport_modes()
#' }
#'
#' @export
comex_transport_modes <- function(verbose = FALSE) {
  data <- comex_get("/tables/ways", verbose = verbose)
  response_to_df(data)
}

#' Get transport mode details
#'
#' Returns details for a specific transport mode.
#'
#' @param mode_id Transport mode code (e.g. `5` for maritime).
#' @param verbose Logical. Default: `FALSE`.
#' @return A list with transport mode details.
#'
#' @examples
#' \dontrun{
#' comex_transport_mode_detail(5)
#' }
#'
#' @export
comex_transport_mode_detail <- function(mode_id, verbose = FALSE) {
  endpoint <- paste0("/tables/ways/", mode_id)
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}

#' Get customs units (URF) table
#'
#' Returns the customs units table (Unidades da Receita Federal) with
#' codes and names. These are the Federal Revenue Service administrative
#' units responsible for overseeing foreign trade operations.
#'
#' @param verbose Logical. Default: `FALSE`.
#' @return A data.frame with customs unit codes and names.
#'
#' @examples
#' \dontrun{
#' comex_customs_units()
#' }
#'
#' @export
comex_customs_units <- function(verbose = FALSE) {
  data <- comex_get("/tables/urf", verbose = verbose)
  response_to_df(data)
}

#' Get customs unit details
#'
#' Returns details for a specific customs unit (URF).
#'
#' @param urf_id Customs unit code (e.g. `8110000`).
#' @param verbose Logical. Default: `FALSE`.
#' @return A list with customs unit details.
#'
#' @examples
#' \dontrun{
#' comex_customs_unit_detail(8110000)
#' }
#'
#' @export
comex_customs_unit_detail <- function(urf_id, verbose = FALSE) {
  endpoint <- paste0("/tables/urf/", urf_id)
  data <- comex_get(endpoint, verbose = verbose)
  extract_single(data)
}
