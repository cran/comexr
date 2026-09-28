# Offline tests: fixtures mirror payloads observed on the live API.

test_that("response_to_df handles {data: {list: [...]}}", {
  resp <- list(data = list(list = list(
    list(year = "2023", country = "China", metricFOB = "5055734806"),
    list(year = "2023", country = "Chile", metricFOB = "123")
  )))
  df <- response_to_df(resp)
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 2)
  expect_named(df, c("year", "country", "metricFOB"))
  expect_type(df$metricFOB, "character")
})

test_that("response_to_df handles a direct unnamed array", {
  resp <- list(data = list(
    list(coUf = 26, sgUf = "PE"),
    list(coUf = 13, sgUf = "AM")
  ))
  df <- response_to_df(resp)
  expect_equal(df$coUf, c(26, 13))
  expect_equal(df$sgUf, c("PE", "AM"))
})

test_that("response_to_df handles a double-wrapped array", {
  resp <- list(data = list(list(
    list(id = "1", text = "A"),
    list(id = "2", text = "B")
  )))
  expect_equal(response_to_df(resp)$id, c("1", "2"))
})

test_that("response_to_df fills fields missing from some rows with NA", {
  resp <- list(data = list(list = list(
    list(a = "1", b = "x"),
    list(a = "2"),
    list(a = "3", b = NULL, c = list("p", "q"))
  )))
  df <- response_to_df(resp)
  expect_equal(df$b, c("x", NA, NA))
  expect_equal(df$c, c(NA, NA, "p, q"))
})

test_that("response_to_df keeps column names verbatim", {
  resp <- list(data = list(list(`field name` = "v", `1st` = "w")))
  expect_named(response_to_df(resp), c("field name", "1st"))
})

test_that("response_to_df turns a single named object into one row", {
  df <- response_to_df(list(data = list(id = 105, country = "Brasil")))
  expect_equal(nrow(df), 1)
  expect_equal(df$country, "Brasil")
})

test_that("response_to_df returns an empty data.frame for empty data", {
  expect_equal(nrow(response_to_df(list(data = NULL))), 0)
  expect_equal(nrow(response_to_df(list(data = list()))), 0)
  expect_equal(nrow(response_to_df(list(data = list(list = list())))), 0)
})

test_that("convert_query_types casts metrics, year and monthNumber", {
  df <- data.frame(
    year = c("2023", "2023"), monthNumber = c("01", "12"),
    country = c("China", "Chile"), ncm = c("02042200", "12019000"),
    metricFOB = c("5055734806", "1.5"), metricKG = c("10", NA),
    stringsAsFactors = FALSE
  )
  out <- convert_query_types(df)
  expect_identical(out$year, c(2023L, 2023L))
  expect_identical(out$monthNumber, c(1L, 12L))
  expect_identical(out$metricFOB, c(5055734806, 1.5))
  expect_identical(out$metricKG, c(10, NA))
  expect_identical(out$ncm, c("02042200", "12019000"))
})

test_that("convert_query_types leaves unparseable columns alone", {
  df <- data.frame(metricFOB = c("1", "n/a"), stringsAsFactors = FALSE)
  expect_identical(convert_query_types(df)$metricFOB, c("1", "n/a"))
  expect_identical(convert_query_types(data.frame()), data.frame())
})

test_that("extract_single unwraps the known detail shapes", {
  expect_null(extract_single(list(data = NULL)))
  expect_equal(extract_single(list(data = list(id = 105)))$id, 105)
  expect_equal(extract_single(list(data = list(list(id = "02042200"))))$id,
               "02042200")
  expect_equal(extract_single(list(data = list(list = list(list(id = 1)))))$id,
               1)
})

test_that("comex_historical trims whole-year API responses to the period", {
  rows <- lapply(1:12, function(m) {
    list(year = 1995L, monthNumber = m, metricFOB = "1", country = "China")
  })
  local_mocked_bindings(comex_post = function(...) list(data = rows))
  out <- comex_historical("export", "1995-03", "1995-05", verbose = FALSE)
  expect_equal(out$monthNumber, 3:5)
  expect_identical(out$metricFOB, c(1, 1, 1))

  local_mocked_bindings(comex_post = function(...) {
    list(data = list(list(year = 1995L, metricFOB = "12")))
  })
  expect_warning(
    comex_historical("export", "1995-03", "1995-05", month_detail = FALSE,
                     verbose = FALSE),
    "whole years"
  )
  expect_no_warning(
    comex_historical("export", "1995-01", "1995-12", month_detail = FALSE,
                     verbose = FALSE)
  )
})
