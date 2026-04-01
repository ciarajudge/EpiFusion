---
output:
  pdf_document: default
  html_document: default
---
## EpiFusion R/Rcpp Migration Roadmap

### Executive summary

You currently have:

- **Core engine in Java** (`Main`, `ParticleFilter`, `MCMC`, `EpiLikelihood`, `ProcessModel`, `rtCalculator`, `Storage`, `XMLParser`, etc.), driven by XML config and writing flat-file outputs.
- **R wrapper package `EpiFusionUtilities`** that:
  - **Prepares data**, **generates XML**, **runs the Java JAR**, and **parses outputs**.
  - Provides **plotting**, **summaries**, and **data wrangling** around EpiFusion runs.

A good migration strategy is: **(1)** stabilise the current behaviour; **(2)** design a clean R/Rcpp core with explicit APIs; **(3)** incrementally port performance‑critical Java components to C++ via Rcpp; **(4)** replace the Java backend under `EpiFusionUtilities` with the new R/Rcpp core and then fold the wrapper into a unified R package.

---

## 1. Current architecture (inferred)

### 1.1 Java core (`EpiFusion`)

- **Entry point**: `Main`
  - Reads command-line XML path, calls `XMLParser.parseXMLInput()`.
  - Uses `Storage` to hold global configuration (chains, steps, file locations, generation time distribution, etc.).
  - Creates `ParticleFilter` and `MCMC` objects per chain and runs `MCMC.runMCMC()`.
  - Logs timings and copies input XML to output folder.
- **State & configuration**:
  - `Storage` appears to be a **global static data store** for:
    - Model settings (chains, particles, steps).
    - Paths and filenames for loggers.
    - Epidemiological parameters (generation time distribution, etc.).
- **Core inference components**:
  - `ProcessModel`, `EpiLikelihood`, `PhyloLikelihood`, `Incidence`, `Trajectory`, `Particle`, `Particles`, `ParticleFilter`, `MCMC`, `Prior`, `Priors`, `Dist` and its subclasses (`NormalDist`, `BetaDist`, `PoissonDist`, `UniformDist`, `UniformDiscreteDist`, `TruncatedNormalDist`), `rtCalculator`, `Trees`, `Tree`, `TreeSegment`, `Node`.
  - Logging infrastructure: `Loggers`, `ParticleLoggers`, `MasterLoggers`, `Storage` + file IO.
- **I/O & config**:
  - `XMLParser` for reading XML configuration (and likely tree data).
  - Writes results as text files to a folder structure consumed by R.

### 1.2 R wrapper (`EpiFusionUtilities`)

From its `DESCRIPTION` and filenames in `R/`:

- **Data preparation**:
  - `load_raw_epifusion.R`, `calculate_daily_infections.R`, `prepare_epifusion_tree.R`, `sampling_dataset.R`, `baseline_dataset.R`, `trajectory_table.R`, various `load_*` helpers.
- **Config and execution**:
  - `generate_epifusion_XML.R`, `generate_XML_chunk.R` build XML config files.
  - `run_epifusion.R` likely calls `system("java -jar EpiFusion.jar ...")`.
- **Output parsing**:
  - `extract_posterior_epifusion.R`, `load_parameter_samples.R`, `load_likelihoods.R`, `load_infection_trajectories.R`, `load_rt_trajectories.R`, `load_fitted_epi_cases.R`, `load_beta_trajectories.R`, `load_cumulativeinfection_trajectories.R`, `load_acceptance.R`.
- **Plotting & reporting**:
  - `plot_chainwise_trajectories.R`, `plot_parameter_trace.R`, `plot_likelihood_trace.R`, `plot_trajectories.R`, `lshtm_theme.R`, plus extensive tidyverse/ggplot2 usage.

So conceptually you already have a **clean separation**:

- **Engine**: Java-based, XML‑driven sampler.
- **Interface**: R package that turns input data into XML, runs engine, parses outputs, and visualises.

