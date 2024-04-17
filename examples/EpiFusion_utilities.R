if(!require(pacman)) install.packages("pacman",repos = "http://cran.us.r-project.org")
invisible(library(pacman))
invisible(p_load(tidyverse,paletteer,HDInterval,plotly,xml2,truncnorm,RColorBrewer,ape,Metrics,stableGR,dplyr,stringr,fitdistrplus,scoringRules,scoringutils,dplyr,magrittr,vioplot))


print('Loading EpiFusion functions.')

#In order of appearance in the tutorial
loadlikelihoods <- function(folder) {
  filepaths <- list.files(folder, pattern = "likelihoods")
  likelihoods <- list()
  for (i in 1:length(filepaths)) {
    likelihoods[[i]] <- read.table(paste0(folder, filepaths[i]), header = F)[,1]
  }
  return(likelihoods)
}

plotlikelihoodtrace <- function(folder) {
  cols <- c('red', 'blue', 'yellow', 'green', 'orange', 'purple')
  minimum <- 0
  maximum <- -Inf
  likelihoods <- loadlikelihoods(folder)
  xmax <- length(likelihoods[[1]])
  for (l in 1:length(likelihoods)) {
    likelihood <- likelihoods[[l]][!likelihoods[[l]]==-Inf]
    minimum <- min(minimum, min(likelihood))
    maximum <- max(maximum, max(likelihood))
  }
  plot(1,1, ylim = c(minimum, maximum), xlim = c(0, xmax),  col  = "white", xlab = "MCMC sample", ylab = "Log Likelihood", main = "Log Likelihood Trace (full chain)")
  for (l in 1:length(likelihoods)) {
    lines(1:length(likelihoods[[l]]), likelihoods[[l]], col = adjustcolor(cols[l], alpha.f=0.6), lwd = 1.5, type = 's')
  }
}

loadtrajectories <- function(folder) {
  trajectories <- read.csv(paste0(folder, "trajectories.csv"), header = T)
  analysisstart <- getanalysisstart(folder)
  analysisend <- getanalysisend(folder)
  analysislength <- analysisend - analysisstart + 1
  trajectories <- trajectories[,1:analysislength]
}

loadtrajectoriesfromfile <- function(file, folder) {
  trajectories <- read.csv(paste0(folder,file), header = T)
  analysisstart <- getanalysisstart(folder)
  analysisend <- getanalysisend(folder)
  analysislength <- analysisend - analysisstart + 1
  trajectories <- trajectories[,1:analysislength]
  return(trajectories)
}

loadtrajectoriesminusburnin <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "trajectories")
  traj <- loadtrajectoriesfromfile(filepaths[1], folder)
  burnin <- round(burn_in*nrow(traj))
  trajectories <- traj[burnin:nrow(traj),]
  for (f in 2:length(filepaths)) {
    traj <- loadtrajectoriesfromfile(filepaths[f], folder)
    burnin <- round(burn_in*nrow(traj))
    trajectories <- rbind(trajectories, traj[burnin:nrow(traj),])
  }
  return(trajectories)
}

plottrajectoriesfromtable <- function(trajectories, colour = 'darkolivegreen4') {
  hpds <- HDInterval::hdi(trajectories, 0.95)
  xmax <- max(hpds)
  means <- colMeans(trajectories, na.rm = T)
  plot(1:length(hpds[1,]), means, type = 'l', col = colour, ylim = c(0, xmax),
       main = 'Infection Trajectories', ylab = 'Number Infected', xlab = 'Time (days)')
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines( means, lwd = 1.5, col = colour)
}

