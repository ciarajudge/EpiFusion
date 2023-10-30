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


fig2_plottruth <- function(datacode) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  plot(truth$t, truth$I, type = "l", ylab = "True Number Infected", xaxt = "n", xlab = "", lwd = 1.5, lty = 5)
}

fig2_plottree <- function(datacode)  {
  tree <- read.tree(paste0("simulateddata_data/", datacode, "/", datacode, "_downsampledtree.tree"))
  tree$tip.label[] = ""
  plot(tree, root.edge = TRUE, edge.color = c("darkslateblue"))
  axis(1)
  title(xlab = "Time")
}

fig2_plotweeklyincidence <- function(datacode)  {
  incidence <- read.table(paste0("simulateddata_data/", datacode, "/", datacode, "_weeklyincidence.txt"))[,1]
  plot(seq(7, 7*length(incidence), 7), incidence, pch = 10, col = "orangered3", ylab = "Weekly Case Incidence", xlab = "Time", cex = 1.5)
}

fig3_plottrajectories <- function(datacode, foldername, linecolour, shapecolour, xlabel, xlimits, ylimits) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  if (xlabel) {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xlab = "Time", ylab = "Incidence")
  } else {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xaxt = "n", xlab = "", ylab = "Incidence")
  }
  hpds <- hdi(trajectories, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(trajectories, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(trajectories, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(trajectories, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig4_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername) - delay
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort(trajectories, delay)
  hpds <- hdi(rt, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(rt, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig4b_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- slidingwindow(slidingwindow(slidingwindow(getrealrt_option2(datacode))))
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xlab = "Time")
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }

  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername) - delay
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort(trajectories, delay)
  hpds <- hdi(rt, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(rt, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig5_plotparamposterior <- function(foldername, parameter, truth, linecolour, shapecolour, plottrue, truthlabel) {
  params <- loadparamsminusburnin(foldername, 0.1)
  labels <- colnames(params)
  values <- params[,match(parameter, labels)]
  hpd <- hdi(values, 0.95)
  dd <- approxfun(density(values)$x, density(values)$y)
  polygon(density(values), col = adjustcolor(shapecolour, alpha.f = 0.4), border = F, ylab = "Density", xlab = "Value")
  lines(rep(hpd[1],2), c(0, dd(hpd[1])), col = linecolour, lty = 3)
  lines(rep(hpd[2],2), c(0, dd(hpd[2])), col = linecolour, lty = 3)
  lines(rep(mean(values),2), c(0, dd(mean(values))), col = linecolour, lty = 2)
  if (!is.na(truthlabel)) {
    ymax <- truthlabel
  } else {
    ymax <- max(density(values)$y)
  }
  
  if (plottrue) {
    lines(c(truth,truth), c(0,ymax*0.95), lwd = 2)
    text(truth, ymax, "True Value")
  }
}

fig6_plottrajectories <- function(datacode, foldername, linecolour, shapecolour, xlabel, xlimits, ylimits) {
  truth <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_table.csv"), header = T)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  if (xlabel) {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xlab = "Time", ylab = "Incidence")
  } else {
    plot(truth$t, truth$I, type = "l", xlim = xlimits, ylim = ylimits, lty = 1, lwd = 1.5, xaxt = "n", xlab = "", ylab = "Incidence")
  }
  hpds <- hdi(trajectories, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(trajectories, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(trajectories, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(trajectories, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig7_confintervals <- function(foldernames, linecolours, shapecolours, delays, yaxis, xlimits, ylimits, title) {
  if (yaxis) {
    plot(-100, -100, xlim = xlimits, ylim = ylimits, xlab = "HPD Interval Width", ylab = "Density", main = title)
  } else {
    plot(-100, -100, xlim = xlimits, ylim = ylimits, xlab = "HPD Interval Width", ylab = "", main = title)
  }
  for (f in 1:length(foldernames)) {
    trajectories <- loadtrajectoriesminusburnin(foldernames[f], 0.1)
    #rt <- trajectorytabletort(trajectories, delays[f])
    hpds <- hdi(trajectories, 0.95)
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

fig8_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername) - delay
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort(trajectories, delay)
  hpds <- hdi(rt, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(rt, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig8b_plotrt <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- slidingwindow(slidingwindow(slidingwindow(getrealrt_option2(datacode))))
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xlab = "Time")
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername) - delay
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort(trajectories, delay)
  hpds <- hdi(rt, 0.95)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.8)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  hpds <- hdi(rt, 0.66)
  polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  means <- colMeans(rt, na.rm = T)
  lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig8_plotEpiNow2 <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  out <- readRDS(foldername)
  estimates <- out$estimates
  summarised <- estimates$summarised
  EpiRs <- summarised$mean
  EpiRs <- EpiRs[summarised$variable=="R"]
  EpiRLow90 <- summarised$lower_90[summarised$variable=="R"] 
  EpiRUp90 <- summarised$upper_90[summarised$variable=="R"]
  lines(seq(7, xlimits[2]), EpiRs[1:(xlimits[2]-6)], col = "blue")
  polygon(c(seq(7, xlimits[2]), seq(xlimits[2],7)), c(EpiRLow90[1:(xlimits[2]-6)], rev(EpiRUp90[1:(xlimits[2]-6)])), col = adjustcolor("blue", alpha.f = 0.3), border = F)
}

fig8b_plotEpiNow2 <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  out <- readRDS(foldername)
  estimates <- out$estimates
  summarised <- estimates$summarised
  EpiRs <- summarised$mean
  EpiRs <- EpiRs[summarised$variable=="R"]
  EpiRLow90 <- summarised$lower_90[summarised$variable=="R"] 
  EpiRUp90 <- summarised$upper_90[summarised$variable=="R"]
  lines(seq(7, xlimits[2]), EpiRs[1:(xlimits[2]-6)], col = "blue")
  polygon(c(seq(7, xlimits[2]), seq(xlimits[2],7)), c(EpiRLow90[1:(xlimits[2]-6)], rev(EpiRUp90[1:(xlimits[2]-6)])), col = adjustcolor("blue", alpha.f = 0.3), border = F)
}

fig8_plotBDSky <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  #analysisstart <- getanalysisstart(foldername)
  #analysisend <- getanalysisend(foldername) - delay
  
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.8)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.66)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #means <- colMeans(rt, na.rm = T)
  #lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig8b_plotBDSky <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  #analysisstart <- getanalysisstart(foldername)
  #analysisend <- getanalysisend(foldername) - delay
  
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.8)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.66)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #means <- colMeans(rt, na.rm = T)
  #lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig8_plotEpiInf <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  #analysisstart <- getanalysisstart(foldername)
  #analysisend <- getanalysisend(foldername) - delay
  
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.8)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.66)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #means <- colMeans(rt, na.rm = T)
  #lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

