#include <Rcpp.h>

// [[Rcpp::export]]
double add_two_cpp(double x, double y) {
  return x + y;
}

// [[Rcpp::export]]
Rcpp::NumericVector epifusion_compute_rt_cpp(
    Rcpp::IntegerVector infections,
    Rcpp::NumericVector gen_time
) {
  const int n_days = infections.size();
  const int gt_len = gen_time.size();

  if (gt_len == 0) {
    Rcpp::stop("`gen_time` must contain at least one value.");
  }

  Rcpp::NumericVector rt(n_days);
  const int lag = gt_len - 1;

  for (int t = 0; t < n_days; ++t) {
    double denom = 0.0;

    if (t < lag) {
      // Java logic: reverse truncated gen_time and normalize this partial window.
      const int k = t + 1;
      Rcpp::NumericVector gt(k);
      for (int i = 0; i < k; ++i) {
        gt[i] = gen_time[k - 1 - i];
      }

      double sum_gt = 0.0;
      for (int i = 0; i < k; ++i) {
        sum_gt += gt[i];
      }

      for (int i = 0; i < k; ++i) {
        gt[i] /= sum_gt;
        denom += static_cast<double>(infections[i]) * gt[i];
      }
    } else {
      // Java logic: use full reversed gen_time with no renormalization.
      for (int i = 0; i < gt_len; ++i) {
        const int inf_idx = t - lag + i;
        const double gt_weight = gen_time[gt_len - 1 - i];
        denom += static_cast<double>(infections[inf_idx]) * gt_weight;
      }
    }

    rt[t] = static_cast<double>(infections[t]) / denom;
  }

  return rt;
}

// [[Rcpp::export]]
Rcpp::NumericVector epi_loglik_poisson_tp_cpp(
    Rcpp::NumericMatrix positive_tests_tp,
    Rcpp::IntegerVector incidence
) {
  const int n_time = positive_tests_tp.nrow();
  const int n_particles = positive_tests_tp.ncol();
  if (incidence.size() != n_time) {
    Rcpp::stop("`incidence` length must equal nrow(positive_tests_tp).");
  }

  Rcpp::NumericVector out(n_particles);
  for (int p = 0; p < n_particles; ++p) {
    double ll = 0.0;
    for (int t = 0; t < n_time; ++t) {
      double lambda = positive_tests_tp(t, p);
      if (lambda <= 0.0) {
        lambda = 0.001;
      }
      ll += R::dpois(static_cast<double>(incidence[t]), lambda, true);
    }
    out[p] = ll;
  }
  return out;
}

// [[Rcpp::export]]
Rcpp::NumericVector epi_loglik_poisson_pt_cpp(
    Rcpp::NumericMatrix positive_tests_pt,
    Rcpp::IntegerVector incidence
) {
  const int n_particles = positive_tests_pt.nrow();
  const int n_time = positive_tests_pt.ncol();
  if (incidence.size() != n_time) {
    Rcpp::stop("`incidence` length must equal ncol(positive_tests_pt).");
  }

  Rcpp::NumericVector out(n_particles);
  for (int t = 0; t < n_time; ++t) {
    const double y = static_cast<double>(incidence[t]);
    for (int p = 0; p < n_particles; ++p) {
      double lambda = positive_tests_pt(p, t);
      if (lambda <= 0.0) {
        lambda = 0.001;
      }
      out[p] += R::dpois(y, lambda, true);
    }
  }
  return out;
}

