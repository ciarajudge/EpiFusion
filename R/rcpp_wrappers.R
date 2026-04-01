#' Add Two Numbers Using C++
#'
#' Minimal example wrapper around an Rcpp backend function.
#'
#' @param x Numeric scalar.
#' @param y Numeric scalar.
#'
#' @return Numeric scalar equal to `x + y`.
#' @export
add_two <- function(x, y) {
  add_two_cpp(x, y)
}

#' Show Backend Status
#'
#' Utility function to confirm package backend setup.
#'
#' @return Named list describing backend options.
#' @export
epifusion_backend_info <- function() {
  list(
    package = "EpiFusion",
    r_backend = TRUE,
    rcpp_backend = TRUE,
    java_sources_present = TRUE
  )
}

#' Compute Effective Reproduction Number (Rt)
#'
#' Computes daily effective reproduction numbers using the same windowing logic
#' currently used in the Java `rtCalculator` implementation.
#'
#' @param infections Integer vector of daily infections (typically cumulative
#'   infections as currently used by Java code).
#' @param gen_time Numeric vector for the generation time distribution.
#'
#' @return Numeric vector of Rt values with length equal to `infections`.
#' @export
compute_rt <- function(infections, gen_time) {
  if (length(infections) == 0) {
    return(numeric())
  }
  if (any(is.na(infections)) || any(is.na(gen_time))) {
    stop("`infections` and `gen_time` must not contain NA values.", call. = FALSE)
  }

  epifusion_compute_rt_cpp(as.integer(infections), as.numeric(gen_time))
}

#' Poisson Epi Log-Likelihood Across Particles
#'
#' Computes per-particle Poisson log-likelihood totals using two possible memory
#' layouts for `positive_tests`:
#' - `"time_particles"`: matrix with time as rows and particles as columns.
#' - `"particles_time"`: matrix with particles as rows and time as columns.
#'
#' @param positive_tests Numeric matrix of expected positive tests.
#' @param incidence Integer vector of observed incidence over time.
#' @param layout Character scalar; one of `"time_particles"` or
#'   `"particles_time"`.
#'
#' @return Numeric vector of log-likelihood totals, one value per particle.
#' @export
epi_loglik_poisson_particles <- function(
  positive_tests,
  incidence,
  layout = c("time_particles", "particles_time")
) {
  layout <- match.arg(layout)
  incidence <- as.integer(incidence)
  positive_tests <- as.matrix(positive_tests)

  if (layout == "time_particles") {
    epi_loglik_poisson_tp_cpp(positive_tests, incidence)
  } else {
    epi_loglik_poisson_pt_cpp(positive_tests, incidence)
  }
}

#' Benchmark Particle Matrix Layouts
#'
#' Simple benchmark helper comparing the two Poisson likelihood kernels.
#'
#' @param n_particles Number of particles to simulate.
#' @param n_time Number of time points to simulate.
#' @param reps Number of repetitions for each kernel.
#' @param seed RNG seed for reproducible synthetic data.
#'
#' @return Data frame with elapsed seconds for each layout.
#' @export
benchmark_epi_layouts <- function(
  n_particles = 2000L,
  n_time = 365L,
  reps = 20L,
  seed = 1L
) {
  set.seed(as.integer(seed))
  n_particles <- as.integer(n_particles)
  n_time <- as.integer(n_time)
  reps <- as.integer(reps)

  lambda_tp <- matrix(
    rgamma(n_time * n_particles, shape = 5, rate = 0.8),
    nrow = n_time,
    ncol = n_particles
  )
  lambda_pt <- t(lambda_tp)
  incidence <- rpois(n_time, lambda = pmax(rowMeans(lambda_tp), 0.1))

  t_tp <- system.time({
    for (i in seq_len(reps)) {
      epi_loglik_poisson_tp_cpp(lambda_tp, incidence)
    }
  })[["elapsed"]]

  t_pt <- system.time({
    for (i in seq_len(reps)) {
      epi_loglik_poisson_pt_cpp(lambda_pt, incidence)
    }
  })[["elapsed"]]

  data.frame(
    layout = c("time_particles", "particles_time"),
    elapsed_seconds = c(t_tp, t_pt),
    n_particles = n_particles,
    n_time = n_time,
    reps = reps,
    stringsAsFactors = FALSE
  )
}

#' Read EpiFusion XML Inputs
#'
#' Parses an EpiFusion XML input file and returns incidence and metadata in a
#' structure aligned with existing EpiFusionUtilities conventions.
#'
#' @param xml_filepath Path to EpiFusion XML file.
#'
#' @return A list including `index_date`, `case_incidence` (with `Date` and
#'   `Cases` columns), raw incidence vectors, and selected model/parameter
#'   fields.
#' @export
read_epifusion_xml_inputs <- function(xml_filepath) {
  doc <- xml2::read_xml(xml_filepath)

  get1 <- function(xpath) {
    node <- xml2::xml_find_first(doc, xpath)
    if (inherits(node, "xml_missing")) {
      return(NA_character_)
    }
    val <- xml2::xml_text(node)
    if (is.null(val) || identical(val, "")) NA_character_ else val
  }

  parse_num_vec <- function(x) {
    if (is.na(x)) {
      return(numeric())
    }
    parts <- strsplit(trimws(x), "\\s+")[[1]]
    as.numeric(parts[nzchar(parts)])
  }

  index_date_chr <- get1("//indexdate")
  incidence_vals <- parse_num_vec(get1("//incidenceVals"))
  incidence_times <- parse_num_vec(get1("//incidenceTimes"))

  if (!is.na(index_date_chr) && length(incidence_times) > 0) {
    date_vec <- as.Date(index_date_chr) + as.integer(incidence_times)
  } else {
    date_vec <- rep(as.Date(NA), length(incidence_vals))
  }

  case_incidence <- data.frame(
    Date = date_vec,
    Cases = as.numeric(incidence_vals)
  )

  list(
    index_date = as.Date(index_date_chr),
    case_incidence = case_incidence,
    incidence_times = incidence_times,
    incidence_vals = incidence_vals,
    tree_file = get1("//treeFile"),
    epi_observation_model = get1("//epiObservationModel"),
    overdispersion = suppressWarnings(as.numeric(get1("//overdispersion"))),
    num_particles = suppressWarnings(as.integer(get1("//numParticles"))),
    num_steps = suppressWarnings(as.integer(get1("//numSteps"))),
    num_chains = suppressWarnings(as.integer(get1("//numChains")))
  )
}

