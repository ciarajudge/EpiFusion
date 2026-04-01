test_that("infer_rt_from_beta_gamma_draws computes beta over gamma by draw", {
  beta_draws <- cbind(
    c(0.2, 0.4, 0.6),
    c(0.3, 0.6, 0.9)
  )
  gamma_draws <- c(0.1, 0.3)

  rt <- infer_rt_from_beta_gamma_draws(beta_draws, gamma_draws)

  expect_equal(dim(rt), dim(beta_draws))
  expect_equal(rt[, 1], c(2, 4, 6))
  expect_equal(rt[, 2], c(1, 2, 3))
})