// [[Rcpp::export]]
Rcpp::List epi_only_poisson_pf_cpp(
    Rcpp::IntegerVector incidence,
    double beta,
    double gamma,
    double phi,
    int initial_state,
    int num_particles,
    int seed
) {
  if (incidence.size() == 0) {
    Rcpp::stop("`incidence` must have at least one value.");
  }
  if (num_particles <= 0) {
    Rcpp::stop("`num_particles` must be > 0.");
  }
  if (initial_state <= 0) {
    Rcpp::stop("`initial_state` must be > 0.");
  }

  Rcpp::Environment base_env("package:base");
  Rcpp::Function set_seed = base_env["set.seed"];
  set_seed(seed);

  const int n_time = incidence.size();
  Rcpp::IntegerVector states(num_particles, initial_state);
  Rcpp::NumericVector log_weights(num_particles);
  Rcpp::NumericVector ess_by_time(n_time);
  Rcpp::NumericVector loglik_by_time(n_time);
  Rcpp::IntegerVector mean_state_by_time(n_time);
  Rcpp::IntegerMatrix states_by_time(n_time, num_particles);

  double total_loglik = 0.0;

  for (int t = 0; t < n_time; ++t) {
    // Propagate all particles one day.
    for (int p = 0; p < num_particles; ++p) {
      int state = states[p];
      if (state <= 0) {
        log_weights[p] = R_NegInf;
        states_by_time(t, p) = 0;
        continue;
      }

      const double birth_rate = std::max(0.0, beta * static_cast<double>(state));
      const double death_rate =
          (t > 1) ? std::max(0.0, gamma * static_cast<double>(state)) : 0.0;
      const int births = R::rpois(birth_rate);
      const int deaths = R::rpois(death_rate);
      state = state + births - deaths;
      if (state <= 0) {
        state = 0;
        states[p] = state;
        log_weights[p] = R_NegInf;
        states_by_time(t, p) = 0;
        continue;
      }
      states[p] = state;
      states_by_time(t, p) = state;

      const double lambda = std::max(0.001, std::round(static_cast<double>(state) * phi));
      log_weights[p] = R::dpois(static_cast<double>(incidence[t]), lambda, true);
    }

    // Incremental log-likelihood via stable log-mean-exp.
    double max_logw = R_NegInf;
    for (int p = 0; p < num_particles; ++p) {
      if (log_weights[p] > max_logw) {
        max_logw = log_weights[p];
      }
    }
    if (!R_finite(max_logw)) {
      return Rcpp::List::create(
          Rcpp::Named("loglik") = R_NegInf,
          Rcpp::Named("loglik_by_time") = loglik_by_time,
          Rcpp::Named("ess_by_time") = ess_by_time,
          Rcpp::Named("mean_state_by_time") = mean_state_by_time,
          Rcpp::Named("states_by_time") = states_by_time,
          Rcpp::Named("final_states") = states);
    }

    double sum_exp = 0.0;
    for (int p = 0; p < num_particles; ++p) {
      sum_exp += std::exp(log_weights[p] - max_logw);
    }
    const double inc_loglik = max_logw + std::log(sum_exp) - std::log(static_cast<double>(num_particles));
    loglik_by_time[t] = inc_loglik;
    total_loglik += inc_loglik;

    // Normalized weights and ESS.
    Rcpp::NumericVector w(num_particles);
    double w_sum = 0.0;
    for (int p = 0; p < num_particles; ++p) {
      w[p] = std::exp(log_weights[p] - max_logw);
      w_sum += w[p];
    }
    for (int p = 0; p < num_particles; ++p) {
      w[p] /= w_sum;
    }
    double sumsq = 0.0;
    for (int p = 0; p < num_particles; ++p) {
      sumsq += w[p] * w[p];
    }
    ess_by_time[t] = 1.0 / sumsq;

    // Multinomial resampling every step.
    Rcpp::NumericVector cdf(num_particles);
    cdf[0] = w[0];
    for (int p = 1; p < num_particles; ++p) {
      cdf[p] = cdf[p - 1] + w[p];
    }
    Rcpp::IntegerVector resampled_states(num_particles);
    for (int m = 0; m < num_particles; ++m) {
      const double u = R::runif(0.0, 1.0);
      int i = 0;
      while (i < num_particles - 1 && cdf[i] < u) {
        ++i;
      }
      resampled_states[m] = states[i];
    }
    states = resampled_states;

    // Track mean state for diagnostics.
    double state_sum = 0.0;
    for (int p = 0; p < num_particles; ++p) {
      state_sum += states[p];
    }
    mean_state_by_time[t] = static_cast<int>(std::round(state_sum / static_cast<double>(num_particles)));
  }

  return Rcpp::List::create(
      Rcpp::Named("loglik") = total_loglik,
      Rcpp::Named("loglik_by_time") = loglik_by_time,
      Rcpp::Named("ess_by_time") = ess_by_time,
      Rcpp::Named("mean_state_by_time") = mean_state_by_time,
      Rcpp::Named("states_by_time") = states_by_time,
      Rcpp::Named("final_states") = states);
}

