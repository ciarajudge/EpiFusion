test_that("epi-only poisson PF returns expected diagnostics", {
  cfg <- epifusion_config(
    case_incidence = data.frame(
      Date = as.Date("2024-01-07") + 7 * (0:9),
      Cases = c(1, 2, 3, 4, 3, 2, 2, 1, 1, 0)
    )
  )

  out <- run_epi_only_poisson_pf(
    config = cfg,
    initial_beta = 0.25,
    beta_jitter = 0.02,
    gamma = 0.08,
    phi = 0.15,
    initial_state = 5L,
    num_particles = 250L,
    seed = 123L
  )

  expect_true(is.list(out))
  expect_true("loglik" %in% names(out))
  expect_equal(length(out$loglik_by_obs), 10)
  expect_equal(length(out$ess_by_obs), 10)
  expect_equal(length(out$mean_state_by_day), 64)
  expect_equal(dim(out$states_by_day), c(64, 250))
  expect_equal(dim(out$betas_by_day), c(64, 250))
  expect_equal(dim(out$window_tests_by_particle), c(10, 250))
  expect_equal(length(out$final_states), 250)
})

test_that("epi-only poisson PF is reproducible with fixed seed", {
  cfg <- epifusion_config(
    case_incidence = data.frame(
      Date = as.Date("2024-02-01") + 0:6,
      Cases = c(0, 1, 2, 3, 2, 1, 0)
    )
  )

  out1 <- run_epi_only_poisson_pf(
    config = cfg,
    initial_beta = 0.2,
    beta_jitter = 0.01,
    gamma = 0.05,
    phi = 0.2,
    initial_state = 4L,
    num_particles = 200L,
    seed = 42L
  )
  out2 <- run_epi_only_poisson_pf(
    config = cfg,
    initial_beta = 0.2,
    beta_jitter = 0.01,
    gamma = 0.05,
    phi = 0.2,
    initial_state = 4L,
    num_particles = 200L,
    seed = 42L
  )

  expect_equal(out1$loglik, out2$loglik)
  expect_equal(out1$loglik_by_obs, out2$loglik_by_obs)
})

