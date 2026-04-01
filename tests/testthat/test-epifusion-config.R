test_that("epifusion_config normalizes case incidence and computes times", {
  case_incidence <- data.frame(
    Date = as.Date(c("2024-01-03", "2024-01-01", "2024-01-02")),
    Cases = c(3, 1, 2)
  )

  cfg <- epifusion_config(case_incidence = case_incidence)
  expect_s3_class(cfg, "epifusion_config")
  expect_equal(cfg$data$incidence_vals, c(1, 2, 3))
  expect_equal(cfg$data$incidence_times, c(0L, 1L, 2L))
})

test_that("epifusion_config respects explicit index_date", {
  case_incidence <- data.frame(
    Date = as.Date(c("2024-01-01", "2024-01-03")),
    Cases = c(10, 5)
  )
  cfg <- epifusion_config(case_incidence = case_incidence, index_date = "2023-12-30")
  expect_equal(cfg$data$incidence_times, c(2L, 4L))
})