#' Benchmark Layouts Using XML Incidence
#'
#' Benchmarks the two particle matrix layouts using incidence extracted from an
#' EpiFusion XML file and synthetic expected positives anchored to those counts.
#'
#' @param xml_filepath Path to EpiFusion XML file.
#' @param n_particles Number of particles to simulate.
#' @param reps Number of benchmark repetitions.
#' @param jitter_sd Lognormal jitter standard deviation around incidence mean.
#' @param seed RNG seed.
#'
#' @return Data frame with elapsed times for each layout.
#' @export
benchmark_epi_layouts_from_xml <- function(
  xml_filepath,
  n_particles = 5000L,
  reps = 30L,
  jitter_sd = 0.25,
  seed = 1L
) {
  parsed <- read_epifusion_xml_inputs(xml_filepath)
  incidence <- as.integer(round(parsed$incidence_vals))
  n_time <- length(incidence)
  if (n_time == 0) {
    stop("No incidence values found in XML.", call. = FALSE)
  }

  set.seed(as.integer(seed))
  n_particles <- as.integer(n_particles)
  reps <- as.integer(reps)
  base_lambda <- pmax(as.numeric(incidence), 0.1)
  noise <- matrix(
    rlnorm(n_time * n_particles, meanlog = 0, sdlog = jitter_sd),
    nrow = n_time,
    ncol = n_particles
  )
  lambda_tp <- noise * base_lambda
  lambda_pt <- t(lambda_tp)

  t_tp <- system.time({
    for (i in seq_len(reps)) {
      epi_loglik_poisson_tp_cpp(lambda_tp, incidence)
    }
  })[["elapsed"]]

  t_pt <- system.time({
    for (i in seq_len(reps)) {
      epi_loglik_poisson_pt_cpp(lambda_pt, incidence)
    }
  })[["elapsed"]]

  data.frame(
    layout = c("time_particles", "particles_time"),
    elapsed_seconds = c(t_tp, t_pt),
    n_particles = n_particles,
    n_time = n_time,
    reps = reps,
    xml_filepath = xml_filepath,
    stringsAsFactors = FALSE
  )
}

#' Build an EpiFusion Configuration Object
#'
#' Creates a normalized in-memory configuration object from native R inputs so
#' XML is not required for model setup.
#'
#' @param case_incidence Data frame with columns `Date` and `Cases`.
#' @param tree Optional phylogenetic tree object or tree filepath.
#' @param index_date Optional outbreak index date. If omitted, uses
#'   `min(case_incidence$Date)`.
#' @param analysis Optional named list of analysis settings.
#' @param model Optional named list of model settings.
#' @param parameters Optional named list of parameter settings.
#' @param priors Optional named list of prior settings.
#' @param loggers Optional named list of logger settings.
#'
#' @return An object of class `epifusion_config`.
#' @export
epifusion_config <- function(
  case_incidence,
  tree = NULL,
  index_date = NULL,
  analysis = list(),
  model = list(),
  parameters = list(),
  priors = list(),
  loggers = list()
) {
  if (!is.data.frame(case_incidence)) {
    stop("`case_incidence` must be a data frame.", call. = FALSE)
  }
  if (!all(c("Date", "Cases") %in% names(case_incidence))) {
    stop("`case_incidence` must contain `Date` and `Cases` columns.", call. = FALSE)
  }

  ci <- case_incidence
  ci$Date <- as.Date(ci$Date)
  ci$Cases <- as.numeric(ci$Cases)

  if (any(is.na(ci$Date))) {
    stop("`case_incidence$Date` contains invalid/missing dates.", call. = FALSE)
  }
  if (any(is.na(ci$Cases))) {
    stop("`case_incidence$Cases` contains missing values.", call. = FALSE)
  }
  if (any(ci$Cases < 0)) {
    stop("`case_incidence$Cases` must be non-negative.", call. = FALSE)
  }

  ci <- ci[order(ci$Date), c("Date", "Cases"), drop = FALSE]

  if (is.null(index_date)) {
    index_date <- min(ci$Date)
  }
  index_date <- as.Date(index_date)
  if (is.na(index_date)) {
    stop("`index_date` must be coercible to Date.", call. = FALSE)
  }

  incidence_times <- as.integer(ci$Date - index_date)
  incidence_vals <- as.numeric(ci$Cases)

  out <- list(
    data = list(
      index_date = index_date,
      case_incidence = ci,
      incidence_times = incidence_times,
      incidence_vals = incidence_vals,
      tree = tree
    ),
    analysis = analysis,
    model = model,
    parameters = parameters,
    priors = priors,
    loggers = loggers
  )
  class(out) <- "epifusion_config"
  out
}

#' Run Epi-Only Poisson Particle Filter
#'
#' Runs a bootstrap particle filter for an epi-only Poisson observation model
#' using fixed parameters.
#'
#' @param config An `epifusion_config` object.
#' @param initial_beta Initial transmission rate for each particle.
#' @param beta_jitter Random-walk standard deviation for per-particle daily
#'   beta updates.
#' @param beta_refactor Multiplicative daily beta refactor (default 1.0).
#' @param gamma Recovery/removal rate parameter.
#' @param phi Observation scaling parameter.
#' @param initial_state Initial latent infected state for all particles.
#' @param num_particles Number of particles.
#' @param seed RNG seed.
#'
#' @return A list with total log-likelihood and filter diagnostics.
#' @export
run_epi_only_poisson_pf <- function(
  config,
  initial_beta,
  beta_jitter,
  beta_refactor = 1.0,
  gamma,
  phi,
  initial_state = 1L,
  num_particles = 1000L,
  seed = 1L
) {
  if (!inherits(config, "epifusion_config")) {
    stop("`config` must be an `epifusion_config` object.", call. = FALSE)
  }
  observation_counts <- as.integer(round(config$data$incidence_vals))
  observation_times <- as.integer(config$data$incidence_times)

  if (length(observation_counts) == 0) {
    stop("`config` has no incidence values.", call. = FALSE)
  }
  if (length(observation_times) != length(observation_counts)) {
    stop("`config$data$incidence_times` must match incidence length.", call. = FALSE)
  }
  if (any(is.na(observation_times))) {
    stop("`config$data$incidence_times` must not contain NA.", call. = FALSE)
  }
  if (any(diff(observation_times) <= 0)) {
    stop("`config$data$incidence_times` must be strictly increasing.", call. = FALSE)
  }

  epi_only_poisson_pf_window_cpp(
    observation_counts = observation_counts,
    observation_times = observation_times,
    initial_beta = as.numeric(initial_beta),
    beta_jitter = as.numeric(beta_jitter),
    beta_refactor = as.numeric(beta_refactor),
    gamma = as.numeric(gamma),
    phi = as.numeric(phi),
    initial_state = as.integer(initial_state),
    num_particles = as.integer(num_particles),
    seed = as.integer(seed)
  )
}