---

## 2. Migration goals (target architecture)

- **Single R package** (e.g. `EpiFusion`), with:
  - **Rcpp/C++ core** for performance‑critical algorithms (particle filter, MCMC, likelihoods, core math).
  - **R-level orchestration** for data prep, configuration, I/O, and plotting.
  - **No external Java runtime** requirement (optional legacy mode if desired).
- **Clean, testable design**:
  - Minimise global mutable state (`Storage`‑like patterns).
  - Clear APIs for:
    - Model configuration (R objects, not XML).
    - Running inference.
    - Accessing results as in‑memory R objects.
- **High efficiency**:
  - Heavy loops and numerical routines moved to C++ via Rcpp (possibly RcppArmadillo or Eigen).
  - Avoid unnecessary copying between R and C++.
  - Use existing high‑quality R libraries for phylogenetics and statistics where possible instead of re‑implementing everything.
- **Backward compatibility and a smooth user transition**:
  - Keep function names and semantics from `EpiFusionUtilities` where practical.
  - Provide deprecation shims and clear migration guides.

---

## 3. High-level migration strategy

- **Phase 0: Stabilise and document current behaviour**  
  Ensure you have a **solid reference** of what “correct” output looks like for a set of scenarios, using the current Java + `EpiFusionUtilities` stack.
- **Phase 1: Design R/Rcpp architecture & interfaces**  
  Agree on how users will specify models, run them, and consume outputs in pure R.
- **Phase 2: Port core algorithms to Rcpp**  
  Start with foundations (distributions, log-likelihoods, core particle filter logic), then move MCMC and Rt calculation.
- **Phase 3: Replace Java backend in R package**  
  Make `run_epifusion()` and related functions call Rcpp code rather than `system("java ...")`, preserving arguments and outputs.
- **Phase 4: Fold utilities and harmonise APIs**  
  Merge `EpiFusionUtilities` functionality into the new package; deprecate the old wrapper.
- **Phase 5: Optimise, simplify, and document**  
  Tighten performance, clarify code structure, add vignettes and pkgdown site.

---

## 4. Phase 0 – Stabilise current system and tests

- **Define canonical test cases**:
  - **Small synthetic examples**: simple incidence curves and tiny trees where you can reason about plausible posteriors.
  - **Realistic examples**: a few of your commonly used datasets that exercise phylogenetic likelihood, multiple chains, etc.
- **Snapshot outputs**:
  - Using current pipeline, run each scenario and **archive**:
    - XML input.
    - All text log files (parameters, likelihoods, trajectories, Rt, trees).
    - Derived objects produced by `EpiFusionUtilities` (e.g. tibbles, summary stats).
- **Create R tests against Java engine**:
  - In a new `tests/` context for the R package, write tests that:
    - Call `run_epifusion()` with known inputs.
    - Assert structural properties (dimensions, column names).
    - Snapshot or tolerance-check key numerical outputs (e.g. effective \(R_t\), log-likelihood traces, posterior means/medians).

This gives you **ground truth** for validation of the R/Rcpp implementation.

---

## 5. Phase 1 – Design of the R/Rcpp package

### 5.1 Package structure

Core package layout in the `EpiFusion` repo:

- `R/`:
  - **User-facing functions**:
    - `epifusion_model()` – construct a model object from data and priors.
    - `run_epifusion()` – run inference and return a fitted object.
    - `summary.epifusion_fit()`, `plot.epifusion_fit()`, `as.data.frame()` methods.
  - **Data prep utilities** (largely imported from `EpiFusionUtilities`):
    - e.g. `prepare_epifusion_tree()`, `calculate_daily_infections()`, etc.
  - **Configuration helpers**:
    - e.g. `epifusion_config()` as an R list (replacing low-level reliance on XML).
