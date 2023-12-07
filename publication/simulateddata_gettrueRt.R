#Generationtimefunctions
simdubcensored_SEIR <- function(max, rate1, rate2) {
  primary <- runif(1e6)
  secondary <- primary + rexp(1e6, rate1) + rexp(1e6, rate2)
  delay <- floor(secondary) - floor(primary)
  cdf <- ecdf(delay)(1:max)
  pmf <- c(cdf[1], diff(cdf))
  return(pmf)
}

simdubcensored_SIR <- function(max, rate) {
  primary <- runif(1e6)
  secondary <- primary + rexp(1e6, rate)
  delay <- floor(secondary) - floor(primary)
  cdf <- ecdf(delay)(1:max)
  pmf <- c(cdf[1], diff(cdf))
  return(pmf)
}

#Renewal equation, used to calculate Rt from inf trajectories
renewal_eqn <- function(infections, gt_distribution) {
  n_days <- length(infections)
  R_t <- rep(NA, n_days)
  lag <- length(gt_distribution) -1
  for (t in 2:n_days) {
    if (t < lag) {
      #renormalise the gt
      gt <- rev(gt_distribution[1:t])
      renormgt <- gt/sum(gt)
      R_t[t] <- (sum(infections[t]))/(sum(infections[1:t] * renormgt))
    } else {
      R_t[t] <- (sum(infections[t]))/(sum(infections[(t-lag):t] * rev(gt_distribution)))
      
    }
  }
  R_t[1] <- R_t[2]
  return(R_t)
}

slidingwindow <- function(vector){
  newvector <- c(vector[1])
  for (i in 2:(length(vector))) {
    newvector[i] <- mean(c(vector[i], vector[i-1]))
  }
  newvector[length(vector)] <- vector[length(vector)]
  return(newvector)
}


table <- read.csv('simulateddata_data/SB4RC/SB4RC_table.csv', header = T)
filtered <- table |>
  select(t, I) |>
  mutate(difference = c(0, diff(I))) |>
  filter(difference == 1) |>
  mutate(t = floor(t)) |>
  select(t, difference) |>
  group_by(t) |>
  mutate(newInfs = n()) |>
  distinct()
all <- data.frame(t = seq(1, round(max(table$t)))) %>%
  left_join(filtered)
all[is.na(all)] <- 0

gt <- simdubcensored_SEIR(21, 1/5, 1/7) |>
  (\(x) x / sum(x))()

rtx <- slidingwindow(renewal_eqn(all$newInfs, gt)) #I'm just throwing a sliding window on it to smooth it out a bit
plot(rtx, log = 'y', xlim = c(0, 120), ylim = c(0.1, 8))
lines(c(0, 120), c(1,1), lty = 2)
write(rtx, 'simulateddata_data/SB4RC/SB4RC_realrt_renewal.txt', ncolumns = 1)



table <- read.csv('simulateddata_data/SS3OC/SS3OC_table.csv', header = T)
filtered <- table |>
  dplyr::select(t, I) |>
  mutate(difference = c(0, diff(I))) |>
  filter(difference == 1) |>
  mutate(t = floor(t)) |>
  dplyr::select(t, difference) |>
  group_by(t) |>
  mutate(newInfs = n()) |>
  distinct()
all <- data.frame(t = seq(1, round(max(table$t)))) %>%
  left_join(filtered)
all[is.na(all)] <- 0

gt <- simdubcensored_SIR(21, 1/7) |>
  (\(x) x / sum(x))()
plot(gt)

rtx <- slidingwindow(renewal_eqn(all$newInfs, gt)) #I'm just throwing a sliding window on it to smooth it out a bit
plot(rtx, log = 'y', xlim = c(0, 100), ylim = c(0.1, 8))
lines(c(0, 120), c(1,1), lty = 2)
write(rtx, 'simulateddata_data/SS3OC/SS3OC_realrt_renewal.txt', ncolumns = 1)


table <- read.csv('simulateddata_data/ST3RC/ST3RC_table.csv', header = T)
filtered <- table |>
  dplyr::select(t, I) |>
  mutate(difference = c(0, diff(I))) |>
  filter(difference == 1) |>
  mutate(t = floor(t)) |>
  dplyr::select(t, difference) |>
  group_by(t) |>
  mutate(newInfs = n()) |>
  distinct()
all <- data.frame(t = seq(1, round(max(table$t)))) %>%
  left_join(filtered)
all[is.na(all)] <- 0

gt <- simdubcensored_SIR(21, 1/7) |>
  (\(x) x / sum(x))()

rtx <- slidingwindow(renewal_eqn(all$newInfs, gt)) #I'm just throwing a sliding window on it to smooth it out a bit
plot(rtx, log = 'y', xlim = c(100, 200), ylim = c(0.1, 8))
lines(c(100, 200), c(1,1), lty = 2)
write(rtx, 'simulateddata_data/ST3RC/ST3RC_realrt_renewal.txt', ncolumns = 1)