// [[Rcpp::export]]
Rcpp::List epi_only_poisson_pf_window_cpp(
    Rcpp::IntegerVector observation_counts,
    Rcpp::IntegerVector observation_times,
    double initial_beta,
    double beta_jitter,
    double beta_refactor,
    double gamma,
    double phi,
    int initial_state,
    int num_particles,
    int seed
) {
  const int n_obs = observation_counts.size();
  if (n_obs == 0) {
    Rcpp::stop("`observation_counts` must have at least one value.");
  }
  if (observation_times.size() != n_obs) {
    Rcpp::stop("`observation_times` must have same length as `observation_counts`.");
  }
  if (num_particles <= 0) {
    Rcpp::stop("`num_particles` must be > 0.");
  }
  if (initial_state <= 0) {
    Rcpp::stop("`initial_state` must be > 0.");
  }
  if (initial_beta < 0.0) {
    Rcpp::stop("`initial_beta` must be >= 0.");
  }
  if (beta_jitter < 0.0) {
    Rcpp::stop("`beta_jitter` must be >= 0.");
  }

  for (int i = 1; i < n_obs; ++i) {
    if (observation_times[i] <= observation_times[i - 1]) {
      Rcpp::stop("`observation_times` must be strictly increasing.");
    }
  }

  Rcpp::Environment base_env("package:base");
  Rcpp::Function set_seed = base_env["set.seed"];
  set_seed(seed);

  const int n_days = observation_times[n_obs - 1] + 1;
  Rcpp::IntegerVector states(num_particles, initial_state);
  Rcpp::NumericVector betas(num_particles, initial_beta);
  Rcpp::NumericVector log_weights(num_particles);
  Rcpp::IntegerVector window_positive_tests(num_particles);
  Rcpp::NumericVector ess_by_obs(n_obs);
  Rcpp::NumericVector loglik_by_obs(n_obs);
  Rcpp::IntegerMatrix ancestor_index_by_obs(n_obs, num_particles);
  Rcpp::IntegerVector mean_state_by_day(n_days);
  Rcpp::IntegerMatrix states_by_day(n_days, num_particles);
  Rcpp::NumericMatrix betas_by_day(n_days, num_particles);
  Rcpp::NumericVector window_expected_tests(n_obs);
  Rcpp::IntegerMatrix window_tests_by_particle(n_obs, num_particles);

  double total_loglik = 0.0;
  int obs_idx = 0;

  for (int day = 0; day < n_days; ++day) {
    for (int p = 0; p < num_particles; ++p) {
      int state = states[p];
      double beta_t = betas[p];
      // Looseformbeta: per-particle beta random walk with optional refactor.
      beta_t = std::fabs(beta_t * beta_refactor + R::rnorm(0.0, beta_jitter));
      betas[p] = beta_t;
      betas_by_day(day, p) = beta_t;
      if (state <= 0) {
        states[p] = 0;
        states_by_day(day, p) = 0;
        continue;
      }

      const double birth_rate = std::max(0.0, beta_t * static_cast<double>(state));
      const double death_rate =
          (day > 1) ? std::max(0.0, gamma * static_cast<double>(state)) : 0.0;
      const int births = R::rpois(birth_rate);
      const int deaths = R::rpois(death_rate);
      state = state + births - deaths;
      if (state < 0) {
        state = 0;
      }
      states[p] = state;
      states_by_day(day, p) = state;

      // Java-like approximation to modeled positives from latent state.
      window_positive_tests[p] += static_cast<int>(std::round(static_cast<double>(state) * phi));
    }

    double mean_state = 0.0;
    for (int p = 0; p < num_particles; ++p) {
      mean_state += states[p];
    }
    mean_state_by_day[day] = static_cast<int>(std::round(mean_state / static_cast<double>(num_particles)));

    if (day == observation_times[obs_idx]) {
      for (int p = 0; p < num_particles; ++p) {
        window_tests_by_particle(obs_idx, p) = window_positive_tests[p];
      }

      // Observation checkpoint: compare summed modeled tests in the window to
      // observed positives for this window.
      for (int p = 0; p < num_particles; ++p) {
        const double lambda = std::max(0.001, static_cast<double>(window_positive_tests[p]));
        log_weights[p] = R::dpois(static_cast<double>(observation_counts[obs_idx]), lambda, true);
      }

      double max_logw = R_NegInf;
      for (int p = 0; p < num_particles; ++p) {
        if (log_weights[p] > max_logw) {
          max_logw = log_weights[p];
        }
      }

      if (!R_finite(max_logw)) {
        return Rcpp::List::create(
            Rcpp::Named("loglik") = R_NegInf,
            Rcpp::Named("loglik_by_obs") = loglik_by_obs,
            Rcpp::Named("ess_by_obs") = ess_by_obs,
            Rcpp::Named("ancestor_index_by_obs") = ancestor_index_by_obs,
            Rcpp::Named("mean_state_by_day") = mean_state_by_day,
            Rcpp::Named("states_by_day") = states_by_day,
            Rcpp::Named("betas_by_day") = betas_by_day,
            Rcpp::Named("window_expected_tests") = window_expected_tests,
            Rcpp::Named("window_tests_by_particle") = window_tests_by_particle,
            Rcpp::Named("final_states") = states);
      }

      double sum_exp = 0.0;
      for (int p = 0; p < num_particles; ++p) {
        sum_exp += std::exp(log_weights[p] - max_logw);
      }
      const double inc_loglik =
          max_logw + std::log(sum_exp) - std::log(static_cast<double>(num_particles));
      loglik_by_obs[obs_idx] = inc_loglik;
      total_loglik += inc_loglik;

      Rcpp::NumericVector w(num_particles);
      double w_sum = 0.0;
      double window_sum = 0.0;
      for (int p = 0; p < num_particles; ++p) {
        w[p] = std::exp(log_weights[p] - max_logw);
        w_sum += w[p];
        window_sum += static_cast<double>(window_positive_tests[p]);
      }
      window_expected_tests[obs_idx] = window_sum / static_cast<double>(num_particles);
      for (int p = 0; p < num_particles; ++p) {
        w[p] /= w_sum;
      }

      double sumsq = 0.0;
      for (int p = 0; p < num_particles; ++p) {
        sumsq += w[p] * w[p];
      }
      ess_by_obs[obs_idx] = 1.0 / sumsq;

      // Resample at observation checkpoints.
      Rcpp::NumericVector cdf(num_particles);
      cdf[0] = w[0];
      for (int p = 1; p < num_particles; ++p) {
        cdf[p] = cdf[p - 1] + w[p];
      }
      Rcpp::IntegerVector resampled_states(num_particles);
      Rcpp::NumericVector resampled_betas(num_particles);
      Rcpp::IntegerMatrix resampled_states_hist(day + 1, num_particles);
      Rcpp::NumericMatrix resampled_betas_hist(day + 1, num_particles);
      for (int p = 0; p < num_particles; ++p) {
        window_positive_tests[p] = 0;
      }
      for (int m = 0; m < num_particles; ++m) {
        const double u = R::runif(0.0, 1.0);
        int i = 0;
        while (i < num_particles - 1 && cdf[i] < u) {
          ++i;
        }
        ancestor_index_by_obs(obs_idx, m) = i;
        resampled_states[m] = states[i];
        resampled_betas[m] = betas[i];
        for (int d = 0; d <= day; ++d) {
          resampled_states_hist(d, m) = states_by_day(d, i);
          resampled_betas_hist(d, m) = betas_by_day(d, i);
        }
      }
      states = resampled_states;
      betas = resampled_betas;
      for (int m = 0; m < num_particles; ++m) {
        for (int d = 0; d <= day; ++d) {
          states_by_day(d, m) = resampled_states_hist(d, m);
          betas_by_day(d, m) = resampled_betas_hist(d, m);
        }
      }

      if (obs_idx < n_obs - 1) {
        ++obs_idx;
      }
    }
  }

  return Rcpp::List::create(
      Rcpp::Named("loglik") = total_loglik,
      Rcpp::Named("loglik_by_obs") = loglik_by_obs,
      Rcpp::Named("ess_by_obs") = ess_by_obs,
      Rcpp::Named("ancestor_index_by_obs") = ancestor_index_by_obs,
      Rcpp::Named("mean_state_by_day") = mean_state_by_day,
      Rcpp::Named("states_by_day") = states_by_day,
      Rcpp::Named("betas_by_day") = betas_by_day,
      Rcpp::Named("window_expected_tests") = window_expected_tests,
      Rcpp::Named("window_tests_by_particle") = window_tests_by_particle,
      Rcpp::Named("final_states") = states);
}

