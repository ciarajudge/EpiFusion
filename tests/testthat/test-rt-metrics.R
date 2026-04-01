test_that("Rt inference metrics are computable", {
  set.seed(2)
  inf_draws <- cbind(
    pmax(1, round(rnorm(30, mean = 20, sd = 5))),
    pmax(1, round(rnorm(30, mean = 22, sd = 5))),
    pmax(1, round(rnorm(30, mean = 18, sd = 4)))
  )
  rt_draws <- infer_rt_from_infection_draws(inf_draws, gen_time = c(0.2, 0.3, 0.5))
  truth_rt <- rowMeans(rt_draws)
  m <- evaluate_infection_trajectory_metrics(rt_draws, truth_rt)

  expect_true(is.finite(m$rmse))
  expect_true(m$coverage >= 0 && m$coverage <= 1)
  expect_true(is.finite(m$hpd_width))
  expect_true(is.finite(m$crps))
})