- `src/`:
  - C++ implementations of:
    - Particle representation and filter.
    - MCMC kernel.
    - Likelihood components (epidemiological and phylogenetic).
    - Rt calculation and distribution helpers.
  - Rcpp exports (via `// [[Rcpp::export]]`).
- `inst/`:
  - Example data.
  - Optional legacy XML templates (if you want to still export XML).
- `vignettes/`:
  - “Getting started with EpiFusion”.
  - “From Java + EpiFusionUtilities to R/Rcpp EpiFusion”.

### 5.2 Data model and API

- **Configuration object**:
  - Replace `Storage` with a plain R object (list or S3 class) that encapsulates:
    - Data (incidence, trees, covariates).
    - Priors, kernel settings, particle numbers.
    - MCMC settings (chains, steps, thinning).
  - Example:

    ```r
    config <- epifusion_config(
      incidence = daily_cases,
      tree = phylo_tree,
      priors = list(R0 = ..., gen_time = ...),
      mcmc = list(chains = 4, iterations = 20000, burnin = 5000, thin = 10)
    )
    ```

- **Fit object**:
  - Result of `run_epifusion()` should be an S3 object, e.g. class `"epifusion_fit"`, containing:
    - Draws / traces for parameters, likelihoods.
    - Infection and Rt trajectories.
    - Diagnostics (acceptance rates, ESS).
    - Metadata (config, version, seed).

This design is critical for **clean code and testability**.

---

## 6. Phase 2 – Porting core algorithms to Rcpp

### 6.1 Foundations: distributions and helpers

- **What to port**:
  - `Dist` and subclasses (`NormalDist`, `BetaDist`, `PoissonDist`, `UniformDist`, `UniformDiscreteDist`, `TruncatedNormalDist`).
  - Utility functions like those in `rtCalculator` (array operations, sums, products).
- **Implementation approach**:
  - Use R’s own `Rmath` via Rcpp (or `R::rnorm`, `R::dnorm`, etc.) where possible.
  - Wrap in **C++ classes or plain functions** with interfaces like:

    ```cpp
    // [[Rcpp::export]]
    double epifusion_dnorm(double x, double mean, double sd, bool log = false);
    ```

  - Keep the **numerical behaviour consistent** with Java implementation where necessary (e.g. truncation, parameterisation).

### 6.2 Particle representation and filter

- **Java role**:
  - Classes like `Particle`, `Particles`, `ParticleFilter`, `Incidence`, `Trajectory` manage:
    - Latent state trajectories.
    - Weights, resampling.
    - Transition dynamics.
- **R/Rcpp design**:
  - Implement a **C++ struct/class** for particle state, but expose it via simple Rcpp types:
    - Use `Rcpp::List` of `NumericVector`/`IntegerVector` to represent ensembles.
    - Alternatively, keep everything in C++ and expose only aggregate results to R.
  - Use RcppArmadillo or Eigen for efficient vector/matrix operations if needed.
- **Algorithm implementation**:
  - Port the exact logic from Java, using the existing code as a direct guide for:
    - Transition step.
    - Weight computation.
    - Resampling (systematic/stratified/multinomial).
  - Provide C++ functions like:

    ```cpp
    // [[Rcpp::export]]
    Rcpp::List epifusion_particle_filter(Rcpp::List config, int chain_id, int seed);
    ```

### 6.3 MCMC kernel

- **Java role**:
  - `MCMC` controls proposal mechanisms, acceptance, logging, multi-chain coordination.
- **R/Rcpp design**:
  - Implement the heavy loop in C++:
    - Parameter proposals (random walks, adaptive step sizes if present).
    - Calling particle filter / likelihood.
    - Metropolis–Hastings accept/reject.
  - Expose a single Rcpp function such as:

    ```cpp
    // [[Rcpp::export]]
    Rcpp::List epifusion_mcmc(
      Rcpp::List config,
      int chain_id,
      int iterations,
      int burnin,
      int thin,
      int seed
    );
    ```

  - Let R orchestrate multiple chains, combination, and post‑processing.