static double pf_window_loglik_only_internal(
    const Rcpp::IntegerVector& observation_counts,
    const Rcpp::IntegerVector& observation_times,
    double initial_beta,
    double beta_jitter,
    double beta_refactor,
    double gamma,
    double phi,
    int initial_state,
    int num_particles
) {
  const int n_obs = observation_counts.size();
  const int n_days = observation_times[n_obs - 1] + 1;
  Rcpp::IntegerVector states(num_particles, initial_state);
  Rcpp::NumericVector betas(num_particles, initial_beta);
  Rcpp::NumericVector log_weights(num_particles);
  Rcpp::IntegerVector window_positive_tests(num_particles);
  double total_loglik = 0.0;
  int obs_idx = 0;

  for (int day = 0; day < n_days; ++day) {
    for (int p = 0; p < num_particles; ++p) {
      int state = states[p];
      double beta_t = betas[p];
      beta_t = std::fabs(beta_t * beta_refactor + R::rnorm(0.0, beta_jitter));
      betas[p] = beta_t;
      if (state <= 0) {
        states[p] = 0;
        continue;
      }
      const double birth_rate = std::max(0.0, beta_t * static_cast<double>(state));
      const double death_rate =
          (day > 1) ? std::max(0.0, gamma * static_cast<double>(state)) : 0.0;
      const int births = R::rpois(birth_rate);
      const int deaths = R::rpois(death_rate);
      state = state + births - deaths;
      if (state < 0) {
        state = 0;
      }
      states[p] = state;
      window_positive_tests[p] += static_cast<int>(std::round(static_cast<double>(state) * phi));
    }

    if (day == observation_times[obs_idx]) {
      for (int p = 0; p < num_particles; ++p) {
        const double lambda = std::max(0.001, static_cast<double>(window_positive_tests[p]));
        log_weights[p] = R::dpois(static_cast<double>(observation_counts[obs_idx]), lambda, true);
      }

      double max_logw = R_NegInf;
      for (int p = 0; p < num_particles; ++p) {
        if (log_weights[p] > max_logw) {
          max_logw = log_weights[p];
        }
      }
      if (!R_finite(max_logw)) {
        return R_NegInf;
      }
      double sum_exp = 0.0;
      for (int p = 0; p < num_particles; ++p) {
        sum_exp += std::exp(log_weights[p] - max_logw);
      }
      const double inc_loglik =
          max_logw + std::log(sum_exp) - std::log(static_cast<double>(num_particles));
      total_loglik += inc_loglik;

      Rcpp::NumericVector w(num_particles);
      double w_sum = 0.0;
      for (int p = 0; p < num_particles; ++p) {
        w[p] = std::exp(log_weights[p] - max_logw);
        w_sum += w[p];
      }
      for (int p = 0; p < num_particles; ++p) {
        w[p] /= w_sum;
      }

      Rcpp::NumericVector cdf(num_particles);
      cdf[0] = w[0];
      for (int p = 1; p < num_particles; ++p) {
        cdf[p] = cdf[p - 1] + w[p];
      }
      Rcpp::IntegerVector resampled_states(num_particles);
      Rcpp::NumericVector resampled_betas(num_particles);
      for (int p = 0; p < num_particles; ++p) {
        window_positive_tests[p] = 0;
      }
      for (int m = 0; m < num_particles; ++m) {
        const double u = R::runif(0.0, 1.0);
        int i = 0;
        while (i < num_particles - 1 && cdf[i] < u) {
          ++i;
        }
        resampled_states[m] = states[i];
        resampled_betas[m] = betas[i];
      }
      states = resampled_states;
      betas = resampled_betas;
      if (obs_idx < n_obs - 1) {
        ++obs_idx;
      }
    }
  }
  return total_loglik;
}

