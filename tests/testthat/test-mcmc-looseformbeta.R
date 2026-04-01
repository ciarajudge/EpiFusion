test_that("run_mcmc_looseformbeta returns expected shape", {
  cfg <- epifusion_config(
    case_incidence = data.frame(
      Date = as.Date("2024-01-07") + 7 * (0:7),
      Cases = c(1, 2, 4, 6, 5, 3, 2, 1)
    ),
    index_date = as.Date("2024-01-01")
  )

  out <- run_mcmc_looseformbeta(
    config = cfg,
    n_steps = 30L,
    num_particles = 150L,
    seed = 99L
  )

  expect_true(is.list(out))
  expect_equal(dim(out$samples), c(30, 4))
  expect_equal(length(out$loglik_trace), 30)
  expect_equal(length(out$accepted), 30)
  expect_true(is.numeric(out$acceptance_rate))
})

