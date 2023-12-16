library(tidyverse)
library(paletteer)
library(HDInterval)
library(plotly)
library(xml2)
library(truncnorm)
library(RColorBrewer)
library(ape)
library(Metrics)
library(stableGR)
library(dplyr)
library(stringr)
library(fitdistrplus)
library(scoringRules)
library(scoringutils)
library(forestplot)
library(dplyr)
library(magrittr)
library(vioplot)


fig2_plottruth <- function(datacode, xlimits) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  plot(truth$t, truth$I, type = "l", ylab = "True Number Infected", xaxt = "n", xlab = "", lwd = 1.5, lty = 5, xlim = xlimits)
}

fig2_plottree <- function(datacode, xlimits)  {
  tree <- read.tree(paste0("simulateddata_data/", datacode, "/", datacode, "_downsampledtree.tree"))
  tree$tip.label[] = ""
  plot(tree, root.edge = TRUE, edge.color = c("darkslateblue"), x.lim = xlimits)
  axis(1)
  title(xlab = "Time")
}

fig2_plotweeklyincidence <- function(datacode, xlimits)  {
  incidence <- read.table(paste0("simulateddata_data/", datacode, "/", datacode, "_weeklyincidence.txt"))[,1]
  plot(seq(7, 7*length(incidence), 7), incidence, pch = 10, col = "orangered3", ylab = "Weekly Case Incidence", xlab = "Time", cex = 1.5, xlim = xlimits)
}