### 6.4 Rt calculation

- **Current implementation**:
  - `rtCalculator.calculateRt(Particle particle)` uses generation time distribution and infection counts.
- **R/Rcpp port**:
  - Implement an equivalent C++ function that takes:
    - A vector of infections.
    - A generation time distribution.
  - Ensure equivalence by directly comparing output of Java and C++ versions on test cases.

Example Rcpp signature:

```cpp
// [[Rcpp::export]]
Rcpp::NumericVector epifusion_compute_rt(
  Rcpp::IntegerVector infections,
  Rcpp::NumericVector gen_time
);
```

---

## 7. Phase 3 – Phylogenetic likelihood and tree handling

- **Current situation**:
  - Java classes (`Trees`, `Tree`, `TreeSegment`, `Node`, `PhyloLikelihood`) implement tree handling and likely a coalescent or birth–death model.
  - These may rely on Java libraries or be fully custom.
- **Options in R/Rcpp**:

  - **Option A – Wrap existing R tree libraries**:
    - Use `ape`, `castor`, etc., to compute likelihoods and tree summary statistics, embedding them in the particle filter.
    - Pros: leans on well‑tested, standard libraries; easier to maintain.
    - Cons: might not exactly match current Java likelihood implementation.
  - **Option B – Port Java tree logic to C++**:
    - Implement custom tree classes and likelihood in C++.
    - Pros: more faithful to current model.
    - Cons: more work, more maintenance.

- **Recommended approach**:
  - Start with **Option B** to obtain **behavioural parity**, guided by unit tests against Java outputs.
  - Where possible, use `ape`/`castor` for low-level operations (tree parsing, branch length handling) and wrap them in R to simplify C++ code.

---

## 8. Phase 4 – Replace Java backend in the R workflow

### 8.1 Layered interface

- **Current R API** (`EpiFusionUtilities`):
  - Key function is likely `run_epifusion()`, which:
    - Prepares XML.
    - Calls `system("java -jar EpiFusion.jar")`.
    - Parses output logs.
- **New R API**:
  - Maintain the same **user-facing function signature** as much as possible:
    - Same arguments (or superset with deprecations).
    - Same return structure (list/tibble columns).
  - Internally:
    - Instead of writing XML and invoking Java, construct an `epifusion_config` object and call the Rcpp engine:

      ```r
      run_epifusion <- function(data, tree, ..., use_legacy = FALSE) {
        if (use_legacy) {
          # Old path: XML + Java
        } else {
          config <- epifusion_config(data = data, tree = tree, ...)
          fit <- epifusion_mcmc_core(config)  # R wrapper around Rcpp
          postprocess_epifusion_fit(fit)
        }
      }
      ```

  - This allows for a **transition period** where Java can still be used for verification, but the default is pure R/Rcpp.

### 8.2 Output structure

- **Goal**: ensure functions like `extract_posterior_epifusion()`, `load_rt_trajectories()`, `plot_*()` continue to work with minimal changes.
- **Strategy**:
  - Make the **Rcpp core return data in the same shape** (columns, names) that `EpiFusionUtilities` functions expect.
  - For a while, keep “loader” functions as thin wrappers that work off **in‑memory objects** rather than disk files, e.g.:

    ```r
    load_rt_trajectories <- function(fit_or_path) {
      if (inherits(fit_or_path, "epifusion_fit")) {
        return(fit_or_path$rt_trajectories)
      } else {
        # Legacy path: read from file system
      }
    }
    ```

---

## 9. Phase 5 – Folding `EpiFusionUtilities` into the new package

### 9.1 Categorise existing R functions

Split `EpiFusionUtilities` functions into categories:

- **Data loading / preparation**:
  - `load_raw_epifusion()`, `calculate_daily_infections()`, `prepare_epifusion_tree()`, `sampling_dataset()`, `baseline_dataset()`, `trajectory_table()`, `load_*` functions reading results.