#' Run a Looseformbeta MH Chain
#'
#' Runs a Metropolis-Hastings chain around the looseformbeta particle filter.
#'
#' @param config An `epifusion_config` object.
#' @param n_steps Number of MH steps.
#' @param num_particles Number of particles used in each PF likelihood estimate.
#' @param initial_state Initial latent infected state.
#' @param beta_refactor Daily multiplicative beta refactor.
#' @param init_params Named numeric vector with elements
#'   `initial_beta`, `beta_jitter`, `gamma`, `phi`.
#' @param proposal_sds Named numeric vector of proposal SDs on the log scale.
#' @param lower_bounds Named numeric vector of lower bounds.
#' @param upper_bounds Named numeric vector of upper bounds.
#' @param seed RNG seed.
#'
#' @return A list containing MH samples, log-likelihood trace, acceptance
#'   indicators, and acceptance rate.
#' @export
run_mcmc_looseformbeta <- function(
  config,
  n_steps = 1000L,
  num_particles = 1000L,
  initial_state = 5L,
  beta_refactor = 1.0,
  init_params = c(initial_beta = 0.3, beta_jitter = 0.02, gamma = 0.143, phi = 0.02),
  proposal_sds = c(initial_beta = 0.1, beta_jitter = 0.1, gamma = 0.1, phi = 0.1),
  lower_bounds = c(initial_beta = 0.1, beta_jitter = 0.001, gamma = 0.0, phi = 0.0),
  upper_bounds = c(initial_beta = 0.5, beta_jitter = 0.1, gamma = 5.0, phi = 5.0),
  seed = 1L
) {
  if (!inherits(config, "epifusion_config")) {
    stop("`config` must be an `epifusion_config` object.", call. = FALSE)
  }
  observation_counts <- as.integer(round(config$data$incidence_vals))
  observation_times <- as.integer(config$data$incidence_times)
  req <- c("initial_beta", "beta_jitter", "gamma", "phi")
  if (!all(req %in% names(init_params))) {
    stop("`init_params` must be named with initial_beta, beta_jitter, gamma, phi.", call. = FALSE)
  }

  run_mh_chain_looseformbeta_cpp(
    observation_counts = observation_counts,
    observation_times = observation_times,
    n_steps = as.integer(n_steps),
    num_particles = as.integer(num_particles),
    initial_state = as.integer(initial_state),
    beta_refactor = as.numeric(beta_refactor),
    init_params = as.numeric(init_params[req]),
    proposal_sds = as.numeric(proposal_sds[req]),
    lower_bounds = as.numeric(lower_bounds[req]),
    upper_bounds = as.numeric(upper_bounds[req]),
    seed = as.integer(seed)
  )
}

#' Run Adaptive-Warmup Looseformbeta MH Chain
#'
#' Performs proposal-scale warmup using Robbins-Monro adaptation on the log
#' proposal standard deviations, then runs a fixed-kernel MH chain.
#'
#' @param config An `epifusion_config` object.
#' @param n_steps Number of post-warmup MH steps.
#' @param warmup_steps Number of adaptive warmup steps.
#' @param adapt_interval Number of iterations per warmup adaptation block.
#' @param target_accept Target acceptance rate for adaptation.
#' @param adaptation_rate Base adaptation rate (diminishes over blocks).
#' @inheritParams run_mcmc_looseformbeta
#'
#' @return A list containing warmup history and final chain output.
#' @export
run_mcmc_looseformbeta_adaptive <- function(
  config,
  n_steps = 1000L,
  warmup_steps = 500L,
  adapt_interval = 50L,
  target_accept = 0.234,
  adaptation_rate = 0.8,
  num_particles = 1000L,
  initial_state = 5L,
  beta_refactor = 1.0,
  init_params = c(initial_beta = 0.3, beta_jitter = 0.02, gamma = 0.143, phi = 0.02),
  proposal_sds = c(initial_beta = 0.1, beta_jitter = 0.1, gamma = 0.1, phi = 0.1),
  lower_bounds = c(initial_beta = 0.1, beta_jitter = 0.001, gamma = 0.0, phi = 0.0),
  upper_bounds = c(initial_beta = 0.5, beta_jitter = 0.1, gamma = 5.0, phi = 5.0),
  seed = 1L
) {
  req <- c("initial_beta", "beta_jitter", "gamma", "phi")
  current_init <- as.numeric(init_params[req])
  names(current_init) <- req
  current_prop <- as.numeric(proposal_sds[req])
  names(current_prop) <- req

  n_blocks <- as.integer(ceiling(warmup_steps / adapt_interval))
  hist <- data.frame(
    block = integer(),
    accept_rate = numeric(),
    sd_initial_beta = numeric(),
    sd_beta_jitter = numeric(),
    sd_gamma = numeric(),
    sd_phi = numeric(),
    stringsAsFactors = FALSE
  )

  current_seed <- as.integer(seed)
  if (warmup_steps > 0) {
    for (b in seq_len(n_blocks)) {
      this_steps <- if (b < n_blocks) as.integer(adapt_interval) else as.integer(warmup_steps - (b - 1L) * adapt_interval)
      if (this_steps <= 0) {
        next
      }

      warm <- run_mcmc_looseformbeta(
        config = config,
        n_steps = this_steps,
        num_particles = num_particles,
        initial_state = initial_state,
        beta_refactor = beta_refactor,
        init_params = current_init,
        proposal_sds = current_prop,
        lower_bounds = lower_bounds,
        upper_bounds = upper_bounds,
        seed = current_seed
      )

      ar <- as.numeric(warm$acceptance_rate)
      gain <- adaptation_rate / sqrt(b)
      log_prop <- log(current_prop)
      log_prop <- log_prop + gain * (ar - target_accept)
      current_prop <- pmax(exp(log_prop), 1e-6)
      names(current_prop) <- req

      current_init <- warm$samples[nrow(warm$samples), ]
      current_init <- as.numeric(current_init)
      names(current_init) <- req
      current_seed <- current_seed + 1L

      hist <- rbind(
        hist,
        data.frame(
          block = b,
          accept_rate = ar,
          sd_initial_beta = current_prop["initial_beta"],
          sd_beta_jitter = current_prop["beta_jitter"],
          sd_gamma = current_prop["gamma"],
          sd_phi = current_prop["phi"],
          stringsAsFactors = FALSE
        )
      )
    }
  }

  final <- run_mcmc_looseformbeta(
    config = config,
    n_steps = as.integer(n_steps),
    num_particles = as.integer(num_particles),
    initial_state = as.integer(initial_state),
    beta_refactor = as.numeric(beta_refactor),
    init_params = current_init,
    proposal_sds = current_prop,
    lower_bounds = lower_bounds,
    upper_bounds = upper_bounds,
    seed = as.integer(current_seed)
  )

  list(
    warmup_history = hist,
    tuned_proposal_sds = current_prop,
    final_init = current_init,
    chain = final
  )
}

