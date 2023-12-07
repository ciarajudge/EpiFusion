library(EpiNow2)
library(epinowcast)
library(tidybayes)
library(memoise)

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

simdubcensored_sampledelays_SEIR <- function(max, rate1, rate2, samplerate) {
  sampledelays <- rexp(1e7, rate1) + rexp(1e7, samplerate)
  recovdelays <- rexp(1e7, rate1) + rexp(1e7, rate2)
  propobserved <- sum(sampledelays < recovdelays) / 1e7
  secondary <- sampledelays[sampledelays < recovdelays]
  print(length(secondary))
  primary <- runif(length(secondary))
  secondary <- primary + secondary
  delay <- floor(secondary) - floor(primary)
  cdf <- ecdf(delay)(1:max)
  pmf <- c(cdf[1], diff(cdf))
  return(list(pmf, propobserved))
}

simdubcensored_sampledelays_SIR <- function(max, rate1, samplerate) {
  sampledelays <- rexp(1e7, samplerate)
  recovdelays <- rexp(1e7, rate1)
  propobserved <- sum(sampledelays < recovdelays) / 1e7
  secondary <- sampledelays[sampledelays < recovdelays]
  print(length(secondary))
  primary <- runif(length(secondary))
  secondary <- primary + secondary
  delay <- floor(secondary) - floor(primary)
  cdf <- ecdf(delay)(1:max)
  pmf <- c(cdf[1], diff(cdf))
  return(list(pmf, propobserved))
}

simdubcensored_sampledelays_samplingscenario <- function(max, rate1, samplerate1, samplerate2, propsplit) {
  sampledelays1 <- rexp(1e7*propsplit, samplerate1)
  sampledelays2 <- rexp(1e7*(1-propsplit), samplerate2)
  sampledelays <- c(sampledelays1, sampledelays2)
  recovdelays <- rexp(1e7, rate1)
  propobserved <- sum(sampledelays < recovdelays) / 1e7
  secondary <- sampledelays[sampledelays < recovdelays]
  print(length(secondary))
  primary <- runif(length(secondary))
  secondary <- primary + secondary
  delay <- floor(secondary) - floor(primary)
  cdf <- ecdf(delay)(1:max)
  pmf <- c(cdf[1], diff(cdf))
  return(list(pmf, propobserved))
}

#####Introduction Scenario#####
#Read in the weekly incidence data, give it dates and put it into a compatible data frame
incidence <- read.table("simulateddata_data/SB4RC/SB4RC_weeklyincidence.txt")
dates <- seq(as.Date(paste0(c("2021-01-07"), collapse = "")), 
             as.Date(paste0(c("2021-05-25"), collapse = "")), by="weeks")
reported_cases <- data.frame(date = dates, confirm = unlist(incidence[,1]))

#This is the generation time calculation from the code you sent me
gt <- simdubcensored_SEIR(21, 1/5, 1/7) |>
  (\(x) x / sum(x))()
plot(gt, col = "blue")

gen_time_epinow2 <- generation_time_opts(
  dist_spec(pmf = gt)
)

samplingstats <- simdubcensored_sampledelays_SEIR(21, 1/5, 1/7, 0.02)
prop_observed <- samplingstats[[2]]
obs_epinow2 <- obs_opts(scale = list(mean = propobserved, sd = 0.02))

samplingpmf <- samplingstats[[1]] |>
  (\(x) x/sum(x))()
plot(samplingpmf, col = 'red')
delays_epinow2 <- delay_opts(dist_spec(pmf = sample_pmf))
  
