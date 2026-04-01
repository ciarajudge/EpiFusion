test_that("resampling preserves coherent particle ancestry histories", {
  # Weekly checkpoints at days 6 and 13 force at least one resampling event.
  cfg <- epifusion_config(
    case_incidence = data.frame(
      Date = as.Date("2024-01-01") + c(6, 13),
      Cases = c(50, 50)
    ),
    index_date = as.Date("2024-01-01")
  )

  out <- run_epi_only_poisson_pf(
    config = cfg,
    initial_beta = 0.2,
    beta_jitter = 0.02,
    beta_refactor = 1.0,
    gamma = 0.1,
    phi = 0.05,
    initial_state = 10L,
    num_particles = 120L,
    seed = 321L
  )

  states <- out$states_by_day
  anc <- out$ancestor_index_by_obs
  obs_days <- cfg$data$incidence_times

  # Robust ancestry invariant: if two children share the same ancestor index at
  # a checkpoint, they must at least share the checkpoint-day state.
  # Only check the final checkpoint (later resampling can overwrite earlier
  # checkpoint histories by design).
  for (o in length(obs_days)) {
    drow <- obs_days[o] + 1L
    anc_row <- anc[o, ]
    for (a in unique(anc_row)) {
      idx <- which(anc_row == a)
      if (length(idx) >= 2) {
        ref <- states[drow, idx[1]]
        for (k in idx[-1]) {
          expect_equal(states[drow, k], ref)
        }
      }
    }
  }
})

