test_that("Poisson epi loglik matches across matrix layouts", {
  set.seed(42)
  n_time <- 20L
  n_particles <- 8L
  lambda_tp <- matrix(rexp(n_time * n_particles, rate = 0.3), nrow = n_time)
  lambda_pt <- t(lambda_tp)
  incidence <- rpois(n_time, lambda = pmax(rowMeans(lambda_tp), 0.1))

  ll_tp <- epi_loglik_poisson_particles(lambda_tp, incidence, "time_particles")
  ll_pt <- epi_loglik_poisson_particles(lambda_pt, incidence, "particles_time")

  expect_equal(ll_tp, ll_pt, tolerance = 1e-12)
})

