test_that("validate_period accepts valid periods", {
  expect_true(validate_period("2023-01", "2023-12"))
  expect_true(validate_period("2023-05", "2023-05"))
})

test_that("validate_period rejects malformed or out-of-range periods", {
  expect_error(validate_period("2023-1", "2023-12"), "start period")
  expect_error(validate_period("2023-00", "2023-12"), "start period")
  expect_error(validate_period("2023-01", "2023-13"), "end period")
  expect_error(validate_period(NA, "2023-12"), "start period")
  expect_error(validate_period(c("2023-01", "2023-02"), "2023-12"))
  expect_error(validate_period("2023-12", "2023-01"), "before or equal")
})

test_that("convert_flow normalises aliases", {
  expect_equal(convert_flow("EXP"), "export")
  expect_equal(convert_flow("imports"), "import")
  expect_error(convert_flow("both"), "Invalid flow")
  expect_error(convert_flow(c("export", "import")), "single string")
})

test_that("get_api_name maps aliases and passes API names through", {
  expect_equal(get_api_name("transport_mode"), "via")
  expect_equal(get_api_name("hs4"), "heading")
  expect_equal(get_api_name("cgce_n1"), "BECLevel1")
  expect_equal(get_api_name("SITCSection"), "SITCSection")
  expect_warning(out <- get_api_name("bogus"), "Unknown")
  expect_equal(out, "bogus")
})

test_that("every .details_map destination is also accepted verbatim", {
  expect_true(all(unname(.details_map) %in% names(.details_map)))
})

test_that("build_details returns an unnamed list of API names", {
  expect_equal(build_details(c("country", "hs2")), list("country", "chapter"))
  expect_equal(build_details(NULL), list())
})

test_that("build_filters builds filter objects and requires names", {
  f <- build_filters(list(country = c(160, 249), hs4 = "0201"))
  expect_equal(f[[1]], list(filter = "country", values = list(160, 249)))
  expect_equal(f[[2]]$filter, "heading")
  expect_equal(build_filters(NULL), list())
  expect_error(build_filters(list(c(160))), "named list")
  expect_error(build_filters(list(country = 160, 26)), "named list")
})

test_that("build_metrics requires at least one metric", {
  expect_equal(build_metrics(), list("metricFOB", "metricKG"))
  expect_error(build_metrics(metric_fob = FALSE, metric_kg = FALSE),
               "At least one")
})

test_that("metadata helpers reject unknown types before any request", {
  expect_error(comex_filters("bogus"), "should be one of")
  expect_error(comex_last_update("bogus"), "should be one of")
})

test_that("SSL verification is opt-out only", {
  req <- httr2::request("https://example.org")
  old <- options(comexr.ssl_verifypeer = NULL,
                        comex.ssl_verifypeer = NULL)
  on.exit(options(old), add = TRUE)
  expect_null(comex_req_options(req)$options$ssl_verifypeer)
  options(comexr.ssl_verifypeer = FALSE)
  expect_equal(comex_req_options(req)$options$ssl_verifypeer, 0)
  options(comexr.ssl_verifypeer = NULL, comex.ssl_verifypeer = FALSE)
  expect_equal(comex_req_options(req)$options$ssl_verifypeer, 0)
})

test_that("%||% works independently of the R version", {
  expect_equal(NULL %||% 1, 1)
  expect_equal(2 %||% 1, 2)
})
