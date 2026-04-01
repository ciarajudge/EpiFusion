test_that("compute_rt returns expected length", {
  rt <- compute_rt(c(1L, 2L, 3L, 4L), c(0.2, 0.3, 0.5))
  expect_length(rt, 4)
})

test_that("compute_rt handles short series with normalized partial windows", {
  infections <- c(2L, 4L)
  gen_time <- c(0.2, 0.3, 0.5)
  rt <- compute_rt(infections, gen_time)

  expect_equal(rt[1], 1.0)
  expect_equal(rt[2], 4 / ((2 * (0.3 / 0.5)) + (4 * (0.2 / 0.5))))
})

test_that("compute_rt keeps Java-style full-window behavior after lag", {
  infections <- c(1L, 2L, 3L, 4L)
  gen_time <- c(0.2, 0.3, 0.5)
  rt <- compute_rt(infections, gen_time)

  # t = 3 (0-based) uses infections[2:4] * reverse(gen_time) without renormalizing.
  expected_t4 <- 4 / ((2 * 0.5) + (3 * 0.3) + (4 * 0.2))
  expect_equal(rt[4], expected_t4)
})

