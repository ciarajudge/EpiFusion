test_that("trajectory metric calculator returns finite metrics", {
  set.seed(1)
  truth <- c(5, 6, 7, 8, 9)
  draws <- cbind(
    truth + rnorm(5, 0, 0.5),
    truth + rnorm(5, 0, 0.5),
    truth + rnorm(5, 0, 0.5),
    truth + rnorm(5, 0, 0.5)
  )

  m <- evaluate_infection_trajectory_metrics(draws, truth)
  expect_true(is.list(m))
  expect_true(is.finite(m$rmse))
  expect_true(m$coverage >= 0 && m$coverage <= 1)
  expect_true(is.finite(m$hpd_width))
  expect_true(is.finite(m$crps))
})

test_that("baseline scenario metrics can be computed against truth", {
  inc_path <- "/Users/user/Desktop/PhD/EpiFusion_PublicationRepo/Scenario_Testing/Data_Simulation/Main_Scenarios/baseline/baseline_weeklyincidence.txt"
  truth_path <- "/Users/user/Desktop/PhD/EpiFusion_PublicationRepo/Scenario_Testing/Data_Simulation/Main_Scenarios/baseline/baseline_truth.csv"
  skip_if_not(file.exists(inc_path), "Baseline incidence file not found.")
  skip_if_not(file.exists(truth_path), "Baseline truth file not found.")

  weekly_inc <- scan(inc_path, what = numeric(), quiet = TRUE)
  start_date <- as.Date("2024-01-01")
  cfg <- epifusion_config(
    case_incidence = data.frame(
      Date = start_date + 6 + 7 * (seq_along(weekly_inc) - 1),
      Cases = weekly_inc
    ),
    index_date = start_date
  )

  fit <- run_mcmc_looseformbeta_adaptive(
    config = cfg,
    n_steps = 120L,
    warmup_steps = 60L,
    adapt_interval = 20L,
    num_particles = 200L,
    seed = 10L
  )

  post_idx <- 61:120
  sel <- post_idx[seq(1, length(post_idx), length.out = 20)]
  draws <- infer_daily_infections_from_samples(
    config = cfg,
    samples = fit$chain$samples,
    draw_indices = sel,
    num_particles = 150L,
    initial_state = 5L,
    seed = 500L
  )

  truth_df <- read.csv(truth_path, check.names = FALSE)
  day_grid <- 0:(nrow(draws) - 1)
  idx <- findInterval(day_grid, truth_df$t)
  idx[idx < 1] <- 1L
  truth_daily <- truth_df$I[idx]

  m <- evaluate_infection_trajectory_metrics(draws, truth_daily)
  expect_true(is.finite(m$rmse))
  expect_true(m$coverage >= 0 && m$coverage <= 1)
  expect_true(is.finite(m$hpd_width))
  expect_true(is.finite(m$crps))
})