fig3_plottrajectories <- function(datacode, foldername, linecolour, shapecolour, xlabel, xlimits, ylimits, title) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  if (xlabel) {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xlab = "Time", ylab = "Incidence", main = title)
  } else {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xaxt = "n", xlab = "", ylab = "Incidence", main = title)
  }
  hpds <- HDInterval::hdi(trajectories, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(trajectories, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig4_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt == 0] <- 0.00001
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, log = 'y', ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, log = 'y', ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  #rt <- betagammartfromfolder(foldername, 0.1)
  hpds <- HDInterval::hdi(rt, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(rt, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig4b_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.0001
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, log = 'y', xlim = xlimits, ylim = ylimits, ylab = "", xlab = "Time")
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, log = 'y', xlim = xlimits, ylim = ylimits, ylab = "", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  #rt <- betagammartfromfolder(foldername, 0.1)
  hpds <- HDInterval::hdi(rt, 0.9)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(rt, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(rt, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig5_plottrajectories <- function(datacode, foldername, linecolour, shapecolour, xlabel, xlimits, ylimits) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  if (xlabel) {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xlab = "Time", ylab = "Incidence")
  } else {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xaxt = "n", xlab = "", ylab = "Incidence")
  }
  hpds <- HDInterval::hdi(trajectories, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(trajectories, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig5b_plottrajectories <- function(datacode, foldername, linecolour, shapecolour, xlabel, xlimits, ylimits, title) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  if (xlabel) {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xlab = "Time", ylab = "", main = title)
  } else {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xaxt = "n", xlab = "", ylab = "", main = title)
  }
  hpds <- HDInterval::hdi(trajectories, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- HDInterval::hdi(trajectories, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(trajectories, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig6_getrowentries <- function(foldername, burnin, truth, scenario, approach, colour) {
  params <- loadparamsminusburnin(foldername, burnin)
  paramlabels <- colnames(params)
  scaled <- (params[,1] - truth[1])/truth[1]
  df <- data.frame(Scenario = rep(scenario, length(scaled)),
                   Approach = rep(approach, length(scaled)),
                   Parameter = rep(paramlabels[1], length(scaled)),
                   Identifier = rep(paste0(approach, "_", paramlabels[1]), length(scaled)),
                   Value = scaled,
                   Colour = rep(colour, length(scaled)))
  for (i in 2:(length(paramlabels)-1)) {
    scaled <- (params[,i] - truth[i])/truth[i]
    df_copy <- data.frame(Scenario = rep(scenario, length(scaled)),
                          Approach = rep(approach, length(scaled)),
                          Parameter = rep(paramlabels[i], length(scaled)),
                          Identifier = rep(paste0(approach, "_", paramlabels[i]), length(scaled)),
                          Value = scaled,
                          Colour = rep(colour, length(scaled)))
    df <- rbind(df, df_copy)
  }
  
  return(df)
}

fig8_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.001
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, log = 'y', lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Rt", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, log = 'y', lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Rt", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  hpds <- HDInterval::hdi(rt, 0.95)
  means <- colMeans(rt)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), 
          col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
    lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig8_plotEpiNow2 <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.001
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, log = 'y', ylim = ylimits, ylab = "Rt", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, log = 'y', ylim = ylimits, ylab = "Rt", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  out <- readRDS(foldername)
  estimates <- out$estimates
  summarised <- estimates$summarised
  EpiRs <- summarised$mean
  EpiRs <- EpiRs[summarised$variable=="R"]
  EpiRLow90 <- summarised$lower_90[summarised$variable=="R"] 
  EpiRUp90 <- summarised$upper_90[summarised$variable=="R"]
  lines(seq(7, xlimits[2]), EpiRs[1:(xlimits[2]-6)], col = linecolour)
  polygon(c(seq(7, xlimits[2]), seq(xlimits[2],7)), c(EpiRLow90[1:(xlimits[2]-6)], rev(EpiRUp90[1:(xlimits[2]-6)])), 
          col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
}

fig8_plotBDSky <- function(datacode, filename, changetimes, lastsequence, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", log = 'y', lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Rt", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", log = 'y', lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Rt", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  tab <- read.table(filename, sep = "\t", header = T)
  means <- as.numeric(tab[1,2:(ncol(tab))])
  hpds <- tab[8,2:(ncol(tab))]
  gethpd <- function(str, ind) {
    val <- as.numeric(str_remove(str_remove(unlist(str_split(str, ","))[ind], "\\["), "\\]"))
    return(val)
  }
  upperhpds <- sapply(hpds, gethpd, 2)
  lowerhpds <- sapply(hpds, gethpd, 1)
  changetimes <- lastsequence - (changetimes*365)
  for (d in seq(2, length(changetimes)-1)) {
    start <- changetimes[d]
    end <- changetimes[d+1]
    lines(c(start,end), rep(means[d], 2), col = linecolour, lwd =2)
    polygon(c(start, start, end, end), c(upperhpds[d], lowerhpds[d], lowerhpds[d], upperhpds[d]), 
              col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
  }
}

fig8_plotTimTam <- function(datacode, foldername, changetimes, lastsequence, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.001
  if (xaxis) {
    plot(realrt, type = "l", log = 'y', lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Rt", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", log = 'y', lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Rt", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }  
  tab <- read.table(foldername, sep = "\t", header = T)
    means <- as.numeric(tab[1,2:ncol(tab)])
    hpds <- tab[8,2:ncol(tab)]
    gethpd <- function(str, ind) {
      val <- as.numeric(str_remove(str_remove(unlist(str_split(str, ","))[ind], "\\["), "\\]"))
      return(val)
    }
    upperhpds <- sapply(hpds, gethpd, 2)
    lowerhpds <- sapply(hpds, gethpd, 1)
    changetimes <- lastsequence - (changetimes)
    means <- means
    upperhpds <- upperhpds
    lowerhpds <- lowerhpds
    print(changetimes)
    print(means)
    for (d in seq(2, length(changetimes)-1)) {
      start <- changetimes[d]
      end <- changetimes[d+1]
      lines(c(start,end), rep(means[d], 2), col = linecolour, lwd =2)
      polygon(c(start, start, end, end), c(upperhpds[d], lowerhpds[d], lowerhpds[d], upperhpds[d]), 
              col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
    }
  
}

fig8b_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.001
  if (xaxis) {
    plot(realrt, type = "l", log = 'y', lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", log = 'y', lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  hpds <- HDInterval::hdi(rt, 0.95)
  means <- colMeans(rt)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), 
          col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig8b_plotEpiNow2 <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.001
  if (xaxis) {
    plot(realrt,type = "l", lty = 5, lwd = 1.5, log = 'y', xlim = xlimits, ylim = ylimits, ylab = "", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, log = 'y', xlim = xlimits, ylim = ylimits, ylab = "", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  out <- readRDS(foldername)
  estimates <- out$estimates
  summarised <- estimates$summarised
  EpiRs <- summarised$mean
  EpiRs <- EpiRs[summarised$variable=="R"]
  EpiRLow90 <- summarised$lower_90[summarised$variable=="R"] 
  EpiRUp90 <- summarised$upper_90[summarised$variable=="R"]
  lines(seq(7, xlimits[2]), EpiRs[1:(xlimits[2]-6)], col = linecolour)
  polygon(c(seq(7, xlimits[2]), seq(xlimits[2],7)), c(EpiRLow90[1:(xlimits[2]-6)], rev(EpiRUp90[1:(xlimits[2]-6)])), 
          col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
}

fig8b_plotBDSky <- function(datacode, filename, changetimes, lastsequence, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.001
  if (xaxis) {
    plot(realrt, log = 'y', type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, log = 'y', type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  tab <- read.table(filename, sep = "\t", header = T)
  means <- as.numeric(tab[1,2:(ncol(tab))])
  hpds <- tab[8,2:(ncol(tab))]
  gethpd <- function(str, ind) {
    val <- as.numeric(str_remove(str_remove(unlist(str_split(str, ","))[ind], "\\["), "\\]"))
    return(val)
  }
  upperhpds <- sapply(hpds, gethpd, 2)
  lowerhpds <- sapply(hpds, gethpd, 1)
  changetimes <- lastsequence - (changetimes*365)
  for (d in seq(2, length(changetimes)-1)) {
    start <- changetimes[d]
    end <- changetimes[d+1]
    lines(c(start,end), rep(means[d], 2), col = linecolour, lwd =2)
    polygon(c(start, start, end, end), c(upperhpds[d], lowerhpds[d], lowerhpds[d], upperhpds[d]), 
            col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
  }
}

fig8b_plotTimTam <- function(datacode, foldername, changetimes, lastsequence, linecolour, shapecolour, xaxis, xlimits, ylimits, title) {
  realrt <- getrealrt_option2(datacode)
  realrt[realrt==0] <- 0.001
  if (xaxis) {
    plot(realrt, log = 'y', type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, log = 'y', type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }  
  tab <- read.table(foldername, sep = "\t", header = T)
  means <- as.numeric(tab[1,2:ncol(tab)])
  hpds <- tab[8,2:ncol(tab)]
  gethpd <- function(str, ind) {
    val <- as.numeric(str_remove(str_remove(unlist(str_split(str, ","))[ind], "\\["), "\\]"))
    return(val)
  }
  upperhpds <- sapply(hpds, gethpd, 2)
  lowerhpds <- sapply(hpds, gethpd, 1)
  changetimes <- lastsequence - (changetimes)
  means <- means
  upperhpds <- upperhpds
  lowerhpds <- lowerhpds
  print(changetimes)
  print(means)
  for (d in seq(2, length(changetimes)-1)) {
    start <- changetimes[d]
    end <- changetimes[d+1]
    lines(c(start,end), rep(means[d], 2), col = linecolour, lwd =2)
    polygon(c(start, start, end, end), c(upperhpds[d], lowerhpds[d], lowerhpds[d], upperhpds[d]), 
            col = adjustcolor(shapecolour, alpha.f = 0.3), border = F)
  }
  
}

#####Table functions #####
table2_rtrmse <- function(datacode, foldername, start, end) {
  realrt <- getrealrt_option2(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  means <- colMeans(rt)
  realrt <- realrt[analysisstart:length(realrt)]
  rtrmse <- rmse(realrt[start:end], means[start:end]) 
  print(paste0("Rt RMSE: ", rtrmse))
}

table2_trajrmse <- function(datacode, foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  means <- colMeans(trajectories, na.rm = T)
  realtraj <- realtraj[analysisstart:length(realtraj)]
  rtrmse <- rmse(realtraj[1:min(length(realtraj), length(means))], means[1:min(length(realtraj), length(means))]) 
  print(paste0("Traj RMSE: ", rtrmse))
}

table2_trajaccuracy1 <- function(datacode,foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  hpds <- HDInterval::hdi(trajectories, 0.95)
  realtraj <- realtraj[analysisstart:analysisend]
  inhpd <- 0
  for (i in 1:length(realtraj)) {
    if (realtraj[i] > hpds[1,i]) {
      if (realtraj[i] < hpds[2,i]) {
        inhpd <- inhpd + 1
      }
    }
  }
  prop <- inhpd/length(realtraj)
  print(paste0("Accuracy: ", prop/0.95))
}

table2_trajaccuracy2 <- function(datacode,foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  hpds <- HDInterval::hdi(trajectories, 0.95)
  inhpd <- 0
  for (i in 1:min(length(realtraj), analysisend)) {
    if (realtraj[i] > hpds[1,i]) {
      if (realtraj[i] < hpds[2,i]) {
        inhpd <- inhpd + 1
      }
    }
  }
  prop <- inhpd/length(realtraj)
  print(paste0("Accuracy: ", prop/0.95))
}

table2_trajhpd <- function(datacode,foldername) {
  truth <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  hpds <- HDInterval::hdi(trajectories, 0.95)
  truth <- truth[analysisstart:length(truth)]
  widths <- (hpds[2,]-hpds[1,])
  scaledwidths <- widths[1:min(length(widths), length(truth))]/truth[1:min(length(widths), length(truth))]
  print(paste0("HPD width: ", mean(scaledwidths)))
}

table2_rthpd <- function(datacode,foldername, start, end) {
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  truth <- getrealrt_option2(datacode)
  truth[truth==0] <- 0.001
  hpds <- HDInterval::hdi(rt, 0.95)
  widths <- hpds[2,]-hpds[1,]
  truth <- truth[analysisstart:length(truth)]
  scaledwidths <- widths[start:end]/truth[start:end]
  print(paste0("HPD width: ", mean(scaledwidths)))
}

table2_rthpd_coverage <- function(datacode,foldername, start, end) {
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  truth <- getrealrt_option2(datacode)
  truth[truth==0] <- 0.001
  hpds <- HDInterval::hdi(rt, 0.95)
  widths <- hpds[2,]-hpds[1,]
  truth <- truth[analysisstart:length(truth)]
  inhpd <- 0
  for (i in start:end) {
    if (truth[i] > hpds[1,i]) {
      if (truth[i] < hpds[2,i]) {
        inhpd <- inhpd + 1
      }
    }
  }
  prop <- inhpd/(end-start)
  print(paste0("Rt coverage: ", prop/0.95))
}

table2_rttransmitaccuracy1 <- function(datacode, foldername, delay) {
  realrt <- getrealrt_option2(datacode)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort(trajectories, delay)
  realrtphase <- realrt
  realrtphase[realrtphase>=1] <- 1
  realrtphase[realrtphase<1] <- 0
  hpds <- hdi(rt, 0.95)
  percent <- getpercentvector(hpds, realrtphase)
  print(paste0("Phase accuracy: ", mean(percent)))
}

table2_rttransmitaccuracy2 <- function(datacode, foldername, delay) {
  realrt <- getrealrt_option2(datacode)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  analysisend <- getanalysisend(foldername)
  print(analysisend)
  rt <- trajectorytabletort(trajectories, delay)
  realrtphase <- realrt
  realrtphase[realrtphase>=1] <- 1
  realrtphase[realrtphase<1] <- 0
  hpds <- hdi(rt, 0.95)[,1:length(realrtphase)]
  percent <- getpercentvector(hpds, realrtphase)
  print(paste0("Phase accuracy: ", mean(percent)))
}

table2_CRPS_2 <- function(datacode, foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  means <- c()
  sds <- c()
  for (i in 1:ncol(trajectories)) {
    fit <- fitdistr(trajectories[,i], "normal")
    means[i] <- fit$estimate[1]
    sds[i] <- fit$estimate[2]
  }
  distributions <- data.frame(means, sds)
  score <- crps_norm(na.omit(realtraj[analysisstart:analysisend]), mean = means, sd = sds)
  return(mean(score))
}

table2_CRPS <- function(datacode, foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  trajectories <- t(trajectories)
  realtraj <- realtraj[analysisstart:length(realtraj)]
  score <- crps_sample(realtraj[1:min(length(realtraj), nrow(trajectories))], trajectories[1:min(length(realtraj), nrow(trajectories)),])
  return(mean(score))
}

table2_rt_CRPS <- function(datacode, foldername) {
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt[rt==0] <- 0.001
  for (i in 1:ncol(rt)) {
    rt[is.nan(rt[,i]), i] <- 0.001
  }
  rt[is.na(rt)] <- 0.001
  #rtcop <- rt
  #for (i in 1:nrow(rt)) {
  #  rtcop[i,] <- slidingwindow(rt[i,])
  #}

  trajectories<- rt
  realtraj <- getrealrt_option2(datacode)
  realtraj[is.nan(realtraj)] <- 0.0001
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- t(trajectories)
  realtraj <- realtraj[analysisstart:length(realtraj)]
  realtraj[is.nan(realtraj)] <- 0.001
  score <- crps_sample(realtraj[2:min(length(realtraj), nrow(trajectories))], trajectories[2:min(length(realtraj), nrow(trajectories)),])
  return(mean(score))
}

table2_brierscore <- function(datacode, foldername, start, end) {
  realrt <- getrealrt_option2(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt <- as.matrix(rt)
  rtcop <- rt
  for (i in 1:nrow(rt)) {
    rtcop[i,] <- slidingwindow(rt[i,])
  }
  rt <- rtcop
  rt[rt==0] <- 0.001
  realrtphase <- realrt
  realrtphase[realrtphase<=1] <- 0
  realrtphase[realrtphase>1] <- 1
  probabilities <- c()
  rt[is.nan(rt)] <- 0.001
  for (i in 1:ncol(rt)) {
    fit <- fitdistr(na.omit(rt[,i]), "normal")
    mean <- fit$estimate[1]
    sd <- fit$estimate[2]
    probabilities[i] <- pnorm(1, mean, sd)
  }
  probabilities <- 1-probabilities
  realrtphase <- realrtphase[analysisstart:length(realrtphase)]
  brier <- brier_score(realrtphase[start:end], probabilities[start:end])
  print(paste0("Brier score: ", mean(brier)))
}

#####Table 3#####

table3_epinow2_rtrmse <- function(datacode, filename, start, end) {
  realrt <- getrealrt_option2(datacode)
  out <- readRDS(filename)
  estimates <- out$estimates
  summarised <- estimates$summarised
  EpiRs <- summarised$mean
  EpiRs <- EpiRs[summarised$variable=="R"]
  realrt <- realrt[7: length(realrt)] #This puts the real rt and EpiNow2 Rt from the same start point
  print(paste0("EpiNow2 Rt rmse:", rmse(EpiRs[start:end], realrt[start:end]) ))

}

table3_BDSky_rtrmse <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  tab <- read.table(filename, sep = "\t", header = T)
  means <- as.numeric(tab[1,2:(ncol(tab))])
  changetimes <- lastsequence - round(changetimes*365)
  times <- c()
  rts <- c()
  for (d in seq(1, length(changetimes)-1)) {
    times <- append(times, seq(changetimes[d], changetimes[d+1]-1))
    rts <- append(rts, rep(means[d], changetimes[d+1]-changetimes[d]))
  }
  rts <- rts[which(times > 0)][start:end]
  times <- times[which(times > 0)][start:end]
  rts <- na.omit(rts)
  times <- times[1:length(rts)]
  realrt <- realrt[times]
  print(paste0("BDSky Rt rmse:",rmse(rts, realrt)))
}

table3_TimTam_rtrmse <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  tab <- read.table(filename, sep = "\t", header = T)
  means <- as.numeric(tab[1,2:(ncol(tab))])
  changetimes <- lastsequence - changetimes
  times <- c()
  rts <- c()
  for (d in seq(1, length(changetimes)-1)) {
    times <- append(times, seq(changetimes[d], changetimes[d+1]-1))
    rts <- append(rts, rep(means[d], changetimes[d+1]-changetimes[d]))
  }
  rts <- rts[which(times > 0)][start:end]
  times <- times[which(times > 0)][start:end]
  rts <- na.omit(rts)
  times <- times[1:length(rts)]
  realrt <- realrt[times]
  print(paste0("TimTam Rt rmse:",rmse(rts, realrt)))
}

table3_epinow2_CRPS <- function(datacode, filename, start, end) {
  realrt <- getrealrt_option2(datacode)
  realrt <- realrt[7: length(realrt)]
  out <- readRDS(filename)
  tab <- out$estimates$samples %>%
    dplyr::filter(variable== "R") %>%
    dplyr::select(time, sample, value) %>%
    tidyr::pivot_wider(names_from = sample, values_from = value) %>%
    dplyr::select(!time)
  tab <- as.matrix(tab)
  tab <- tab[1:min(length(realrt), nrow(tab)),]
  tab <- as.matrix(tab)
  score <- crps_sample(realrt[start:end], tab[start:end,])
  return(paste0("EpiNow2 CRPS:",mean(score)))
  
}

table3_EpiFusion_CRPS <- function(datacode, foldername, start, end) {
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  rt <- loadrtsminusburnin(foldername, 0.1)
  rt[rt==0] <- 0.001
  for (i in 1:ncol(rt)) {
    rt[is.nan(rt[,i]), i] <- 0.001
  }
  rt[is.na(rt)] <- 0.001
  #rtcop <- rt
  #for (i in 1:nrow(rt)) {
  #  rtcop[i,] <- slidingwindow(rt[i,])
  #}
  
  trajectories<- rt
  realtraj <- getrealrt_option2(datacode)
  realtraj[is.nan(realtraj)] <- 0.0001
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- t(trajectories)
  realtraj <- realtraj[analysisstart:length(realtraj)]
  realtraj[is.nan(realtraj)] <- 0.001
  score <- crps_sample(realtraj[start:end], trajectories[start:end,])
  return(paste0("EpiFusion CRPS:",mean(score)))
}

table3_BDSky_CRPS <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  tab <- read.table(filename, sep = "\t", header = T) %>%
    dplyr::select(!(dplyr::starts_with('state')))
  tab <- as.matrix(tab)
  changetimes <- lastsequence - round(changetimes*365)
  rtsamples <- matrix(0, nrow = lastsequence, ncol = nrow(tab))
  changetimes[changetimes < 1] = 1
  for (d in seq(1, length(changetimes)-1)) {
    times <- seq(changetimes[d], changetimes[d+1]-1)
    rtsamples[times,] <- tab[,d]
  }
  rts <- rtsamples[start:end,]
  realrt <- realrt[start:end]
  score <- crps_sample(realrt, rts)
  return(paste0("BDSky CRPS:",mean(score)))
}

table3_TimTam_CRPS <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  tab <- read.table(filename, sep = "\t", header = T) %>%
    dplyr::select(!(dplyr::starts_with('state')))
  tab <- as.matrix(tab)
  changetimes <- lastsequence - changetimes
  rtsamples <- matrix(0, nrow = lastsequence, ncol = nrow(tab))
  changetimes[changetimes < 1] = 1
  for (d in seq(1, length(changetimes)-1)) {
    times <- seq(changetimes[d], changetimes[d+1]-1)
    rtsamples[times,] <- tab[,d]
  }
  rts <- rtsamples[start:end,]
  realrt <- realrt[start:end]
  score <- crps_sample(realrt, rts)
  return(paste0("TimTam CRPS:",mean(score)))
}

table3_epinow2_brier <- function(datacode, filename, start, end) {
  realrt <- getrealrt_option2(datacode)
  realrt <- realrt[7:length(realrt)]
  out <- readRDS(filename)
  tab <- out$estimates$samples %>%
    dplyr::filter(variable== "R") %>%
    dplyr::select(time, sample, value) %>%
    tidyr::pivot_wider(names_from = sample, values_from = value) %>%
    dplyr::select(!time)
  tab <- as.matrix(tab)
  print(nrow(tab))
  print(length(realrt))
  tab <- tab[1:end,]
  tab <- as.matrix(tab)
  
  probabilities <- c()
  for (d in 1:nrow(tab)) {
    probabilities[d] <- sum(tab[d,]<=1)/length(tab[d,])
  }
  probabilities <- 1-probabilities
  realrtphase <- realrt
  realrtphase[realrtphase<=1] <- 0
  realrtphase[realrtphase>1] <- 1
  
  score <- brier_score(realrtphase[start:end], probabilities[start:end])
  return(paste0("EpiNow2 Brier:",mean(score)))
  
}

table3_BDSky_brier <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  realrtphase <- realrt
  realrtphase[realrtphase<=1] <- 0
  realrtphase[realrtphase>1] <- 1
  
  tab <- read.table(filename, sep = "\t", header = T) %>%
    dplyr::select(!(dplyr::starts_with('state')))
  tab <- as.matrix(tab)
  changetimes <- lastsequence - round(changetimes*365)
  rtsamples <- matrix(0, nrow = lastsequence, ncol = nrow(tab))
  changetimes[changetimes < 1] = 1
  probabilities <- c()
  for (d in seq(1, length(changetimes)-1)) {
    times <- seq(changetimes[d], changetimes[d+1]-1)
    probabilities[times] <- sum(tab[,d]<=1)/length(tab[,d])
  }
  probabilities <- 1-probabilities
  probabilities <- probabilities[start:end]
  realrtphase <- realrtphase[start:end]
  brier <- brier_score(realrtphase, probabilities)
  print(paste0("BDSky Brier score: ", mean(brier)))
}

table3_TimTam_brier <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  realrtphase <- realrt
  realrtphase[realrtphase<=1] <- 0
  realrtphase[realrtphase>1] <- 1
  
  tab <- read.table(filename, sep = "\t", header = T) %>%
    dplyr::select(!(dplyr::starts_with('state')))
  tab <- as.matrix(tab)
  changetimes <- round(lastsequence - changetimes)
  rtsamples <- matrix(0, nrow = lastsequence, ncol = nrow(tab))
  changetimes[changetimes < 1] = 1
  probabilities <- c()
  for (d in seq(1, length(changetimes)-1)) {
    times <- seq(changetimes[d], changetimes[d+1]-1)
    probabilities[times] <- sum(tab[,d]<=1)/length(tab[,d])
  }
  probabilities <- 1-probabilities
  probabilities <- probabilities[start:end]
  realrtphase <- realrtphase[start:end]
  brier <- brier_score(realrtphase, probabilities)
  print(paste0("TimTam Brier score: ", mean(brier)))
}

table3_epinow2_coverage <- function(datacode, filename, start, end) {
  realrt <- getrealrt_option2(datacode)
  realrt <- realrt[7:length(realrt)]
  out <- readRDS(filename)
  estimates <- out$estimates
  summarised <- estimates$summarised
  EpiRLow90 <- summarised$lower_90[summarised$variable=="R"] 
  EpiRUp90 <- summarised$upper_90[summarised$variable=="R"]
  inhpd <- 0
  for (i in start:end) {
    if (realrt[i] > EpiRLow90[i]) {
      if (realrt[i] < EpiRUp90[i]) {
        inhpd <- inhpd + 1
      }
    }
  }
  coverage <- inhpd / length(start:end)
  print(paste0("EpiNow2 Rt coverage:", coverage/0.9))
  
}

table3_BDSky_coverage <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  tab <- read.table(filename, sep = "\t", header = T)
  means <- as.numeric(tab[1,2:(ncol(tab))])
  hpds <- tab[8,2:(ncol(tab))]
  gethpd <- function(str, ind) {
    val <- as.numeric(str_remove(str_remove(unlist(str_split(str, ","))[ind], "\\["), "\\]"))
    return(val)
  }
  upperhpds <- sapply(hpds, gethpd, 2)
  lowerhpds <- sapply(hpds, gethpd, 1)
  changetimes <- lastsequence - round(changetimes*365)
  print(changetimes)
  times <- c()
  uppers <- c()
  lowers <- c()
  for (d in seq(1, length(changetimes)-1)) {
    times <- append(times, seq(changetimes[d], changetimes[d+1]-1))
    uppers <- append(uppers, rep(upperhpds[d], changetimes[d+1]-changetimes[d]))
    lowers <- append(lowers, rep(lowerhpds[d], changetimes[d+1]-changetimes[d]))
  }
  uppers <- uppers[which(times > 0)]
  lowers <- lowers[which(times > 0)]
  #times <- times[which(times > 0)][start:end]
  #uppers <- na.omit(uppers)
  #lowers <- na.omit(lowers)
  #times <- times[1:length(uppers)]
  #realrt <- realrt[times]
  inhpd <- 0
  for (i in start:end) {
    if (realrt[i] > lowers[i]) {
      if (realrt[i] < uppers[i]) {
        inhpd <- inhpd + 1
      }
    }
  }
    coverage <- inhpd / length(start:end)
    print(paste0("BDsky Rt coverage:", coverage/0.95))
}

table3_TimTam_coverage <- function(datacode, filename, changetimes, lastsequence, start, end) {
  realrt <- getrealrt_option2(datacode)
  tab <- read.table(filename, sep = "\t", header = T)
  means <- as.numeric(tab[1,2:(ncol(tab))])
  hpds <- tab[8,2:(ncol(tab))]
  gethpd <- function(str, ind) {
    val <- as.numeric(str_remove(str_remove(unlist(str_split(str, ","))[ind], "\\["), "\\]"))
    return(val)
  }
  upperhpds <- sapply(hpds, gethpd, 2)
  lowerhpds <- sapply(hpds, gethpd, 1)
  changetimes <- lastsequence - changetimes
  times <- c()
  uppers <- c()
  lowers <- c()
  for (d in seq(1, length(changetimes)-1)) {
    times <- append(times, seq(changetimes[d], changetimes[d+1]-1))
    uppers <- append(uppers, rep(upperhpds[d], changetimes[d+1]-changetimes[d]))
    lowers <- append(lowers, rep(lowerhpds[d], changetimes[d+1]-changetimes[d]))
  }
  uppers <- uppers[which(times > 0)]
  lowers <- lowers[which(times > 0)]
  inhpd <- 0
  for (i in start:end) {
    if (realrt[i] > lowers[i]) {
      if (realrt[i] < uppers[i]) {
        inhpd <- inhpd + 1
      }
    }
  }
  coverage <- inhpd / length(start:end)
  print(paste0("TIMTam Rt coverage:", coverage/0.95))
}


#####Supplementary Table####
supplementary_table2_valuesandrhat <- function(foldername, burnin, variable) {
  table <- loadparamsminusburnin(foldername, burnin)
  labels <- colnames(table)
  index <- match(variable, labels)
  
  values <- table[,index]
  print(mean(values))
  hpds <- hdi(values, 0.95)
  print(hpds)
  
  table <- loadparamsminusburninseparate(foldername, burnin)
  paramlist <- list()
  for (m in 1:length(table)) {
      paramlist[[m]] <- as.matrix(table[[m]][,index])
  }
  print(stable.GR(paramlist)$psrf)

}



#####Useful functions#####
getpercentvector <- function(hpds, posneg) {
  lower <- na.omit(hpds[1,])
  upper <- na.omit(hpds[2,])
  percentvector <- c()
  
  for (i in 1:length(lower)) {
    if (posneg[i] == 0) {
      correct <- 1 - lower[i]
      if (correct < 0) {
        correct <- 0
      }
      fullwidth <- upper[i] - lower[i]
      percent <- correct/fullwidth
      if (upper[i]==lower[i]) {
        if (upper[i] < 1) {
          percentvector[i] <- 1
        } else {
          percentvector[i] <- 0
        }
      } else if (percent > 1) {
        percent <- 1
      }
      percentvector[i] <- percent
    } else {
      correct <-upper[i] - 1
      if (correct < 0) {
        correct <- 0
      }
      fullwidth <- upper[i] - lower[i]
      percent <- correct/fullwidth
      if (upper[i]==lower[i]) {
        if (upper[i] > 1) {
          percentvector[i] <- 1
        } else {
          percentvector[i] <- 0
        }
      } else if (percent > 1) {
        percent <- 1
      }
      percentvector[i] <- percent
    }
  }
  return(percentvector)
}

gettrueI <- function(datacode) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  truthI <- c()
  truth$t <- ceiling(truth$t)
  for (i in 1:(max(truth$t))) {
    truthI[i] <- mean(truth$I[which(truth$t==i)])
    if (is.nan(truthI[i]) && i > 1) {
      truthI[i] <- truthI[i-1]
    } else if (is.nan(truthI[i])) {
      truthI[i] <- 1
    }
  }
  return(truthI)
}


getrealrt_option2 <- function(datacode) {
  rt <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_realRt_renewal.txt"), header = F)[,1]
  return(rt)
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

loadgammas <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "param")
  gammas <- list()
  for (f in 1:length(filepaths)) {
    params <- read.csv(paste0(folder,filepaths[f]), header = TRUE)
    burnin <- round(burn_in*nrow(params))
    params <- params[burnin:nrow(params),]
    gammas[f] <- mean(params$gamma)
  }
  print(gammas)
  return(gammas)
}

loadgammasminusburnin <- function(folder, burn_in) {
  filepaths <- list.files(folder, pattern = "param")
  print(filepaths)
  gammas <- c()
  for (f in 1:length(filepaths)) {
    params <- read.csv(paste0(folder,filepaths[f]), header = TRUE)
    burnin <- round(burn_in*nrow(params))
    params <- params[burnin:nrow(params),]
    gammas <- append(gammas, params$gamma)
  }
  return(gammas)
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

loadgammasfromfile <- function(file, folder) {
  trajectories <- read.csv(paste0(folder,file), header = T)$gamma
  print(trajectories)
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

slidingwindow <- function(vector){
  newvector <- c()
  for (i in 1:(length(vector)-1)) {
    newvector[i] <- mean(c(vector[i], vector[i+1]))
  }
  newvector[length(vector)] <- vector[length(vector)]
  return(newvector)
}

trajectorytruthbackground <- function(ylimit, plotlimits, datacode, xaxis) {
  truth <- read.csv(paste0("simulateddata_data", datacode, "/", datacode, "_table.csv"), header = T)
  plot(truth$t, truth$I, type = "l", lwd = 2, ylab = "I", xlab = "Time")
}

slidingwindow <- function(vector){
  newvector <- c()
  for (i in 1:(length(vector)-1)) {
    newvector[i] <- mean(c(vector[i], vector[i+1]))
  }
  newvector[length(vector)] <- vector[length(vector)]
  return(newvector)
}

betagammartfromfolder <- function(folder, burn_in) {
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

fig8_confintervals_rt <- function(foldernames, linecolours, shapecolours, delays, yaxis, xlimits, ylimits, title) {
  if (yaxis) {
    plot(-100, -100, xlim = xlimits, ylim = ylimits, xlab = "HPD Interval Width", ylab = "Density", main = title)
  } else {
    plot(-100, -100, xlim = xlimits, ylim = ylimits, xlab = "HPD Interval Width", ylab = "", main = title)
  }
  for (f in 1:length(foldernames)) {
    trajectories <- loadtrajectoriesminusburnin(foldernames[f], 0.1)
    rt <- trajectorytabletort(trajectories, delays[f])
    hpds <- hdi(rt, 0.95)
    widths <- hpds[2,]-hpds[1,]
    polygon(density(widths), col = adjustcolor(shapecolours[f], alpha.f = 0.5), border = linecolours[f], lty = 3)
    #hpds <- hdi(rt, 0.8)
    #widths <- hpds[2,]-hpds[1,]
    #polygon(density(widths), col = adjustcolor(shapecolours[f], alpha.f = 0.2), border = linecolours[f], lty = 3)
    #hpds <- hdi(rt, 0.66)
    #widths <- hpds[2,]-hpds[1,]
    #polygon(density(widths), col = adjustcolor(shapecolours[f], alpha.f = 0.2), border = linecolours[f], lty = 3)
  }
}

calculate_effective_R <- function(infection_trajectory, generation_time_pmf) {
  n <- length(infection_trajectory)
  R_effective <- numeric(n)
  
  for (t in 2:n) {
    sum_term <- 0
    for (k in 1:t) {
      if (t - k + 1 > 0) {
        sum_term <- sum_term + generation_time_pmf[k] * R_effective[t - k + 1]
        print(sum_term)
      }
    }
    R_effective[t] <- infection_trajectory[t] * sum_term
  }
  
  return(R_effective)
}

calculate_rt_2 <- function(infection_trajectory, generation_time_pmf) {
  rt <- c()
  for (i in 1:length(infection_trajectory)-1) {
    secondaries <- sum(infection_trajectory[(i+1):(i+length(generation_time_pmf))]*generation_time_pmf)
    rt[i] <- secondaries/infection_trajectory[i]
  }
  return(rt[1:(length(infection_trajectory)-length(generation_time_pmf))])
}


fig4x_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, gentime, title) {
  trueI <- gettrueI(datacode)
  realrt <- calculate_rt_2(trueI, gentime)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername) - length(gentime)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort_2(trajectories, gentime)
  rt[is.na(rt)] <- 0
  hpds <- hdi(rt, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(rt, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

trajectorytabletort_2 <- function(trajectories, gentime) {
  rtmatrix <- matrix(0, nrow = nrow(trajectories), ncol = ncol(trajectories)-length(gentime))
  for (i in 1:nrow(rtmatrix)) {
    rtmatrix[i,] <- calculate_rt_2(unlist(trajectories[i,]), gentime)
  }
  return(rtmatrix)
}