fig8b_plotEpiInf <- function(datacode, foldername, linecolour, shapecolour, xaxis, xlimits, ylimits, delay, title) {
  realrt <- getrealrt_option2(datacode)
  if (xaxis) {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xlab = "Time", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  } else {
    plot(realrt, type = "l", lty = 5, lwd = 1.5, xlim = xlimits, ylim = ylimits, ylab = "Effective Reproduction Number", xaxt = "n", xlab = "", main = title)
    lines(c(0, length(realrt)), c(1,1), lty = 2, col = "grey")
  }
  #analysisstart <- getanalysisstart(foldername)
  #analysisend <- getanalysisend(foldername) - delay
  
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.8)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #hpds <- hdi(rt, 0.66)
  #polygon(c(seq(analysisstart,analysisend), rev(seq(analysisstart,analysisend))), c(hpds[1,], rev(hpds[2,])), col = adjustcolor(shapecolour, alpha.f = 0.2), border = F)
  #means <- colMeans(rt, na.rm = T)
  #lines(seq(analysisstart, analysisend), means, lwd = 1.5, col = linecolour)
}

table2_rtrmse <- function(datacode, foldername, delay) {
  realrt <- getrealrt_option2(datacode)
  analysisstart <- getanalysisstart(foldername) + 10
  analysisend <- getanalysisend(foldername) - delay
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort(trajectories, delay)
  means <- colMeans(rt, na.rm = T)
  print(means)
  print(realrt)
  rtrmse <- rmse(realrt[analysisstart:analysisend], means[10:length(means)]) 
  print(paste0("Rt RMSE: ", rtrmse))
}

