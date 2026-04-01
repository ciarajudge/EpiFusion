test_that("XML parser returns wrapper-compatible incidence structure", {
  xml_candidates <- c(
    "baseline_fixed_tree_inputfile.xml",
    "../../baseline_fixed_tree_inputfile.xml"
  )
  xml_path <- xml_candidates[file.exists(xml_candidates)][1]
  skip_if_not(file.exists(xml_path), "Baseline XML fixture not found in repo root.")

  parsed <- read_epifusion_xml_inputs(xml_path)
  expect_true(inherits(parsed$index_date, "Date"))
  expect_true(is.data.frame(parsed$case_incidence))
  expect_true(all(c("Date", "Cases") %in% names(parsed$case_incidence)))
  expect_equal(length(parsed$incidence_vals), nrow(parsed$case_incidence))
  expect_equal(parsed$epi_observation_model, "poisson")
})

test_that("Layout kernels are equal on incidence from real XML", {
  xml_candidates <- c(
    "baseline_fixed_tree_inputfile.xml",
    "../../baseline_fixed_tree_inputfile.xml"
  )
  xml_path <- xml_candidates[file.exists(xml_candidates)][1]
  skip_if_not(file.exists(xml_path), "Baseline XML fixture not found in repo root.")

  parsed <- read_epifusion_xml_inputs(xml_path)
  incidence <- as.integer(round(parsed$incidence_vals))
  n_time <- length(incidence)
  n_particles <- 32L

  set.seed(7)
  lambda_tp <- matrix(
    rlnorm(n_time * n_particles, meanlog = 0, sdlog = 0.2),
    nrow = n_time
  ) * pmax(as.numeric(incidence), 0.1)
  lambda_pt <- t(lambda_tp)

  ll_tp <- epi_loglik_poisson_particles(lambda_tp, incidence, "time_particles")
  ll_pt <- epi_loglik_poisson_particles(lambda_pt, incidence, "particles_time")
  expect_equal(ll_tp, ll_pt, tolerance = 1e-12)
})