#' Plot MCMC Traces with Truth Lines
#'
#' Creates a multi-panel trace plot for core parameters and log-likelihood.
#' Horizontal reference lines are drawn for known truth values of `gamma` and
#' `phi`.
#'
#' @param samples Matrix/data frame with columns `initial_beta`, `beta_jitter`,
#'   `gamma`, and `phi`.
#' @param loglik Numeric vector of log-likelihood trace values.
#' @param accepted Optional logical vector of accepted indicators.
#' @param truth_gamma Truth/reference value for gamma.
#' @param truth_phi Truth/reference value for phi.
#' @param output_path Optional PNG output path. If `NULL`, plots to current
#'   device.
#'
#' @return Invisibly returns `output_path`.
#' @export
plot_mcmc_trace_panel <- function(
  samples,
  loglik,
  accepted = NULL,
  truth_gamma = 0.143,
  truth_phi = 0.02,
  output_path = NULL
) {
  s <- as.matrix(samples)
  if (!all(c("initial_beta", "beta_jitter", "gamma", "phi") %in% colnames(s))) {
    stop("`samples` must include columns initial_beta, beta_jitter, gamma, phi.", call. = FALSE)
  }

  if (!is.null(output_path)) {
    png(output_path, width = 1500, height = 1000)
    on.exit(dev.off(), add = TRUE)
  }

  par(mfrow = c(3, 2), mar = c(4, 4, 2, 1))
  plot(s[, "initial_beta"], type = "l", col = "steelblue", xlab = "Step", ylab = "initial_beta", main = "Trace: initial_beta")
  plot(s[, "beta_jitter"], type = "l", col = "steelblue", xlab = "Step", ylab = "beta_jitter", main = "Trace: beta_jitter")
  plot(s[, "gamma"], type = "l", col = "steelblue", xlab = "Step", ylab = "gamma", main = "Trace: gamma")
  abline(h = truth_gamma, col = "firebrick", lwd = 2, lty = 2)
  plot(s[, "phi"], type = "l", col = "steelblue", xlab = "Step", ylab = "phi", main = "Trace: phi")
  abline(h = truth_phi, col = "firebrick", lwd = 2, lty = 2)
  plot(loglik, type = "l", col = "darkorange", xlab = "Step", ylab = "log-likelihood", main = "Trace: log-likelihood")
  if (!is.null(accepted)) {
    plot(cumsum(as.numeric(accepted)) / seq_along(accepted), type = "l", col = "darkgreen",
         xlab = "Step", ylab = "Cumulative acceptance", main = "Acceptance")
  } else {
    plot.new()
    text(0.5, 0.5, "Acceptance trace not provided")
  }

  invisible(output_path)
}

empirical_crps <- function(draws, y) {
  draws <- as.numeric(draws)
  n <- length(draws)
  if (n == 0) return(NA_real_)
  term1 <- mean(abs(draws - y))
  term2 <- 0.5 * mean(abs(outer(draws, draws, "-")))
  term1 - term2
}

#' Evaluate Infection Trajectory Inference
#'
#' Computes trajectory accuracy metrics comparing inferred daily infections to
#' true daily infections.
#'
#' @param inferred_draws Numeric matrix with one row per day and one column per
#'   posterior draw.
#' @param truth Numeric vector of true daily infections.
#' @param alpha Credible interval mass for coverage/width metrics.
#'
#' @return Named list with RMSE, coverage, mean HPD width (equal-tail interval),
#'   and mean CRPS.
#' @export
evaluate_infection_trajectory_metrics <- function(inferred_draws, truth, alpha = 0.95) {
  draws <- as.matrix(inferred_draws)
  truth <- as.numeric(truth)
  if (nrow(draws) != length(truth)) {
    stop("`inferred_draws` rows must match length of `truth`.", call. = FALSE)
  }

  post_mean <- rowMeans(draws)
  ok_mean <- is.finite(post_mean) & is.finite(truth)
  rmse <- sqrt(mean((post_mean[ok_mean] - truth[ok_mean])^2))

  lo <- apply(draws, 1, quantile, probs = (1 - alpha) / 2, na.rm = TRUE)
  hi <- apply(draws, 1, quantile, probs = 1 - (1 - alpha) / 2, na.rm = TRUE)
  ok_cov <- is.finite(truth) & is.finite(lo) & is.finite(hi)
  coverage <- mean(truth[ok_cov] >= lo[ok_cov] & truth[ok_cov] <= hi[ok_cov])
  hpd_width <- mean((hi - lo)[ok_cov])

  crps_vals <- vapply(seq_len(nrow(draws)), function(i) {
    if (!is.finite(truth[i])) return(NA_real_)
    empirical_crps(draws[i, is.finite(draws[i, ])], truth[i])
  }, numeric(1))
  crps <- mean(crps_vals, na.rm = TRUE)

  list(
    rmse = rmse,
    coverage = coverage,
    hpd_width = hpd_width,
    crps = crps
  )
}