- **Configuration / run control**:
  - `generate_epifusion_XML()`, `generate_XML_chunk()`, `run_epifusion()`.
- **Post-processing & plotting**:
  - `extract_posterior_epifusion()`, `plot_*` functions, `lshtm_theme()`.

### 9.2 Integration plan

- **Data prep**:
  - Move these functions essentially **as-is** into the new `EpiFusion` R package under similar names.
  - Ensure they don’t make unnecessary assumptions about files vs in‑memory objects.
- **Configuration / run control**:
  - Replace XML-specific internals with R config object construction.
  - Keep XML generation functions but:
    - Mark them as **legacy helpers** (e.g., for reproducing old runs or interoperability with other tools).
    - Maybe hide them from top-level user interface (`@keywords internal`).
- **Post-processing**:
  - Update these functions to operate on the new `epifusion_fit` object where possible.
  - Provide thin wrappers that can still consume legacy file-based output for backwards compatibility.
- **Package metadata**:
  - Decide whether to **rename** the final package (e.g. just `EpiFusion`) and:
    - Deprecate `EpiFusionUtilities` on CRAN/GitHub (if applicable), pointing users to the new combined package.
    - Or keep `EpiFusionUtilities` as a minimal shim package that `Depends` on the new core and re-exports key functions.

---

## 10. Code quality & cleanliness during migration

- **Eliminate global state**:
  - Avoid `Storage`-like singletons. Use explicit function arguments or **state objects** passed through.
- **Modularise**:
  - Separate:
    - Model specification (priors, generative structure).
    - Sampling algorithm (particle filter + MCMC).
    - Input/Output (data prep, results).
    - Visualisation.
- **Adopt R idioms**:
  - Function/argument naming consistent with tidyverse/Bioconductor where appropriate.
  - S3 classes for model and fit objects.
- **Documentation and examples**:
  - Roxygen2 docs for all user-facing functions.
  - Vignettes showing:
    - “Run EpiFusion from R (no Java)”.
    - “Migrating from EpiFusionUtilities + Java to new EpiFusion”.

---

## 11. Validation and performance

- **Validation against Java**:
  - For each canonical dataset from Phase 0:
    - Run Java + old R wrapper and new R/Rcpp engine.
    - Compare:
      - Posterior means, medians, credible intervals.
      - Rt trajectories.
      - Log-likelihood traces.
      - Acceptance rates.
    - Decide on acceptable numerical tolerances.
- **Performance tuning**:
  - Use `bench`, `microbenchmark`, and `Rprof`/`profvis` to identify bottlenecks.
  - Optimise:
    - Memory allocations in C++ (pre‑allocate, reuse buffers).
    - Avoiding unnecessary R ↔ C++ conversions in loops.
  - Consider:
    - **Parallel chains** via `future`, `parallel`, or Rcpp‑supported threading (if safe for your C++ design).
    - Making long-running simulations interruptible when called from R.

---

## 12. Suggested concrete next steps

- **Short term (1–2 weeks)**:
  - Finalise **target R API** (what does `run_epifusion()` look like in the new world).
  - Write **R tests** that exercise the full current pipeline on 2–3 example datasets and archive Java outputs.
  - Begin port of basic helpers to Rcpp (e.g. `rtCalculator` logic and distribution functions).
- **Medium term (1–3 months)**:
  - Implement C++ particle filter and MCMC core.
  - Integrate into R package and wire into a prototype `run_epifusion()` that bypasses Java for some simple scenarios.
  - Start porting or re-implementing phylogenetic likelihood.
- **Longer term (3–6+ months)**:
  - Complete retirement of Java for core use cases.
  - Fold `EpiFusionUtilities` fully into the new package with maintained interfaces and deprecations.
  - Build vignettes and a pkgdown site; consider releasing a tagged version as “EpiFusion 2.0”.

---

## 13. Proposed Rcpp core API

