test_that("adaptive MCMC wrapper returns tuning history and chain", {
  cfg <- epifusion_config(
    case_incidence = data.frame(
      Date = as.Date("2024-01-07") + 7 * (0:7),
      Cases = c(1, 2, 4, 6, 5, 3, 2, 1)
    ),
    index_date = as.Date("2024-01-01")
  )

  out <- run_mcmc_looseformbeta_adaptive(
    config = cfg,
    n_steps = 20L,
    warmup_steps = 20L,
    adapt_interval = 10L,
    num_particles = 100L,
    seed = 11L
  )

  expect_true(is.list(out))
  expect_true(is.data.frame(out$warmup_history))
  expect_equal(dim(out$chain$samples), c(20, 4))
  expect_true(is.numeric(out$chain$acceptance_rate))
})