options(mc.cores = 8)
out <- epinow(reported_cases = reported_cases, 
              generation_time = gen_time_epinow2, #From above
              delays = delays_epinow2, 
              obs = obs_epinow2,
              rt = rt_opts(prior = list(mean = 1.5, sd = 1.0)), #I think this makes sense, Rt starts high and gets low, mean over the whole time is 1.5ish
              gp = gp_opts(basis_prop = 0.2), 
              stan = stan_opts(samples = 4000),
              horizon = 0, 
              target_folder = "results",
              logs = file.path("logs", Sys.Date()),
              return_output = TRUE, 
              verbose = TRUE)
 plot(out)
 saveRDS(out, "SB4RC_epinow_maybefinal.RDS")
 
 
 #####Transmission step-change scenario#####
 #Read in the weekly incidence data, give it dates and put it into a compatible data frame
 incidence <- read.table("simulateddata_data/ST3RC/ST3RC_weeklyincidence.txt")
 dates <- seq(as.Date(paste0(c("2021-01-07"), collapse = "")), 
              as.Date(paste0(c("2022-06-01"), collapse = "")), by="weeks")
 reported_cases <- data.frame(date = dates, confirm = unlist(incidence[,1]))
 
 gt <- simdubcensored_SIR(21, 1/7) |>
   (\(x) x / sum(x))()
 plot(gt, col = "blue")
 gen_time_epinow2 <- generation_time_opts(
   dist_spec(pmf = gt)
 )
 
 samplingstats <- simdubcensored_sampledelays_SIR(21, 1/7, 0.02)
 prop_observed <- samplingstats[[2]]
 obs_epinow2 <- obs_opts(scale = list(mean = propobserved, sd = 0.02))
 
 samplingpmf <- samplingstats[[1]] |>
   (\(x) x/sum(x))()
 plot(samplingpmf, col = 'red')
 delays_epinow2 <- delay_opts(dist_spec(pmf = sample_pmf))
 
 
 options(mc.cores = 8)
 out <- epinow(reported_cases = reported_cases, 
               generation_time = gen_time_epinow2, #From above
               delays = delays_epinow2,
               obs = obs_epinow2,
               rt = rt_opts(prior = list(mean = 1.1, sd = 2.0)), #Rt is 1 for a lot of this scenario
               gp = gp_opts(basis_prop = 0.2), 
               stan = stan_opts(samples = 4000),
               horizon = 0, 
               target_folder = "results",
               logs = file.path("logs", Sys.Date()),
               return_output = TRUE, 
               verbose = TRUE)
 plot(out)
 saveRDS(out, "ST3RC_epinow_maybefinal.RDS")

 
 #####Sampling stepchange scenario#####
 #Read in the weekly incidence data, give it dates and put it into a compatible data frame
 incidence <- read.table("simulateddata_data/SS3OC/SS3OC_weeklyincidence.txt")
 dates <- seq(as.Date(paste0(c("2021-01-07"), collapse = "")), 
              as.Date(paste0(c("2021-05-01"), collapse = "")), by="weeks")
 reported_cases <- data.frame(date = dates, confirm = unlist(incidence[,1]))
 
 #Get generation time
 gt <- simdubcensored_SIR(21, 1/7) |>
   (\(x) x / sum(x))()
 plot(gt, col = "blue")
 gen_time_epinow2 <- generation_time_opts(
   dist_spec(pmf = gt)
 )
 
 #Get sampling delays, this one is more complicated due to the stepchange 
 samplingstats <- simdubcensored_sampledelays_samplingscenario(21, 1/7, 0.007, 0.07, 0.3)
 prop_observed <- samplingstats[[2]]
 obs_epinow2 <- obs_opts(scale = list(mean = propobserved, sd = 0.15)) #putting a lot of uncertainty, best i can do on the stepchange really
 
 samplingpmf <- samplingstats[[1]] |>
   (\(x) x/sum(x))()
 plot(samplingpmf, col = 'red')
 delays_epinow2 <- delay_opts(dist_spec(pmf = sample_pmf))
 
 
 
 
 options(mc.cores = 8)
 out <- epinow(reported_cases = reported_cases, 
               generation_time = gen_time_epinow2, #From above
               delays = delays_epinow2,
               obs = obs_epinow2,
               rt = rt_opts(prior = list(mean = 1.5, sd = 1.0)), #I think this makes sense, Rt starts high and gets low, mean over the whole time is 1.5ish
               gp = gp_opts(basis_prop = 0.2), 
               stan = stan_opts(samples = 4000),
               horizon = 0, 
               target_folder = "results",
               logs = file.path("logs", Sys.Date()),
               return_output = TRUE, 
               verbose = TRUE)
 plot(out)
 
 saveRDS(out, "SS3OC_epinow_maybefinal.RDS")
 
 
 
 