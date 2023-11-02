library(HDInterval)
library(EpiNow2)

incidence <- read.table("simulateddata_data/SS3OC/SS3OC_weeklyincidence.txt")

dates <- seq(as.Date(paste0(c("2021-01-07"), collapse = "")), 
             as.Date(paste0(c("2021-05-01"), collapse = "")), by="weeks")

reported_cases <- data.frame(date = dates, confirm = unlist(incidence[,1]))

reporting_delay <- estimate_delay(rexp(1000, (3)))

options(mc.cores = 4)
out <- epinow(reported_cases = reported_cases, 
              generation_time = reporting_delay,
              delays = delay_opts(),
              rt = rt_opts(prior = list(mean = 1.5, sd = 1.0)),
              gp = gp_opts(basis_prop = 0.2),
              stan = stan_opts(samples = 4000),
              horizon = 0, 
              target_folder = "results",
              logs = file.path("logs", Sys.Date()),
              return_output = TRUE, 
              verbose = TRUE)
 plot(out)

 saveRDS(out, "Publication1/epinow2_SS3OC_version1.RDS")
 
 
 layout(matrix(c(1)))
 out <- readRDS("/Users/ciarajudge/Desktop/PhD/Publication1/epinow2_SB4RC_version1.RDS")
 estimates <- out$estimates
 summarised <- estimates$summarised
 EpiRs <- summarised$mean
 EpiRs <- EpiRs[summarised$variable=="R"]
 EpiRLow90 <- summarised$lower_90[summarised$variable=="R"] 
 EpiRUp90 <- summarised$upper_90[summarised$variable=="R"]
 
plot(out)
 length(unique(out$estimates$samples$date))
 lines(seq(7, 140), EpiRs, col = "blue")
 polygon(c(seq(7, 140), seq(140,7)), c(EpiRLow90, rev(EpiRUp90)), col = adjustcolor("blue", alpha.f = 0.3), border = F)
 
 plottrajectorieswlikelihoods <- function(table, likelihoods, burnin) {
   indexes <- which(likelihoods == -Inf)
   scaledlikelihoods <- likelihoods
   scaledlikelihoods[indexes] <- 0
   scaledlikelihoods <- round(scaledlikelihoods-min(scaledlikelihoods))
   #print(scaledlikelihoods)
   colours <- paletteer_c("ggthemes::Red-Gold", max(scaledlikelihoods))
   for (i in burnin:nrow(table)) {
     if (!i %% 10 == 0 ) {
       next
     }
     if (i %in% indexes) {
       colour <- "grey"
     }
     else {
       colour <- colours[scaledlikelihoods[i]]
     }
     lines(seq(1,length(unlist(table[i,]))), unlist(table[i,]), lwd = 1.5, col = colour)
   }
 }
 
 
 plottrajectoryHPDs <- function(trajectories, colour = "red") {
   hpds <- hdi(trajectories, 0.9)
   polygon(c(seq(1,ncol(trajectories)), rev(seq(1,ncol(trajectories)))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.4), border = F)
   means <- colMeans(trajectories, na.rm = T)
   print(means)
   lines(means, lwd = 1.5, col = colour)
 }
 
 rtfromtrajectory <- function(trajectory) {
   rt <- c()
   for (i in 1:length(trajectory)-1) {
     rt[i] <- trajectory[i+1]/trajectory[i]
   }
   return(rt)
 }
 
 rtHPDs <- function(folder, colour, burnin) {
   truth <- read.csv(truthfile, header = T)
   truthI <- c()
   for (i in 1:ceiling(max(truth$t))) {
     truthI[i] <- truth$I[which(truth$t==max(truth$t[which(truth$t<i)]))]
   }
   rt <- c()
   for (i in 1:length(truthI)-1) {
     rt[i] <- truthI[i+1]/truthI[i]
   }
   rtsmoothed3 <- c()
   for (i in 1:length(rt)-1) {
     rtsmoothed3[i] <- (rt[i+1]+rt[i])/2
   }
   
   #plot(rtsmoothed3, type = "l", col = "black", lwd=2, main = "Rt versus Truth", ylab = "Effective reproduction number", xlab = "Day")
   #lines(c(0, ceiling(max(truthI))), c(1,1), lty = 2, col = "grey")
   
   trajectories <- read.csv(paste0(folder, "trajectories.csv"), header = T)
   burnin <- round(burnin*nrow(trajectories))
   trajectories <- trajectories[burnin:nrow(trajectories),1:ncol(trajectories)-1]
   rtmatrix <- matrix(0, nrow = nrow(trajectories), ncol = ncol(trajectories)-1)
   for (i in 1:nrow(rtmatrix)) {
     rtmatrix[i,] <- rtfromtrajectory(unlist(trajectories[i,]))
   }
   hpds <- hdi(rtmatrix, 0.9)
   upper <- na.omit(hpds[1,])
   lower <- na.omit(hpds[2,])
   polygon(c(seq(1,length(upper)), rev(seq(1,length(upper)))), c(upper, rev(lower)), col = adjustcolor(colour, alpha.f = 0.4), border = F)
   means <- colMeans(rtmatrix, na.rm = T)
   lines(means, lwd = 1.5, col = colour)
 }
 
 
 truthfile <- "/Users/ciarajudge/Desktop/PhD/EpiFusionData/basesim/basesimSEIR.csv"
 rtHPDs("EpiFusionResults/AAACL_AnalysisType1_/", "orange", 0.2)
 rtHPDs("EpiFusionResults/AAACH/", "darkolivegreen3", 0.2)

 lines(21:133, EpiRs, col = "blue") 
 polygon(c(21:133, rev(21:133)), c(EpiRLow90, rev(EpiRUp90)), col = adjustcolor("blue", alpha.f = 0.4), border = F)
 
 
 
 
 
 
 
 
 
 
 