plottrajectoryposteriors <- function(foldername, burnin, colour = 'darkolivegreen4') {
  trajectories <- loadtrajectoriesminusburnin(foldername, burnin)
  hpds <- HDInterval::hdi(trajectories, 0.95)
  xmax <- max(hpds)
  means <- colMeans(trajectories, na.rm = T)
  plot(1:length(hpds[1,]), means, type = 'l', col = colour, ylim = c(0, xmax), main = 'Infection Trajectories', ylab = 'Number Infected', xlab = 'Time (days)')
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

addtrajectoriesfromtable <- function(trajectories, colour = 'darkolivegreen4') {
  hpds <- HDInterval::hdi(trajectories, 0.95)
  xmax <- max(hpds)
  means <- colMeans(trajectories, na.rm = T)
  lines(1:length(hpds[1,]), means, col = colour)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines( means, lwd = 1.5, col = colour)
}

addtrajectoryposteriors <- function(foldername, burnin, colour = 'darkolivegreen4') {
  trajectories <- loadtrajectoriesminusburnin(foldername, burnin)
  hpds <- HDInterval::hdi(trajectories, 0.95)
  xmax <- max(hpds)
  means <- colMeans(trajectories, na.rm = T)
  lines(1:length(hpds[1,]), means, col = colour)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

loadrtsfromfile <- function(file, folder) {
  rts <- read.csv(paste0(folder,file), header = F)
  analysisstart <- getanalysisstart(folder)
  analysisend <- getanalysisend(folder)
  analysislength <- analysisend - analysisstart + 1
  rts <- rts[,1:analysislength]
  return(rts)
}

loadrtsminusburnin <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "rt_")
  traj <- loadrtsfromfile(filepaths[1], folder)
  burnin <- round(burn_in*nrow(traj))
  rts <- traj[burnin:nrow(traj),]
  for (f in 2:length(filepaths)) {
    traj <- loadrtsfromfile(filepaths[f], folder)
    burnin <- round(burn_in*nrow(traj))
    rts <- rbind(rts, traj[burnin:nrow(traj),])
  }
  return(rts)
}

plotrtposteriors_renewal <- function(foldername, burn_in, colour) {
  rt <- loadrtsminusburnin(foldername, burn_in)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  #rt <- betagammartfromfolder(foldername, 0.1)
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  plot(means, type = 'l', col = colour, ylim = c(0.001, ymax), main = "R(t) Trajectories", xlab = "Time (Days)", ylab = "R(t)")
  lines(c(1, length(hpds[1,])), c(1,1), lty = 2)
  hpds <- HDInterval::hdi(rt, 0.95)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

addrtposteriors_renewal <- function(foldername, burn_in, colour) {
  rt <- loadrtsminusburnin(foldername, burn_in)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  #rt <- betagammartfromfolder(foldername, 0.1)
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  lines(means, type = 'l', col = colour)
  lines(c(1, length(hpds[1,])), c(1,1), lty = 2)
  hpds <- HDInterval::hdi(rt, 0.95)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

plotrtfromtable_renewal <- function(rt, colour) {
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  #rt <- betagammartfromfolder(foldername, 0.1)
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  plot(means, type = 'l', col = colour, ylim = c(0.001, ymax), main = "R(t) Trajectories", xlab = "Time (Days)", ylab = "R(t)")
  lines(c(1, length(hpds[1,])), c(1,1), lty = 2)
  hpds <- HDInterval::hdi(rt, 0.95)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

addrtfromtable_renewal <- function(rt, colour) {
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  #rt <- betagammartfromfolder(foldername, 0.1)
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  lines(means, type = 'l', col = colour)
  lines(c(1, length(hpds[1,])), c(1,1), lty = 2)
  hpds <- HDInterval::hdi(rt, 0.95)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

loadbetasfromfile <- function(file, folder) {
  trajectories <- read.csv(paste0(folder,file), header = F)
  analysisstart <- getanalysisstart(folder)
  analysisend <- getanalysisend(folder)
  analysislength <- analysisend - analysisstart + 1
  trajectories <- trajectories[,1:analysislength]
}

loadbetasminusburnin <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "betas")
  traj <- loadbetasfromfile(filepaths[1], folder)
  burnin <- round(burn_in*nrow(traj))
  trajectories <- traj[burnin:nrow(traj),]
  for (f in 2:length(filepaths)) {
    traj <- loadbetasfromfile(filepaths[f], folder)
    burnin <- round(burn_in*nrow(traj))
    trajectories <- rbind(trajectories, traj[burnin:nrow(traj),])
  }
  return(trajectories)
}

loadgammasfromfile <- function(file, folder) {
  trajectories <- read.csv(paste0(folder,file), header = T)$gamma
  return(trajectories)
}

loadgammas <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "param")
  gammas <- list()
  for (f in 1:length(filepaths)) {
    params <- read.csv(paste0(folder,filepaths[f]), header = TRUE)
    burnin <- round(burn_in*nrow(params))
    params <- params[burnin:nrow(params),]
    gammas[f] <- mean(params$gamma)
  }
  return(gammas)
}