#' Infer Daily Infection Draws from MCMC Samples
#'
#' Uses posterior parameter samples to generate daily infection trajectories via
#' the particle filter.
#'
#' @param config An `epifusion_config` object.
#' @param samples MCMC sample matrix/data frame containing
#'   `initial_beta`,`beta_jitter`,`gamma`,`phi`.
#' @param draw_indices Integer indices of rows in `samples` to evaluate.
#' @param num_particles Number of particles per posterior predictive PF draw.
#' @param initial_state Initial latent infected state.
#' @param beta_refactor Beta refactor passed to PF.
#' @param seed RNG seed base.
#'
#' @return Numeric matrix of inferred daily infections (days x draws), using PF
#'   mean daily states per draw.
#' @export
infer_daily_infections_from_samples <- function(
  config,
  samples,
  draw_indices = NULL,
  num_particles = 300L,
  initial_state = 5L,
  beta_refactor = 1.0,
  seed = 1L
) {
  s <- as.matrix(samples)
  req <- c("initial_beta", "beta_jitter", "gamma", "phi")
  if (!all(req %in% colnames(s))) {
    stop("`samples` must include initial_beta, beta_jitter, gamma, phi.", call. = FALSE)
  }
  if (is.null(draw_indices)) {
    draw_indices <- seq_len(nrow(s))
  }
  draw_indices <- as.integer(draw_indices)
  out_list <- vector("list", length(draw_indices))

  for (k in seq_along(draw_indices)) {
    idx <- draw_indices[k]
    pf <- run_epi_only_poisson_pf(
      config = config,
      initial_beta = s[idx, "initial_beta"],
      beta_jitter = s[idx, "beta_jitter"],
      beta_refactor = beta_refactor,
      gamma = s[idx, "gamma"],
      phi = s[idx, "phi"],
      initial_state = initial_state,
      num_particles = num_particles,
      seed = as.integer(seed + k - 1L)
    )
    out_list[[k]] <- as.numeric(pf$mean_state_by_day)
  }

  do.call(cbind, out_list)
}

#' Infer Rt Draws from Infection Draws
#'
#' Applies `compute_rt()` column-wise to a matrix of inferred daily infection
#' draws.
#'
#' @param infection_draws Numeric matrix with rows = days and cols = draws.
#' @param gen_time Generation-time distribution passed to `compute_rt()`.
#'
#' @return Numeric matrix of Rt draws (days x draws).
#' @export
infer_rt_from_infection_draws <- function(infection_draws, gen_time = c(0.2, 0.3, 0.5)) {
  x <- as.matrix(infection_draws)
  rt_cols <- lapply(seq_len(ncol(x)), function(j) {
    inf <- pmax(round(x[, j]), 0)
    compute_rt(inf, gen_time = gen_time)
  })
  do.call(cbind, rt_cols)
}

#' Infer Rt Draws from Beta and Gamma Samples
#'
#' Computes Rt trajectories directly from process parameters as:
#' `Rt(t) = beta(t) / gamma`, with `gamma` typically constant within each MCMC
#' sample and varying across samples.
#'
#' @param beta_draws Numeric matrix with rows = days and cols = posterior draws.
#' @param gamma_draws Numeric vector of length `ncol(beta_draws)`, containing the
#'   sampled gamma for each posterior draw.
#' @param min_gamma Small positive floor used to avoid division by zero.
#'
#' @return Numeric matrix of Rt draws (days x draws).
#' @export
infer_rt_from_beta_gamma_draws <- function(beta_draws, gamma_draws, min_gamma = 1e-8) {
  b <- as.matrix(beta_draws)
  g <- as.numeric(gamma_draws)
  if (ncol(b) != length(g)) {
    stop("`length(gamma_draws)` must equal `ncol(beta_draws)`.", call. = FALSE)
  }
  if (any(!is.finite(g))) {
    stop("`gamma_draws` must be finite.", call. = FALSE)
  }
  g_safe <- pmax(g, min_gamma)
  rt <- sweep(b, 2, g_safe, "/")
  rt[!is.finite(rt)] <- NA_real_
  rt
}