table2_trajrmse <- function(datacode, foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  means <- colMeans(trajectories, na.rm = T)
  rtrmse <- rmse(realtraj[analysisstart:analysisend], means) 
  print(paste0("Traj RMSE: ", rtrmse))
}

table2_trajaccuracy1 <- function(datacode,foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  hpds <- hdi(trajectories, 0.8)
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
  print(paste0("Accuracy: ", prop))
}

table2_trajaccuracy2 <- function(datacode,foldername) {
  realtraj <- gettrueI(datacode)
  analysisstart <- getanalysisstart(foldername)
  analysisend <- getanalysisend(foldername)
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  hpds <- hdi(trajectories, 0.95)
  inhpd <- 0
  for (i in 1:min(length(realtraj), analysisend)) {
    if (realtraj[i] > hpds[1,i]) {
      if (realtraj[i] < hpds[2,i]) {
        inhpd <- inhpd + 1
      }
    }
  }
  prop <- inhpd/length(realtraj)
  print(paste0("Accuracy: ", prop))
}

table2_trajhpd <- function(datacode,foldername) {
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  hpds <- hdi(trajectories, 0.95)
  widths <- hpds[2,]-hpds[1,]
  print(paste0("HPD width: ", mean(widths)))
}

table2_rthpd <- function(datacode,foldername, delay) {
  trajectories <- loadtrajectoriesminusburnin(foldername, 0.1)
  rt <- trajectorytabletort(trajectories, delay)
  hpds <- hdi(rt, 0.95)
  widths <- hpds[2,]-hpds[1,]
  print(paste0("HPD width: ", mean(widths)))
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



#####Useful functions
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
  truth <- read.csv(paste0("/Users/ciarajudge/Desktop/PhD/EpiFusionData/", datacode, "/", datacode, "_table.csv"), header = T)
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

getrealrt_option1 <- function(datacode) {
  rt <- read.csv(paste0("/Users/ciarajudge/Desktop/PhD/EpiFusionData/", datacode, "/", datacode, "_realRt_option1.txt"), header = F)[,1]
  return(rt)
}

getrealrt_option2 <- function(datacode) {
  rt <- read.csv(paste0("simulateddata_data/", datacode, "/", datacode, "_realRt_option2.txt"), header = F)[,1]
  return(rt)
}

rtfromtrajectory <- function(trajectory, delay) {
  rt <- c()
  for (i in 1:(length(trajectory)-delay)) {
    rt[i] <- trajectory[i+delay]/trajectory[i]
    if (is.nan(rt[i])) {
      rt[i] <- 0
    }
  }
  return(rt)
}

trajectorytabletort <- function(trajectories, delay) {
  rtmatrix <- matrix(0, nrow = nrow(trajectories), ncol = ncol(trajectories)-delay)
  for (i in 1:nrow(rtmatrix)) {
    rtmatrix[i,] <- rtfromtrajectory(unlist(trajectories[i,]), delay)
  }
  return(rtmatrix)
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
  trajectories <- read.csv(paste0(folder, "trajectories_chain0.csv"), header = T)
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
  truth <- read.csv(paste0("/Users/ciarajudge/Desktop/PhD/EpiFusionData/", datacode, "/", datacode, "_table.csv"), header = T)
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