loadgammasminusburnin <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "param")
  gammas <- c()
  for (f in 1:length(filepaths)) {
    params <- read.csv(paste0(folder,filepaths[f]), header = TRUE)
    burnin <- round(burn_in*nrow(params))
    params <- params[burnin:nrow(params),]
    gammas <- append(gammas, params$gamma)
  }
  return(gammas)
}

loadbetagammartminusburnin <- function(folder, burn_in) {
  betafilepaths <- list.files(folder, pattern = "betas")
  gammasfilepaths <- list.files(folder, pattern = "param")
  betas <- loadbetasfromfile(betafilepaths[1], folder)
  gammas <- loadgammasfromfile(gammasfilepaths[1], folder)
  burnin <- round(burn_in*nrow(betas))
  betas <- betas[burnin:nrow(betas),]
  gammas <- gammas[burnin:length(gammas)]
  len <- min(length(gammas), nrow(betas))
  rt <- betas[1:len,]/gammas[1:len]
  for (f in 2:length(betafilepaths)) {
    betas <- loadbetasfromfile(betafilepaths[f], folder)
    gammas <- loadgammasfromfile(gammasfilepaths[f], folder)
    burnin <- round(burn_in*nrow(betas))
    betas <- betas[burnin:nrow(betas),]
    gammas <- gammas[burnin:length(gammas)]
    len <- min(length(gammas), nrow(betas))
    rt <- betas[1:len,]/gammas[1:len]
  }
  return(rt)
}