#' Run Standard Baseline Migration Bundle
#'
#' Creates a timestamped folder in `migration/`, runs adaptive looseformbeta
#' MCMC using baseline inputs, and writes a standard output bundle.
#'
#' @param label Short run label appended to timestamped folder name.
#' @param n_steps Number of post-warmup MCMC steps.
#' @param num_particles Number of particles in PF calls.
#' @param warmup_steps Adaptive warmup steps.
#' @param adapt_interval Warmup adaptation block size.
#' @param seed RNG seed.
#' @param root_dir Project root directory.
#'
#' @return List with `run_dir`, `summary`, and `metrics`.
#' @export
run_migration_baseline <- function(
  label = "iter",
  n_steps = 1000L,
  num_particles = 200L,
  warmup_steps = 500L,
  adapt_interval = 50L,
  n_posterior_pf_draws = 30L,
  seed = 123L,
  root_dir = ".",
  truth_path = file.path(root_dir, "data", "truth", "baseline_truth.csv"),
  incidence_path = file.path(root_dir, "data", "incidence", "baseline_weeklyincidence.txt"),
  rt_gen_time = c(0.2, 0.3, 0.5)
) {
  ts <- format(Sys.time(), "%Y-%m-%d_%H%M%S")
  run_dir <- file.path(root_dir, "migration", paste(ts, label, sep = "_"))
  dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
  raw_dir <- file.path(run_dir, "raw_output")
  dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
  plot_dir <- file.path(run_dir, "plots")
  dir.create(plot_dir, recursive = TRUE, showWarnings = FALSE)

  if (!file.exists(incidence_path) || !file.exists(truth_path)) {
    stop("Baseline incidence/truth files not found at expected paths.", call. = FALSE)
  }

  weekly_inc <- scan(incidence_path, what = numeric(), quiet = TRUE)
  start_date <- as.Date("2024-01-01")
  cfg <- epifusion_config(
    case_incidence = data.frame(
      Date = start_date + 6 + 7 * (seq_along(weekly_inc) - 1),
      Cases = weekly_inc
    ),
    index_date = start_date
  )

  elapsed <- system.time({
    fit <- run_mcmc_looseformbeta_adaptive(
      config = cfg,
      n_steps = as.integer(n_steps),
      warmup_steps = as.integer(warmup_steps),
      adapt_interval = as.integer(adapt_interval),
      num_particles = as.integer(num_particles),
      seed = as.integer(seed)
    )
  })

  chain <- fit$chain
  samples <- as.matrix(chain$samples)
  post_idx <- seq.int(max(1L, floor(nrow(samples) * 0.5)), nrow(samples))
  n_draws <- min(as.integer(n_posterior_pf_draws), length(post_idx))
  if (n_draws <= 0L) {
    stop("`n_posterior_pf_draws` must be >= 1.", call. = FALSE)
  }
  thin_idx <- post_idx[round(seq(1L, length(post_idx), length.out = n_draws))]

  # For trajectory-style raw outputs, sample one random particle from each PF run
  # (one PF run per selected posterior draw).
  sampled_traj_list <- vector("list", length(thin_idx))
  sampled_beta_list <- vector("list", length(thin_idx))
  sampled_pt_list <- vector("list", length(thin_idx))
  for (k in seq_along(thin_idx)) {
    sidx <- thin_idx[k]
    pf_draw <- run_epi_only_poisson_pf(
      config = cfg,
      initial_beta = samples[sidx, "initial_beta"],
      beta_jitter = samples[sidx, "beta_jitter"],
      beta_refactor = 1.0,
      gamma = samples[sidx, "gamma"],
      phi = samples[sidx, "phi"],
      initial_state = 5L,
      num_particles = as.integer(num_particles),
      seed = as.integer(seed + 1000L + k)
    )
    j <- sample.int(ncol(pf_draw$states_by_day), size = 1)
    sampled_traj_list[[k]] <- as.numeric(pf_draw$states_by_day[, j])
    sampled_beta_list[[k]] <- as.numeric(pf_draw$betas_by_day[, j])
    sampled_pt_list[[k]] <- as.numeric(pf_draw$window_tests_by_particle[, j])
  }
  sampled_traj <- do.call(cbind, sampled_traj_list) # days x draws
  sampled_beta <- do.call(cbind, sampled_beta_list) # days x draws
  sampled_pt <- do.call(cbind, sampled_pt_list)     # windows x draws

  truth_df <- read.csv(truth_path, check.names = FALSE)
  day_grid <- 0:(nrow(sampled_traj) - 1)
  idx <- findInterval(day_grid, truth_df$t)
  idx[idx < 1] <- 1L
  truth_daily <- truth_df$I[idx]

  # Posterior predictive PF at posterior mean params for plotting.
  post_mean <- colMeans(samples[post_idx, , drop = FALSE])
  pf <- run_epi_only_poisson_pf(
    config = cfg,
    initial_beta = post_mean["initial_beta"],
    beta_jitter = post_mean["beta_jitter"],
    beta_refactor = 1.0,
    gamma = post_mean["gamma"],
    phi = post_mean["phi"],
    initial_state = 5L,
    num_particles = as.integer(num_particles),
    seed = as.integer(seed + 2000L)
  )

  # Write Java-style single-chain raw outputs first, then compute metrics from
  # those written files.
  fmt_time_header <- paste0("T_", day_grid, ",", collapse = "")
  traj_raw <- t(sampled_traj) # rows are posterior draws, cols are days
  traj_df <- as.data.frame(traj_raw)
  names(traj_df) <- paste0("T_", day_grid)
  write.table(
    cbind(traj_df, .trailing = ""),
    file = file.path(raw_dir, "trajectories_chain0.csv"),
    sep = ",",
    row.names = FALSE,
    col.names = c(names(traj_df), ""),
    quote = FALSE
  )

  cuminf_raw <- t(apply(traj_raw, 1, cumsum))
  cuminf_df <- as.data.frame(cuminf_raw)
  names(cuminf_df) <- paste0("T_", day_grid)
  write.table(
    cbind(cuminf_df, .trailing = ""),
    file = file.path(raw_dir, "cuminfections_chain0.txt"),
    sep = ",",
    row.names = FALSE,
    col.names = c(names(cuminf_df), ""),
    quote = FALSE
  )

  beta_df <- as.data.frame(t(sampled_beta))
  names(beta_df) <- paste0("T_", day_grid)
  write.table(
    cbind(beta_df, .trailing = ""),
    file = file.path(raw_dir, "betas_chain0.txt"),
    sep = ",",
    row.names = FALSE,
    col.names = c(names(beta_df), ""),
    quote = FALSE
  )

  week_grid <- seq_len(nrow(sampled_pt)) - 1L
  pt_df <- as.data.frame(t(sampled_pt))
  names(pt_df) <- paste0("T_", week_grid)
  write.table(
    cbind(pt_df, .trailing = ""),
    file = file.path(raw_dir, "positivetests_chain0.csv"),
    sep = ",",
    row.names = FALSE,
    col.names = c(names(pt_df), ""),
    quote = FALSE
  )

  params_df <- data.frame(
    gamma = samples[, "gamma"],
    psi = 0.001,
    phi = samples[, "phi"],
    betaJitter = samples[, "beta_jitter"],
    initialBeta = samples[, "initial_beta"]
  )
  write.table(
    cbind(params_df, .trailing = ""),
    file = file.path(raw_dir, "params_chain0.csv"),
    sep = ",",
    row.names = FALSE,
    col.names = c(names(params_df), ""),
    quote = FALSE
  )

  writeLines(as.character(chain$loglik_trace), file.path(raw_dir, "likelihoods_chain0.txt"))
  writeLines(as.character(as.numeric(chain$accepted)), file.path(raw_dir, "acceptance_chain0.txt"))
  writeLines(as.character(cumsum(as.numeric(chain$accepted)) / seq_along(chain$accepted)),
             file.path(raw_dir, "completed_chain0.txt"))
  writeLines(as.character(as.numeric(elapsed[["elapsed"]])), file.path(raw_dir, "timings.txt"))

  # Compute metrics from raw trajectories file content (chain0 format).
  traj_loaded <- utils::read.csv(file.path(raw_dir, "trajectories_chain0.csv"), check.names = FALSE)
  traj_loaded <- traj_loaded[, grepl("^T_", names(traj_loaded)), drop = FALSE]
  traj_loaded <- as.matrix(traj_loaded)
  inferred_from_raw <- t(traj_loaded) # days x draws
  metrics <- evaluate_infection_trajectory_metrics(inferred_from_raw, truth_daily)
  gamma_draws <- as.numeric(samples[thin_idx, "gamma"])
  inferred_rt <- infer_rt_from_beta_gamma_draws(sampled_beta, gamma_draws)
  truth_rt <- truth_df$Rt[idx]
  metrics_rt <- evaluate_infection_trajectory_metrics(inferred_rt, truth_rt)

  # Save plots
  plot_mcmc_trace_panel(
    samples = samples,
    loglik = chain$loglik_trace,
    accepted = chain$accepted,
    truth_gamma = 0.143,
    truth_phi = 0.02,
    output_path = file.path(plot_dir, "trace_params_likelihood.png")
  )

  png(file.path(plot_dir, "pfdiagnostics_daily_states_vs_truth.png"), width = 1500, height = 900)
  matplot(day_grid, pf$states_by_day, type = "l", lty = 1,
          col = grDevices::rgb(30/255, 136/255, 229/255, alpha = 25, maxColorValue = 255),
          xlab = "Day", ylab = "I(t)", main = "Daily particle states vs truth")
  lines(day_grid, truth_daily, lwd = 3, col = "firebrick")
  dev.off()

  weeks <- seq_len(nrow(pf$window_tests_by_particle))
  png(file.path(plot_dir, "pfdiagnostics_observed_vs_modelled_all_particles.png"), width = 1400, height = 900)
  matplot(weeks, pf$window_tests_by_particle, type = "l", lty = 1,
          col = grDevices::rgb(30/255, 136/255, 229/255, alpha = 35, maxColorValue = 255),
          xlab = "Week index", ylab = "Weekly positive tests",
          main = "Observed vs modelled positives (all particles)")
  lines(weeks, weekly_inc, type = "o", pch = 16, lwd = 2.5, col = "firebrick")
  dev.off()

  # Save tabular outputs
  summary_df <- data.frame(
    elapsed_user_sec = as.numeric(elapsed[["user.self"]]),
    elapsed_system_sec = as.numeric(elapsed[["sys.self"]]),
    elapsed_wall_sec = as.numeric(elapsed[["elapsed"]]),
    n_steps = as.integer(n_steps),
    warmup_steps = as.integer(warmup_steps),
    n_posterior_pf_draws = as.integer(n_draws),
    num_particles = as.integer(num_particles),
    acceptance_rate = as.numeric(chain$acceptance_rate),
    post_mean_initial_beta = post_mean["initial_beta"],
    post_mean_beta_jitter = post_mean["beta_jitter"],
    post_mean_gamma = post_mean["gamma"],
    post_mean_phi = post_mean["phi"]
  )
  write.csv(summary_df, file.path(run_dir, "timing_summary.csv"), row.names = FALSE)
  write.csv(as.data.frame(fit$warmup_history), file.path(run_dir, "warmup_history.csv"), row.names = FALSE)
  metrics_combined <- data.frame(
    target = c("infections", "infections", "infections", "infections",
               "Rt", "Rt", "Rt", "Rt"),
    metric = c("rmse", "coverage", "hpd_width", "crps",
               "rmse", "coverage", "hpd_width", "crps"),
    value = c(metrics$rmse, metrics$coverage, metrics$hpd_width, metrics$crps,
              metrics_rt$rmse, metrics_rt$coverage, metrics_rt$hpd_width, metrics_rt$crps),
    stringsAsFactors = FALSE
  )

  benchmark_file <- file.path(root_dir, "data", "truth", "java_epi_only_benchmark_metrics.csv")
  metrics_combined$benchmark_value <- NA_real_
  metrics_combined$benchmark_source <- NA_character_
  if (file.exists(benchmark_file)) {
    bench <- utils::read.csv(benchmark_file, check.names = FALSE, stringsAsFactors = FALSE)
    bench_map <- c(
      "infections|rmse" = "infection_rmse",
      "infections|coverage" = "infection_calibrated_coverage",
      "infections|crps" = "infection_crps",
      "Rt|rmse" = "rt_rmse",
      "Rt|coverage" = "rt_calibrated_coverage",
      "Rt|crps" = "rt_crps"
    )
    row_keys <- paste(metrics_combined$target, metrics_combined$metric, sep = "|")
    bench_keys <- unname(bench_map[row_keys])
    for (i in seq_along(bench_keys)) {
      key <- bench_keys[i]
      if (!is.na(key)) {
        j <- match(key, bench$metric_key)
        if (!is.na(j)) {
          metrics_combined$benchmark_value[i] <- as.numeric(bench$value[j])
          metrics_combined$benchmark_source[i] <- as.character(bench$source[j])
        }
      }
    }
  }
  metrics_combined$delta_vs_benchmark <- metrics_combined$value - metrics_combined$benchmark_value
  write.csv(metrics_combined, file.path(run_dir, "metrics_combined.csv"), row.names = FALSE)

  lo <- apply(sampled_traj, 1, quantile, probs = 0.025, na.rm = TRUE)
  hi <- apply(sampled_traj, 1, quantile, probs = 0.975, na.rm = TRUE)
  write.csv(data.frame(
    day = day_grid,
    truth = truth_daily,
    posterior_mean = rowMeans(sampled_traj),
    q025 = lo,
    q975 = hi
  ), file.path(run_dir, "daily_truth_vs_posterior_summary.csv"), row.names = FALSE)
  rt_q025 <- apply(inferred_rt, 1, quantile, probs = 0.025, na.rm = TRUE)
  rt_q975 <- apply(inferred_rt, 1, quantile, probs = 0.975, na.rm = TRUE)
  write.csv(data.frame(
    day = day_grid,
    truth_rt = truth_rt,
    posterior_mean_rt = rowMeans(inferred_rt),
    q025_rt = rt_q025,
    q975_rt = rt_q975
  ), file.path(run_dir, "daily_rt_truth_vs_posterior_summary.csv"), row.names = FALSE)

  # Manuscript-style trajectory summaries with uncertainty ribbons.
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package `ggplot2` is required to write trajectory summary plots.", call. = FALSE)
  }
  inf_summary <- data.frame(
    day = day_grid,
    posterior_mean = rowMeans(sampled_traj),
    q025 = lo,
    q975 = hi,
    truth = truth_daily
  )
  inf_y <- range(c(inf_summary$q025, inf_summary$q975, inf_summary$truth), finite = TRUE)
  p_inf <- ggplot2::ggplot(inf_summary, ggplot2::aes(x = day)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = q025, ymax = q975),
                         fill = "#2aac6d", alpha = 0.2, na.rm = TRUE) +
    ggplot2::geom_line(ggplot2::aes(y = posterior_mean, color = "Posterior mean"), linewidth = 1.1, na.rm = TRUE) +
    ggplot2::geom_line(ggplot2::aes(y = truth, color = "Truth"), linewidth = 1.2, na.rm = TRUE) +
    ggplot2::scale_color_manual(values = c("Posterior mean" = "#2aac6d", "Truth" = "firebrick")) +
    ggplot2::coord_cartesian(ylim = inf_y) +
    ggplot2::labs(
      x = "Day", y = "Infections",
      title = "Infection trajectory posterior summary",
      color = NULL
    ) +
    ggplot2::theme_minimal()
  ggplot2::ggsave(
    filename = file.path(plot_dir, "trajectory_infection_summary.png"),
    plot = p_inf, width = 14, height = 8.5, dpi = 120
  )

  rt_summary <- data.frame(
    day = day_grid,
    posterior_mean = rowMeans(inferred_rt),
    q025 = rt_q025,
    q975 = rt_q975,
    truth = truth_rt
  )
  rt_y <- range(c(rt_summary$q025, rt_summary$q975, rt_summary$truth, 1), finite = TRUE)
  p_rt <- ggplot2::ggplot(rt_summary, ggplot2::aes(x = day)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = q025, ymax = q975),
                         fill = "#00abce", alpha = 0.2, na.rm = TRUE) +
    ggplot2::geom_line(ggplot2::aes(y = posterior_mean, color = "Posterior mean"), linewidth = 1.1, na.rm = TRUE) +
    ggplot2::geom_line(ggplot2::aes(y = truth, color = "Truth"), linewidth = 1.2, na.rm = TRUE) +
    ggplot2::geom_hline(yintercept = 1, linetype = 2, color = "grey40", linewidth = 0.7) +
    ggplot2::scale_color_manual(values = c("Posterior mean" = "#00abce", "Truth" = "firebrick")) +
    ggplot2::coord_cartesian(ylim = rt_y) +
    ggplot2::labs(
      x = "Day", y = "Rt",
      title = "Rt trajectory posterior summary",
      color = NULL
    ) +
    ggplot2::theme_minimal()
  ggplot2::ggsave(
    filename = file.path(plot_dir, "trajectory_rt_summary.png"),
    plot = p_rt, width = 14, height = 8.5, dpi = 120
  )

  writeLines(c(
    paste0("label: ", label),
    paste0("timestamp: ", ts),
    paste0("run_dir: ", run_dir),
    paste0("raw_output_dir: ", raw_dir),
    paste0("plot_dir: ", plot_dir),
    paste0("truth_path: ", truth_path),
    paste0("incidence_path: ", incidence_path),
    paste0("seed: ", seed)
  ), file.path(run_dir, "run_config.txt"))

  output_manifest <- data.frame(
    file = c(
      "raw_output/trajectories_chain0.csv",
      "raw_output/cuminfections_chain0.txt",
      "raw_output/betas_chain0.txt",
      "raw_output/positivetests_chain0.csv",
      "raw_output/params_chain0.csv",
      "raw_output/likelihoods_chain0.txt",
      "raw_output/acceptance_chain0.txt",
      "raw_output/completed_chain0.txt",
      "raw_output/timings.txt",
      "timing_summary.csv",
      "warmup_history.csv",
      "metrics_combined.csv",
      "daily_truth_vs_posterior_summary.csv",
      "daily_rt_truth_vs_posterior_summary.csv",
      "plots/trace_params_likelihood.png",
      "plots/pfdiagnostics_daily_states_vs_truth.png",
      "plots/pfdiagnostics_observed_vs_modelled_all_particles.png",
      "plots/trajectory_infection_summary.png",
      "plots/trajectory_rt_summary.png",
      "run_config.txt"
    ),
    class = c(
      rep("raw_primary", 9),
      "diagnostic",
      "diagnostic",
      "diagnostic",
      "diagnostic",
      "diagnostic",
      rep("plot", 5),
      "diagnostic"
    ),
    description = c(
      "Sampled infection trajectories (Java-compatible)",
      "Cumulative infections derived from trajectories (Java-compatible)",
      "Sampled beta trajectories (Java-compatible)",
      "Sampled modelled weekly positives (Java-compatible)",
      "MCMC parameter draws (Java-compatible)",
      "MCMC log-likelihood trace (Java-compatible)",
      "MCMC accept/reject indicator trace (Java-compatible)",
      "Cumulative acceptance trace (Java-compatible)",
      "Runtime scalar in seconds (Java-compatible)",
      "Convenience timing and posterior mean snapshot",
      "Adaptive warmup proposal-scale history",
      "Infection and Rt metrics in one table",
      "Daily infection truth vs posterior summary",
      "Daily Rt truth vs posterior summary",
      "Trace panel for parameters and likelihood",
      "All-particle daily states vs truth",
      "All-particle modelled weekly positives vs observed",
      "Infection trajectory posterior ribbon plot",
      "Rt trajectory posterior ribbon plot",
      "Run metadata and file paths"
    ),
    stringsAsFactors = FALSE
  )
  write.csv(output_manifest, file.path(run_dir, "output_manifest.csv"), row.names = FALSE)

  list(run_dir = run_dir, raw_output_dir = raw_dir, plot_dir = plot_dir, summary = summary_df, metrics = metrics, metrics_rt = metrics_rt)
}

