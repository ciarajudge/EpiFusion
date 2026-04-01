# Data Fixtures

This folder stores local data fixtures used by migration runs and tests.

## Layout

- `data/truth/`
  - `baseline_truth.csv`: baseline simulation truth trajectory and parameters.
    Includes columns such as:
    - `I` (true infections over time),
    - `Gamma`,
    - `Rt`.
  - `java_epi_only_benchmark_metrics.csv`: historical Java epi-only benchmark
    metric targets used to compare migration outputs.
- `data/incidence/`
  - `baseline_weeklyincidence.txt`: observed weekly incidence used for baseline
    fitting runs.

These copies are kept in-repo so migration outputs are reproducible without
external file path dependencies.