Below is a concrete proposal for the **Rcpp-level API**, i.e. the functions implemented in C++ and exposed to R via `// [[Rcpp::export]]`. These are the building blocks that R wrappers like `run_epifusion()` will call.

### 13.1 Configuration and model objects

At the R level you construct configuration objects; at the C++ level you receive them as `Rcpp::List` and convert into internal structs/classes.

Suggested Rconfig structure:

```r
config <- epifusion_config(
  data = list(
    incidence = incidence_vector,
    tree = phylo_tree,         # can be serialized (edge list, parent/child, etc.)
    covariates = covariate_df  # optional
  ),
  priors = list(
    R0 = list(mean = 2.5, sd = 0.5),
    gen_time = list(mean = 5.0, sd = 1.0),
    # other parameters...
  ),
  mcmc = list(
    chains = 4L,
    iterations = 20000L,
    burnin = 5000L,
    thin = 10L,
    seed = 1L
  ),
  particles = list(
    n_particles = 1000L,
    resample_threshold = 0.5
  ),
  model = list(
    use_phylo = TRUE,
    # model-specific switches and options
  )
)
```

Rcpp functions should accept this as an opaque `Rcpp::List` and immediately map to C++ types.

### 13.2 Distribution and helper functions

These are low-level but useful both for internal use and for advanced users.

```cpp
// [[Rcpp::export]]
double epifusion_dnorm(double x, double mean, double sd, bool log = false);

// [[Rcpp::export]]
double epifusion_dbeta(double x, double alpha, double beta, bool log = false);

// [[Rcpp::export]]
double epifusion_dpois(double x, double lambda, bool log = false);

// [[Rcpp::export]]
double epifusion_dunif(double x, double min, double max, bool log = false);

// [[Rcpp::export]]
double epifusion_dunif_discrete(int x, int min, int max, bool log = false);

// [[Rcpp::export]]
double epifusion_dtruncnorm(
  double x,
  double mean,
  double sd,
  double a,
  double b,
  bool log = false
);
```

Vectorised wrappers can be added later as needed.

### 13.3 Rt calculation

Direct port of `rtCalculator` with a clean R interface:

```cpp
// [[Rcpp::export]]
Rcpp::NumericVector epifusion_compute_rt(
  Rcpp::IntegerVector infections,
  Rcpp::NumericVector gen_time
);
```

This returns a numeric vector \(R_t\) of the same length as `infections`.

### 13.4 Particle filter core

The particle filter operates for a **single chain** with a given configuration and seed. R will call this either directly for debugging or indirectly from the MCMC kernel.

```cpp
// [[Rcpp::export]]
Rcpp::List epifusion_particle_filter(
  Rcpp::List config,
  int chain_id,
  int seed
);
```

Suggested contents of the returned list:

- `loglik`: total log-likelihood for the data given current parameters.
- `weights`: final normalised particle weights.
- `trajectories`: latent state trajectories (e.g. infections by time, possibly as a 3D structure represented via list-of-matrices).
- `diagnostics`: any filter-level diagnostics (effective sample size by time step, number of resampling events, etc.).

The exact internal representation can evolve, as long as the **R wrapper** exposes a stable interface.

### 13.5 MCMC kernel

The MCMC kernel encapsulates:

- Parameter proposals.
- Calls to `epifusion_particle_filter()` for each proposal.
- Metropolis–Hastings accept/reject logic.

Core signature:

```cpp
// [[Rcpp::export]]
Rcpp::List epifusion_mcmc(
  Rcpp::List config,
  int chain_id,
  int iterations,
  int burnin,
  int thin,
  int seed
);
```

Suggested contents of the returned list (for a **single chain**):

- `samples`: matrix/data frame of parameter samples (rows = iterations post-burnin, cols = parameters).
- `loglik`: vector of log-likelihood values per kept iteration.
- `acceptance`: overall acceptance rate and possibly parameter-wise acceptance.
- `trajectories`: selected latent trajectories (e.g. sample every `thin` steps or for a subset of particles as needed).
- `diagnostics`: misc. diagnostic measures (ESS, adaptation info, proposal scales, etc.).