// [[Rcpp::export]]
Rcpp::List run_mh_chain_looseformbeta_cpp(
    Rcpp::IntegerVector observation_counts,
    Rcpp::IntegerVector observation_times,
    int n_steps,
    int num_particles,
    int initial_state,
    double beta_refactor,
    Rcpp::NumericVector init_params,
    Rcpp::NumericVector proposal_sds,
    Rcpp::NumericVector lower_bounds,
    Rcpp::NumericVector upper_bounds,
    int seed
) {
  if (init_params.size() != 4 || proposal_sds.size() != 4 ||
      lower_bounds.size() != 4 || upper_bounds.size() != 4) {
    Rcpp::stop("init/proposal/bounds vectors must each have length 4.");
  }
  if (n_steps <= 0) {
    Rcpp::stop("`n_steps` must be > 0.");
  }
  Rcpp::Environment base_env("package:base");
  Rcpp::Function set_seed = base_env["set.seed"];
  set_seed(seed);

  auto in_bounds = [&](const Rcpp::NumericVector& x) {
    for (int j = 0; j < 4; ++j) {
      if (x[j] < lower_bounds[j] || x[j] > upper_bounds[j]) {
        return false;
      }
    }
    return true;
  };

  Rcpp::NumericMatrix samples(n_steps, 4);
  colnames(samples) = Rcpp::CharacterVector::create(
      "initial_beta", "beta_jitter", "gamma", "phi");
  Rcpp::NumericVector loglik_trace(n_steps);
  Rcpp::LogicalVector accepted(n_steps);

  Rcpp::NumericVector current(4);
  for (int j = 0; j < 4; ++j) current[j] = init_params[j];
  if (!in_bounds(current)) {
    Rcpp::stop("`init_params` are outside prior bounds.");
  }

  double current_ll = pf_window_loglik_only_internal(
      observation_counts, observation_times,
      current[0], current[1], beta_refactor, current[2], current[3],
      initial_state, num_particles);
  if (!R_finite(current_ll)) {
    Rcpp::stop("Initial parameter set produced non-finite log-likelihood.");
  }

  int n_accept = 0;
  for (int i = 0; i < n_steps; ++i) {
    Rcpp::NumericVector cand(4);
    for (int j = 0; j < 4; ++j) {
      const double logx = std::log(current[j]);
      cand[j] = std::exp(logx + R::rnorm(0.0, proposal_sds[j]));
    }

    bool accept = false;
    double cand_ll = R_NegInf;
    if (in_bounds(cand)) {
      cand_ll = pf_window_loglik_only_internal(
          observation_counts, observation_times,
          cand[0], cand[1], beta_refactor, cand[2], cand[3],
          initial_state, num_particles);
      if (R_finite(cand_ll)) {
        // Jacobian term from log-scale random walk proposal.
        double jac = 0.0;
        for (int j = 0; j < 4; ++j) {
          jac += std::log(cand[j]) - std::log(current[j]);
        }
        const double log_alpha = (cand_ll - current_ll) + jac;
        accept = (std::log(R::runif(0.0, 1.0)) < log_alpha);
      }
    }

    if (accept) {
      current = cand;
      current_ll = cand_ll;
      ++n_accept;
      accepted[i] = true;
    } else {
      accepted[i] = false;
    }

    for (int j = 0; j < 4; ++j) {
      samples(i, j) = current[j];
    }
    loglik_trace[i] = current_ll;
  }

  return Rcpp::List::create(
      Rcpp::Named("samples") = samples,
      Rcpp::Named("loglik_trace") = loglik_trace,
      Rcpp::Named("accepted") = accepted,
      Rcpp::Named("acceptance_rate") = static_cast<double>(n_accept) / static_cast<double>(n_steps));
}