plotrtposteriors_betagamma <- function(foldername, burn_in, colour) {
  rt <- loadbetagammartminusburnin(foldername, burn_in)
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  plot(means, type = 'l', col = colour, ylim = c(0.001, ymax), main = "R(t) Trajectories", xlab = "Time (Days)", ylab = "R(t)", log = 'y')
  hpds <- HDInterval::hdi(rt, 0.95)
  lines(c(1, length(hpds[1,])), c(1,1), lty = 2)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

addrtposteriors_betagamma <- function(foldername, burn_in, colour) {
  rt <- loadbetagammartminusburnin(foldername, burn_in)
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  lines(means, col = colour)
  hpds <- HDInterval::hdi(rt, 0.95)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

plotrtfromtable_betagamma <- function(rt, colour) {
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  plot(means, type = 'l', col = colour, ylim = c(0.001, ymax), main = "R(t) Trajectories", xlab = "Time (Days)", ylab = "R(t)", log = 'y')
  hpds <- HDInterval::hdi(rt, 0.95)
  lines(c(1, length(hpds[1,])), c(1,1), lty = 2)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

addrtfromtable_betagamma <- function(rt, colour) {
  means <- colMeans(rt, na.rm = T)
  hpds <- HDInterval::hdi(rt, 0.95)
  ymax <- max(unlist(hpds)[!is.nan(unlist(hpds))&!is.na(unlist(hpds))])
  lines(means, col = colour)
  hpds <- HDInterval::hdi(rt, 0.95)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(1:length(hpds[1,]), rev(1:length(hpds[1,]))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(colour, alpha.f = 0.2), border = F)
  lines(means, lwd = 1.5, col = colour)
}

getXMLfile <- function(folder) {
  filepath <- list.files(folder, pattern = ".xml")
  xmlstem <- as_list(read_xml(paste0(folder,filepath)))
  xmlbase <- xmlstem$EpiFusionInputs
  return(xmlbase)
}

getanalysisstart <- function(folder) {
  trajectories <- read.csv(paste0(folder, "trajectories_chain0.csv"), header = T)
  days <- colnames(trajectories)
  day1 <- days[1]
  start <- as.integer(str_remove(day1, "T_"))+1
  return(start)
}

getanalysisend <- function(folder) {
  trajectories <- read.csv(paste0(folder, "trajectories_chain0.csv"), header = T, fill = T)
  trajectories <- trajectories[,1:(ncol(trajectories)-1)]
  endindex <- length(na.omit(unlist(trajectories[nrow(trajectories),])))
  days <- colnames(trajectories)
  day1 <- days[endindex]
  end <- as.integer(str_remove(day1, "T_"))+1
  return(end)
}

loadtrajectoriesminusburninseparate <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "trajectories")
  trajectories <- list()
  for (f in 1:length(filepaths)) {
    traj <- loadtrajectoriesfromfile(filepaths[f], folder)
    burnin <- round(burn_in*nrow(traj))
    trajectories[[f]] <- traj[burnin:nrow(traj),]
  }
  return(trajectories)
}

loadlikelihoods <- function(folder) {
  filepaths <- list.files(folder, pattern = "likelihoods")
  likelihoods <- list()
  for (i in 1:length(filepaths)) {
    likelihoods[[i]] <- read.table(paste0(folder, filepaths[i]), header = F)[,1]
  }
  return(likelihoods)
}

loadparamsfromfile <- function(file, folder) {
  trajectories <- read.csv(paste0(folder,file), header = T)
  return(trajectories)
}

loadparamsminusburnin <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "params")
  traj <- loadparamsfromfile(filepaths[1], folder)
  burnin <- round(burn_in*nrow(traj))
  trajectories <- traj[burnin:nrow(traj),]
  for (f in 2:length(filepaths)) {
    traj <- loadparamsfromfile(filepaths[f], folder)
    burnin <- round(burn_in*nrow(traj))
    trajectories <- rbind(trajectories, traj[burnin:nrow(traj),])
  }
  return(trajectories)
}

loadparamsminusburninseparate <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "params")
  print(filepaths)
  trajectories <- list()
  for (f in 1:length(filepaths)) {
    traj <- loadparamsfromfile(filepaths[f], folder)
    burnin <- round(burn_in*nrow(traj))
    trajectories[[f]] <- traj[burnin:nrow(traj),]
  }
  return(trajectories)
}

loadparamsseparate <- function(folder) {
  filepaths <- list.files(folder, pattern = "params")
  print(filepaths)
  trajectories <- list()
  for (f in 1:length(filepaths)) {
    traj <- loadparamsfromfile(filepaths[f], folder)
    trajectories[[f]] <- traj
  }
  return(trajectories)
}

loadparambyname <- function(folder, burn_in, name) {
  filepaths <- list.files(folder, pattern = "params")
  traj <- loadparamfromfilebyname(filepaths[1], folder, name)
  burnin <- round(burn_in*length(traj))
  trajectories <- traj[burnin:length(traj)]
  for (f in 2:length(filepaths)) {
    traj <- loadparamfromfilebyname(filepaths[f], folder, name)
    burnin <- round(burn_in*length(traj))
    trajectories <- c(trajectories, traj[burnin:length(traj)])
  }
  return(trajectories)
}

loadparamfromfilebyname <- function(file, folder, name) {
  trajectories <- read.csv(paste0(folder,file), header = T)
  return(unlist(trajectories[[name]]))
}

slidingwindow <- function(vector){
  newvector <- c()
  for (i in 1:(length(vector)-1)) {
    newvector[i] <- mean(c(vector[i], vector[i+1]))
  }
  newvector[length(vector)] <- vector[length(vector)]
  return(newvector)
}