### 13.6 Multi-chain orchestration

Running multiple chains can be done in R (looping over `chain_id` and `seed`) or in C++. To keep the surface simple and flexible, I suggest:

- **Primary Rcpp API** remains **single-chain** (`epifusion_mcmc()`).
- Provide an optional **multi-chain helper**:

```cpp
// [[Rcpp::export]]
Rcpp::List epifusion_mcmc_multichain(
  Rcpp::List config,
  int chains,
  int iterations,
  int burnin,
  int thin,
  int seed
);
```

This returns a list of chain objects (each like the single-chain return). Internally, you can:

- Run chains sequentially for simplicity.
- Or use C++ threading (with care for RNG and R’s thread-safety constraints) later.

On the R side, `run_epifusion()` can either:

- Call `epifusion_mcmc_multichain()` directly.
- Or parallelise over chains using R’s `future`/`parallel` while keeping C++ single-threaded.

### 13.7 Phylogenetic likelihood

The exact interface depends on how you choose to represent trees. A reasonable starting point:

```cpp
// [[Rcpp::export]]
double epifusion_phylo_loglik(
  Rcpp::List tree,     // serialized tree (edge list, branch lengths, etc.)
  Rcpp::List params    // parameters relevant to the phylo model
);
```

Where:

- `tree` could contain:
  - `edges`: integer matrix with parent/child indices.
  - `branch_length`: numeric vector.
  - Any additional attributes required by your model.
- `params` contains:
  - Birth–death rates or coalescent parameters.
  - Any scaling factors or hyperparameters.

Within the particle filter and MCMC, this function is called as part of the overall likelihood computation.

### 13.8 Top-level engine call (optional)

You may want a single Rcpp function that does **everything** (configure, run MCMC, post-process) for performance or simplicity. For example:

```cpp
// [[Rcpp::export]]
Rcpp::List epifusion_run_engine(Rcpp::List config);
```

This would:

- Internally orchestrate multiple chains.
- Return a rich object that closely matches what `run_epifusion()` will return at the R level.

However, keeping the lower-level pieces (distributions, particle filter, MCMC kernel) exported separately is very helpful for:

- Debugging and testing.
- Research extensions.
- Educational use.

---

## 14. How this ties into the R-level API

With the Rcpp core in place, R-level functions look roughly like:

```r
run_epifusion <- function(
  incidence,
  tree = NULL,
  priors = list(),
  mcmc = list(iterations = 20000L, burnin = 5000L, thin = 10L, chains = 4L),
  particles = list(n_particles = 1000L),
  model = list(use_phylo = !is.null(tree)),
  seed = 1L,
  use_legacy = FALSE
) {
  config <- epifusion_config(
    data = list(incidence = incidence, tree = tree),
    priors = priors,
    mcmc = modifyList(list(chains = mcmc$chains, iterations = mcmc$iterations,
                           burnin = mcmc$burnin, thin = mcmc$thin, seed = seed), list()),
    particles = particles,
    model = model
  )

  if (use_legacy) {
    # existing path: XML + Java + file-based parsing
  } else {
    fit_raw <- epifusion_mcmc_multichain(
      config,
      chains = mcmc$chains,
      iterations = mcmc$iterations,
      burnin = mcmc$burnin,
      thin = mcmc$thin,
      seed = seed
    )
    fit <- postprocess_epifusion_fit(fit_raw, config)
    class(fit) <- "epifusion_fit"
    fit
  }
}
```

Existing `EpiFusionUtilities` functions (`extract_posterior_epifusion()`, `plot_*()`, `load_*()`) can then be progressively refactored to operate on `"epifusion_fit"` objects, making the whole workflow Java-free for typical users while still allowing legacy operation where required.

