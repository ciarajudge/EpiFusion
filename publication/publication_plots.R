setwd("/Users/ciarajudge/Desktop/PhD/EpiFusion/publication/")
source("publication_plots_utilities.R")

introduction_epi <- "model_results/introduction_EpiOnly/"
introduction_phylo <- "model_results/introduction_PhyloOnly/"
introduction_combined <- "model_results/introduction_Combined/"

sampling_epi <- "model_results/sampling_EpiOnly/"
sampling_phylo <- "model_results/sampling_PhyloOnly/"
sampling_combined <- "model_results/sampling_Combined/"

transmission_epi <- "model_results/transmission_EpiOnly/"
transmission_phylo <- "model_results/transmission_PhyloOnly/"
transmission_combined <- "model_results/transmission_Combined/"

introduction_EpiNow <- "benchmarking/introduction_EpiNow2.RDS"
introduction_BDSky <- "benchmarking/introduction_BDSky.tab"
introduction_TimTam <- "benchmarking/introduction_TimTam.tab"

sampling_EpiNow <- "benchmarking/sampling_EpiNow2.RDS"
sampling_BDSky <- "benchmarking/sampling_BDSky.tab"
sampling_TimTam <- "benchmarking/sampling_TimTam.tab"

transmission_EpiNow <- "benchmarking/transmission_EpiNow2.RDS"
transmission_BDSky <- "benchmarking/transmission_BDSky.tab"
transmission_TimTam <- "benchmarking/transmission_TimTam.tab"

#Figure 1 particle filter diagram (made in powerpoint)

#####Figure 2a b and c Tree and Case Incidence Example#####
par(ps = 12)
pdf("figs/Figure2a.pdf", width = 7.5, height = 5.5)
layout(matrix(c(1,2,3,2), nrow = 2, ncol = 2, byrow = T))
par(mar = c(0.5, 4, 0.1, 1))
fig2_plottruth("SB4RC")
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("SB4RC")
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("SB4RC")
dev.off()

#bc
pdf("figs/Figure2bc.pdf", width = 7.5, height = 3.5)
layout(matrix(c(1,2,3,4,5,2,6,4), nrow = 2, ncol = 4, byrow = T))
par(mar = c(0.5, 4, 0.1, 1))
fig2_plottruth("SS3OC")
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("SS3OC")
par(mar = c(0.5, 4, 0.1, 1))
fig2_plottruth("ST3RC")
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("ST3RC")
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("SS3OC")
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("ST3RC")
dev.off()


#####Figure 3 Introduction I's#####
pdf("figs/Figure3.pdf", width = 7.5, height = 9)
layout(matrix(c(1,2,3), nrow = 3), heights = c(1,1,1.2))
par(mar = c(0.5, 4, 0.1, 1))
fig3_plottrajectories("SB4RC", introduction_epi,
                      "orangered3", "orange", FALSE, c(0, 120), c(0, 5000))
text(90, 4500, "Case Incidence Only", cex = 2)
fig3_plottrajectories("SB4RC", introduction_phylo,
                      "darkslateblue", "slateblue", FALSE, c(0, 120), c(0, 5000))
text(90, 4500, "Tree Only", cex = 2)
par(mar = c(4, 4, 0.1, 1))
fig3_plottrajectories("SB4RC", introduction_combined,
                      "darkolivegreen4", "darkolivegreen3", TRUE, c(0, 120), c(0, 5000))
text(90, 4500, "Combined Datasets", cex = 2)
dev.off()

#####Figure 4 R 3x3 Matrix#####
pdf("figs/Figure4.pdf", width = 7.5, height = 7)
layout(matrix(c(1,2,3,4,5,6,7,8,9), nrow = 3, ncol = 3), heights = c(1.2,1,1.2), widths = c(1.1, 1,1))
par(mar = c(0.5, 4, 3, 1))
fig4_plotrt("SB4RC", introduction_epi,
            "orangered3", "orange", FALSE, c(1, 120), c(0, 8), 9, title = "Introduction")
par(mar = c(0.5, 4, 0.1, 1))
fig4_plotrt("SB4RC", introduction_phylo,
            "darkslateblue", "slateblue", FALSE, c(1, 120), c(0, 8), 9, title = "")
par(mar = c(4, 4, 0.1, 1))
fig4_plotrt("SB4RC", introduction_combined,
            "darkolivegreen4", "darkolivegreen3", TRUE, c(1, 120), c(0, 8), 9, title = "")
par(mar = c(0.5, 2, 3, 1))
fig4b_plotrt("SS3OC", sampling_epi,
            "orangered3", "orange", FALSE, c(1, 100), c(0, 4), 4, title = "Step-change in Sampling")
par(mar = c(0.5, 2, 0.1, 1))
fig4b_plotrt("SS3OC", sampling_phylo,
            "darkslateblue", "slateblue", FALSE, c(1, 100), c(0, 4), 4, title = "")
par(mar = c(4, 2, 0.1, 1))
fig4b_plotrt("SS3OC", sampling_combined,
            "darkolivegreen4", "darkolivegreen3", TRUE, c(1, 100), c(0, 4), 4, title = "")
par(mar = c(0.5, 2, 3, 1))
fig4b_plotrt("ST3RC", transmission_epi,
            "orangered3", "orange", FALSE, c(110, 200), c(0, 2), 4, title = "Step-change in Transmission")
par(mar = c(0.5, 2, 0.1, 1))
fig4b_plotrt("ST3RC", transmission_phylo,
            "darkslateblue", "slateblue", FALSE, c(110, 200), c(0, 2), 4, title = "")
par(mar = c(4, 2, 0.1, 1))
fig4b_plotrt("ST3RC", transmission_combined,
            "darkolivegreen4", "darkolivegreen3", TRUE, c(110, 200), c(0, 2), 4, title = "")
dev.off()

#####Figure 5 has to be done manually cause it's messy#####
intro_epi_params <- fig5_getrowentries(introduction_epi, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05), 'Introduction', 'Epi Only', "orange")
intro_phylo_params <- fig5_getrowentries(introduction_phylo, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05), 'Introduction', 'Phylo Only', "slateblue")
intro_combined_params <- fig5_getrowentries(introduction_combined, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05), 'Introduction', 'Combined', "darkolivegreen3")

sampling_epi_params <- fig5_getrowentries(sampling_epi, 0.1, c(0.143, 0.00025, 35, 0.0025, 0.035, 35, 0.35, 0.6,  0.05), 'Sampling', 'Epi Only', "orange")
sampling_phylo_params <- fig5_getrowentries(sampling_phylo, 0.1, c(0.143, 0.00025, 35, 0.0025, 0.035, 35, 0.35, 0.6,  0.05), 'Sampling', 'Phylo Only', "slateblue")
sampling_combined_params <- fig5_getrowentries(sampling_combined, 0.1, c(0.143, 0.00025, 35, 0.0025, 0.035, 35, 0.35, 0.6,  0.05), 'Sampling', 'Combined', "darkolivegreen3")

transmission_epi_params <- fig5_getrowentries(transmission_epi, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05, 1, 150, 2, 500), 'Transmission', 'Epi Only', "orange")
transmission_phylo_params <- fig5_getrowentries(transmission_phylo, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05, 1, 150, 2, 500), 'Transmission', 'Phylo Only', "slateblue")
transmission_combined_params <- fig5_getrowentries(transmission_combined, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05, 1, 150, 2, 500), 'Transmission', 'Combined', "darkolivegreen3")

parameter_combined <- rbind(intro_epi_params, intro_phylo_params, intro_combined_params,
                            sampling_epi_params, sampling_phylo_params, sampling_combined_params,
                            transmission_epi_params, transmission_phylo_params, transmission_combined_params) %>%
  dplyr::filter(Parameter != 'initialBeta') %>%
  dplyr::filter(Parameter != "betaJitter") %>%
  dplyr::filter(Parameter != "initialI") %>%
  dplyr::filter(Parameter != "betaRefactor_distribs_0") %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "betaRefactor_distribs_1", "transmission step-change magnitude")) %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "betaRefactor_changetime_0", "transmission step-change time")) %>%
  dplyr::filter(!str_detect(Parameter, "psi") | Approach != "Epi Only") %>%
  dplyr::filter(!str_detect(Parameter, "phi") | Approach != "Phylo Only") %>%
  dplyr::filter(!str_detect(Parameter, "changetime")) %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "_distribs_0", " initial")) %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "_distribs_1", " final")) %>%
  dplyr::arrange(Parameter) 


approachlist <- c("Introduction", "Sampling", "Transmission")
shapelist <- c( "fpDrawNormalCI","fpDrawDiamondCI", "fpDrawCircleCI")
boxcolors <- list()
shapes <- c()
for (i in 1:nrow(parameter_combined)) {
  boxcolors[[i]] <- gpar(fill = parameter_combined$colour[i], col = NA)
  shapes[i] <- shapelist[match(parameter_combined$Scenario[i], approachlist)]
}
styles <- fpShapesGp(box = boxcolors)
  
pdf("figs/Figure5.pdf", width =6, height = 10)
parameter_combined %>%
  forestplot(labeltext = c(Parameter), 
             fn.ci_norm=shapes, shapes_gp = styles, vertices = TRUE) %>%
  fp_set_zebra_style("#EFEFEF") %>%
  fp_set_style(align = "r")
dev.off()

plot(-1, -1, xlim = c(0, 100), ylim = c(0, 100))
legend(20, 80, title = "Scenario", c("Introduction", "Sampling", "Transmission"),
       pch = c(15, 18, 19), col = "black")
legend(20, 60, title = "Approach", c("Case incidence", "Tree", "Combined"),
      fill = c("orange", "slateblue", "darkolivegreen3"))

#####Figure 6 ST3RC I's#####
pdf("figs/Figure6.pdf", width = 7.5, height = 9)
layout(matrix(c(1,2,3), nrow = 3), heights = c(1,1,1.2))
par(mar = c(0.5, 4, 0.1, 1))
fig6_plottrajectories("ST3RC", transmission_epi,
                      "orangered3", "orange", FALSE, c(120, 210), c(0, 3000))
text(190, 2500, "Case Incidence Only", cex = 2)
fig6_plottrajectories("ST3RC", transmission_phylo,
                      "darkslateblue", "slateblue", FALSE, c(120, 210), c(0, 3000))
text(190, 2500, "Tree Only", cex = 2)
par(mar = c(4, 4, 0.1, 1))
fig6_plottrajectories("ST3RC", transmission_combined,
                      "darkolivegreen4", "darkolivegreen3", TRUE, c(120, 210), c(0, 3000))
text(190, 2500, "Combined Datasets", cex = 2)
dev.off()

######Figure 7 Confidence Interval distributions all three scenarios (trajectory)####
pdf("figs/Figure7.pdf", width = 7.5, height = 3)
layout(matrix(c(1,2,3), nrow = 1), widths = c(1.1,1,1))
par(mar = c(4, 4, 2, 0.5))
fig7_confintervals(c(transmission_epi,
                     transmission_phylo,
                     transmission_combined),
                   c("orangered3", "darkslateblue", "darkolivegreen4"),
                   c("orange", "slateblue", "darkolivegreen3"),
                   c(5,5,5),
                   TRUE,
                   c(200, 1600),
                   c(0, 0.005),
                   "Step Change in Transmission")
par(mar = c(4, 2, 2, 0.5))
fig7_confintervals(c(introduction_epi,
                     introduction_phylo,
                     introduction_combined),
                   c("orangered3", "darkslateblue", "darkolivegreen4"),
                   c("orange", "slateblue", "darkolivegreen3"),
                   c(5,5,5),
                   FALSE,
                   c(0, 2000),
                   c(0, 0.002),
                   "Introduction to New Population")
fig7_confintervals(c(sampling_epi,
                     sampling_phylo,
                     sampling_combined),
                   c("orangered3", "darkslateblue", "darkolivegreen4"),
                   c("orange", "slateblue", "darkolivegreen3"),
                   c(5,5,5),
                   FALSE,
                   c(0, 2000),
                   c(0, 0.002),
                   "Step Change in Sampling")
dev.off()



#####Figure 8 comparison against other methods#####
#Fig8 Introduction on its own
pdf("figs/Figure8intro.pdf", width = 7.5, height = 12)
layout(matrix(c(1,2,3,4), ncol = 1))
par(mar = c(0.5, 4, 3, 1))
fig8_plotrt("SB4RC", introduction_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 120), c(0, 8), 9, title = "Introduction")
text(90, 6, "EpiFusion", cex = 2)
par(mar = c(0.5, 4, 0.1, 1))
fig8_plotEpiNow2("SB4RC", introduction_EpiNow,"deepskyblue3", "deepskyblue", FALSE, c(1, 120), c(0,8), title = "")
text(90, 6, "EpiNow2", cex = 2)
fig8_plotBDSky("SB4RC", introduction_BDSky, c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 98, "firebrick3", "firebrick1", FALSE, c(1, 120), c(0,8), title = "")
text(90, 6, "BDSky", cex = 2)
par(mar = c(4, 4, 0.1, 1))
fig8_plotTimTam("SB4RC", introduction_TimTam, c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16, 0), 98, "goldenrod3", "goldenrod1", TRUE, c(1, 120), c(0,8), title = "")
text(90, 6, "TimTam", cex = 2)
dev.off()

pdf("figs/Figure8sampling.pdf", width = 7.5, height = 12)
layout(matrix(c(1,2,3,4), ncol = 1))
par(mar = c(0.5, 4, 3, 1))
fig8_plotrt("SS3OC", sampling_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 100), c(0, 5), 4, title = "Sampling Scenario")
text(85, 4, "EpiFusion", cex = 2)
par(mar = c(0.5, 4, 0.1, 1))
fig8_plotEpiNow2("SS3OC", sampling_EpiNow,"deepskyblue3", "deepskyblue", FALSE, c(1, 100), c(0,5), title = "")
text(85, 4, "EpiNow2", cex = 2)
fig8_plotBDSky("SS3OC", sampling_BDSky, c(0.29, 0.2575, 0.2192, 0.1973, 0.1767, 0.1562, 0.1342, 0.0932, 0.0521, 0.0), 94, "firebrick3", "firebrick1", FALSE, c(1, 100), c(0,5), title = "")
text(85, 4, "BDSky", cex = 2)
par(mar = c(4, 4, 0.1, 1))
fig8_plotTimTam("SS3OC", sampling_TimTam, c(100, 94.0, 80.0, 72.0, 64.5, 57.0, 49.0, 34.0, 19.0, 0), 94, "goldenrod3", "goldenrod1", TRUE, c(1, 100), c(0,5), title = "")
text(85, 4, "TimTam", cex = 2)
dev.off()

pdf("figs/Figure8transmission.pdf", width = 7.5, height = 12)
layout(matrix(c(1,2,3,4), ncol = 1))
par(mar = c(0.5, 4, 3, 1))
fig8_plotrt("ST3RC", transmission_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(100, 200), c(0, 8), 4, title = "Introduction")
text(170, 6, "EpiFusion", cex = 2)
par(mar = c(0.5, 4, 0.1, 1))
fig8_plotEpiNow2("ST3RC", transmission_EpiNow,"deepskyblue3", "deepskyblue", FALSE, c(100, 200), c(0, 8), title = "")
text(170, 6, "EpiNow2", cex = 2)
fig8_plotBDSky("ST3RC", transmission_BDSky, c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 500, "firebrick3", "firebrick1", FALSE, c(100, 200), c(0,8), title = "")
text(170, 6, "BDSky", cex = 2)
par(mar = c(4, 4, 0.1, 1))
fig8_plotTimTam("ST3RC", transmission_TimTam, c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16, 0), 500, "goldenrod3", "goldenrod1", TRUE, c(100, 200), c(0,8), title = "")
text(170, 6, "TimTam", cex = 2)
dev.off()

pdf("figs/Figure8.pdf", width = 7.5, height = 7)
layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12), nrow = 4, ncol = 3), heights = c(1.2,1,1,1.25), widths = c(1.1, 1,1))
par(mar = c(0.5, 4, 3, 1))
fig8_plotrt("SB4RC", introduction_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 120), c(0, 8), 9, title = "Introduction")
par(mar = c(0.5, 4, 0.1, 1))
fig8_plotEpiNow2("SB4RC", introduction_EpiNow,"deepskyblue3", "deepskyblue", FALSE, c(1, 120), c(0,8), title = "")
fig8_plotBDSky("SB4RC", introduction_BDSky, c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 98, "firebrick3", "firebrick1", FALSE, c(1, 120), c(0,8), title = "")
fig8_plotTimTam("SB4RC", introduction_TimTam, c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16), 98, "goldenrod3", "goldenrod1", TRUE, c(1, 120), c(0,8), title = "")
par(mar = c(0.5, 2, 3, 1))
fig8b_plotrt("SS3OC", sampling_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 100), c(0, 4), 4, title = "Step-change in Sampling")
par(mar = c(0.5, 2, 0.1, 1))
fig8b_plotEpiNow2("SS3OC", sampling_EpiNow,"deepskyblue3", "deepskyblue", FALSE, c(1, 100), c(0, 4), 9, title = "")
fig8b_plotBDSky("SS3OC", sampling_BDSky,"firebrick3", "firebrick1", FALSE, c(1, 100), c(0, 4), 9, title = "")
par(mar = c(4, 2, 0.1, 1))
fig8b_plotEpiInf("SS3OC", "", "goldenrod3", "goldenrod1", TRUE, c(1, 100), c(0, 4), 4, title = "")
par(mar = c(0.5, 2, 3, 1))
fig8b_plotrt("ST3RC", transmission_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(110, 200), c(0, 2), 4, title = "Step-change in Transmission")
par(mar = c(0.5, 2, 0.1, 1))
fig8b_plotEpiNow2("ST3RC", transmission_EpiNow, "deepskyblue3", "deepskyblue", FALSE, c(110, 200), c(0, 2), 4, title = "")
fig8b_plotBDSky("ST3RC", transmission_BDSky, "firebrick3", "firebrick1", FALSE, c(110, 200), c(0, 2), 4, title = "")
par(mar = c(4, 2, 0.1, 1))
fig8b_plotEpiInf("ST3RC", "filename", "goldenrod3", "goldenrod1", TRUE, c(110, 200), c(0, 2), 4, title = "")
dev.off()


#####Table 2####
table2_rtrmse("SB4RC", introduction_epi, 8)
table2_rtrmse("SB4RC", introduction_phylo, 8)
table2_rtrmse("SB4RC", introduction_combined, 8)

table2_rtrmse("ST3RC", transmission_epi, 3)
table2_rtrmse("ST3RC", transmission_phylo, 3)
table2_rtrmse("ST3RC", transmission_combined, 3)

table2_rtrmse("SS3OC", sampling_epi, 4)
table2_rtrmse("SS3OC", sampling_phylo, 4)
table2_rtrmse("SS3OC", sampling_combined, 4)


table2_trajrmse("SB4RC", introduction_epi)
table2_trajrmse("SB4RC", introduction_phylo)
table2_trajrmse("SB4RC", introduction_combined)

table2_trajrmse("ST3RC", transmission_epi)
table2_trajrmse("ST3RC", transmission_phylo)
table2_trajrmse("ST3RC", transmission_combined)

table2_trajrmse("SS3OC", sampling_epi)
table2_trajrmse("SS3OC", sampling_phylo)
table2_trajrmse("SS3OC", sampling_combined)


table2_trajaccuracy1("SB4RC", introduction_epi)
table2_trajaccuracy1("SB4RC", introduction_phylo)
table2_trajaccuracy1("SB4RC", introduction_combined)

table2_trajaccuracy1("ST3RC", transmission_epi)
table2_trajaccuracy1("ST3RC", transmission_phylo)
table2_trajaccuracy1("ST3RC", transmission_combined)

table2_trajaccuracy2("SS3OC", sampling_epi)
table2_trajaccuracy2("SS3OC", sampling_phylo)
table2_trajaccuracy2("SS3OC", sampling_combined)


table2_trajhpd("SB4RC", introduction_epi)
table2_trajhpd("SB4RC", introduction_phylo)
table2_trajhpd("SB4RC", introduction_combined)

table2_trajhpd("ST3RC", transmission_epi)
table2_trajhpd("ST3RC", transmission_phylo)
table2_trajhpd("ST3RC", transmission_combined)

table2_trajhpd("SS3OC", sampling_epi)
table2_trajhpd("SS3OC", sampling_phylo)
table2_trajhpd("SS3OC", sampling_combined)



table2_rthpd("SB4RC", introduction_epi, 8)
table2_rthpd("SB4RC", introduction_phylo, 8)
table2_rthpd("SB4RC", introduction_combined, 8)

table2_rthpd("ST3RC", transmission_epi, 4)
table2_rthpd("ST3RC", transmission_phylo, 4)
table2_rthpd("ST3RC", transmission_combined, 4)

table2_rthpd("SS3OC", sampling_epi, 4)
table2_rthpd("SS3OC", sampling_phylo, 4)
table2_rthpd("SS3OC", sampling_combined, 4)


#table2_rttransmitaccuracy1("SB4RC", introduction_epi, 8)
#table2_rttransmitaccuracy1("SB4RC", introduction_phylo, 8)
#table2_rttransmitaccuracy1("SB4RC", introduction_combined, 8)

#table2_rttransmitaccuracy1("ST3RC", transmission_epi, 4)
#table2_rttransmitaccuracy1("ST3RC", transmission_phylo, 4)
#table2_rttransmitaccuracy1("ST3RC", transmission_combined, 4)

#table2_rttransmitaccuracy2("SS3OC", sampling_epi, 4)
#table2_rttransmitaccuracy1("SS3OC", sampling_phylo, 4)
#table2_rttransmitaccuracy2("SS3OC", sampling_combined, 4)


table2_CRPS("SB4RC", introduction_epi)
table2_CRPS("SB4RC", introduction_phylo)
table2_CRPS("SB4RC", introduction_combined)

table2_CRPS("ST3RC", transmission_epi)
table2_CRPS("ST3RC", transmission_phylo)
table2_CRPS("ST3RC", transmission_combined)

table2_CRPS("SS3OC", sampling_epi)
table2_CRPS("SS3OC", sampling_phylo)
table2_CRPS("SS3OC", sampling_combined)


table2_brierscore("SB4RC", introduction_epi, 8)
table2_brierscore("SB4RC", introduction_phylo, 8)
table2_brierscore("SB4RC", introduction_combined, 8)

table2_brierscore("ST3RC", transmission_epi, 4)
table2_brierscore("ST3RC", transmission_phylo, 4)
table2_brierscore("ST3RC", transmission_combined, 4)

table2_brierscore("SS3OC", sampling_epi, 4)
table2_brierscore("SS3OC", sampling_phylo, 4)
table2_brierscore("SS3OC", sampling_combined, 4)


#####SUPPLEMENTARY#####

#####Supplementary Table Model Results - Validation Stage 1#####
#Intro Scenario
supplementary_table2_valuesandrhat(introduction_epi, 0.1, "gamma")
supplementary_table2_valuesandrhat(introduction_epi, 0.1, "phi")
supplementary_table2_valuesandrhat(introduction_epi, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(introduction_epi, 0.1, "betaJitter")

supplementary_table2_valuesandrhat(introduction_phylo, 0.1, "gamma")
supplementary_table2_valuesandrhat(introduction_phylo, 0.1, "psi")
supplementary_table2_valuesandrhat(introduction_phylo, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(introduction_phylo, 0.1, "betaJitter")

supplementary_table2_valuesandrhat(introduction_combined, 0.1, "gamma")
supplementary_table2_valuesandrhat(introduction_combined, 0.1, "psi")
supplementary_table2_valuesandrhat(introduction_combined, 0.1, "phi")
supplementary_table2_valuesandrhat(introduction_combined, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(introduction_combined, 0.1, "betaJitter")

#Sampling Scenario
supplementary_table2_valuesandrhat(sampling_epi, 0.1, "gamma")
supplementary_table2_valuesandrhat(sampling_epi, 0.1, "phi_distribs_0")
supplementary_table2_valuesandrhat(sampling_epi, 0.1, "phi_distribs_1")
supplementary_table2_valuesandrhat(sampling_epi, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(sampling_epi, 0.1, "betaJitter")

supplementary_table2_valuesandrhat(sampling_phylo, 0.1, "gamma")
supplementary_table2_valuesandrhat(sampling_phylo, 0.1, "psi_distribs_0")
supplementary_table2_valuesandrhat(sampling_phylo, 0.1, "psi_distribs_1")
supplementary_table2_valuesandrhat(sampling_phylo, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(sampling_phylo, 0.1, "betaJitter")

supplementary_table2_valuesandrhat(sampling_combined, 0.1, "gamma")
supplementary_table2_valuesandrhat(sampling_combined, 0.1, "psi_distribs_0")
supplementary_table2_valuesandrhat(sampling_combined, 0.1, "psi_distribs_1")
supplementary_table2_valuesandrhat(sampling_combined, 0.1, "phi_distribs_0")
supplementary_table2_valuesandrhat(sampling_combined, 0.1, "phi_distribs_1")
supplementary_table2_valuesandrhat(sampling_combined, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(sampling_combined, 0.1, "betaJitter")


#Transmission Scenario
supplementary_table2_valuesandrhat(transmission_epi, 0.1, "gamma")
supplementary_table2_valuesandrhat(transmission_epi, 0.1, "phi")
supplementary_table2_valuesandrhat(transmission_epi, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(transmission_epi, 0.1, "betaJitter")
supplementary_table2_valuesandrhat(transmission_epi, 0.1, "betaRefactor_distribs_1")
supplementary_table2_valuesandrhat(transmission_epi, 0.1, "betaRefactor_changetime_0")
supplementary_table2_valuesandrhat(transmission_epi, 0.1, "initialI")

supplementary_table2_valuesandrhat(transmission_phylo, 0.1, "gamma")
supplementary_table2_valuesandrhat(transmission_phylo, 0.1, "psi")
supplementary_table2_valuesandrhat(transmission_phylo, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(transmission_phylo, 0.1, "betaJitter")
supplementary_table2_valuesandrhat(transmission_phylo, 0.1, "betaRefactor_distribs_1")
supplementary_table2_valuesandrhat(transmission_phylo, 0.1, "betaRefactor_changetime_0")
supplementary_table2_valuesandrhat(transmission_phylo, 0.1, "initialI")

supplementary_table2_valuesandrhat(transmission_combined, 0.1, "gamma")
supplementary_table2_valuesandrhat(transmission_combined, 0.1, "psi")
supplementary_table2_valuesandrhat(transmission_combined, 0.1, "phi")
supplementary_table2_valuesandrhat(transmission_combined, 0.1, "initialBeta")
supplementary_table2_valuesandrhat(transmission_combined, 0.1, "betaJitter")
supplementary_table2_valuesandrhat(transmission_combined, 0.1, "betaRefactor_distribs_1")
supplementary_table2_valuesandrhat(transmission_combined, 0.1, "betaRefactor_changetime_0")
supplementary_table2_valuesandrhat(transmission_combined, 0.1, "initialI")






#####Spares#####
#####Figure 5 an earlier draft #####
pdf("figs/Figure5a.pdf", width = 10, height = 3.5)
layout(matrix(c(1,2,3), nrow = 1, byrow = T), widths = c(1.1,1,1))
par(mar = c(4, 4, 2, 1))
plot(-100, -100, xlim = c(0.02, 0.23), ylim = c(0, 35), main = "Gamma", ylab = "Density", xlab = "Value")
fig5_plotparamposterior(introduction_epi,
                        "gamma", 0.143, "orangered3", "orange", FALSE, NA)
fig5_plotparamposterior(introduction_combined,
                        "gamma", 0.143, "darkolivegreen4", "darkolivegreen3", FALSE, NA)
fig5_plotparamposterior(introduction_phylo,
                        "gamma", 0.143, "darkslateblue", "slateblue", TRUE, 32)
par(mar = c(4, 2, 2, 1))
plot(-100, -100, xlim = c(0.0006, 0.0014), ylim = c(0, 5200), main = "Psi", ylab = "", xlab = "Value")
fig5_plotparamposterior(introduction_combined,
                        "psi", 0.001, "darkolivegreen4", "darkolivegreen3", FALSE, 5150)
fig5_plotparamposterior(introduction_phylo,
                        "psi", 0.001, "darkslateblue", "slateblue", TRUE, 5150)
plot(-100, -100, xlim = c(0.08, 0.2), ylim = c(0, 45), main = "Phi", ylab = "", xlab = "Value")
fig5_plotparamposterior(introduction_epi,
                        "phi", 0.14, "orangered3", "orange", FALSE, NA)
fig5_plotparamposterior(introduction_combined,
                        "phi", 0.14, "darkolivegreen4", "darkolivegreen3", TRUE, 45)
dev.off()

pdf("figs/Figure5b.pdf", width = 10, height = 2.5)
layout(matrix(c(1,2,3,4), nrow = 1, byrow = T), widths = c(1.1,1,1,1))
par(mar = c(4, 4, 2, 1))
plot(-100, -100, xlim = c(0.02, 0.23), ylim = c(0, 22), main = "Gamma", ylab = "Density", xlab = "Value")
fig5_plotparamposterior(transmission_epi,
                        "gamma", 0.143, "orangered3", "orange", FALSE, NA)
fig5_plotparamposterior(transmission_combined,
                        "gamma", 0.143, "darkolivegreen4", "darkolivegreen3", FALSE, NA)
fig5_plotparamposterior(transmission_phylo,
                        "gamma", 0.143, "darkslateblue", "slateblue", TRUE, NA)
par(mar = c(4, 2, 2, 1))
plot(-100, -100, xlim = c(0.0006, 0.0014), ylim = c(0, 5200), main = "Psi", ylab = "", xlab = "Value")
fig5_plotparamposterior(transmission_combined,
                        "psi", 0.001, "darkolivegreen4", "darkolivegreen3", FALSE, 5150)
fig5_plotparamposterior(transmission_phylo,
                        "psi", 0.001, "darkslateblue", "slateblue", TRUE, 5150)
plot(-100, -100, xlim = c(0.08, 0.2), ylim = c(0, 32), main = "Phi", ylab = "", xlab = "Value")
fig5_plotparamposterior(transmission_epi,
                        "phi", 0.14, "orangered3", "orange", FALSE, NA)
fig5_plotparamposterior(transmission_combined,
                        "phi", 0.14, "darkolivegreen4", "darkolivegreen3", TRUE, 30)
plot(-100, -100, xlim = c(125, 180), ylim = c(0, 0.09), main = "Transmission Step Change Time", ylab = "",  xlab = "Value")
fig5_plotparamposterior(transmission_epi,
                        "betaRefactor_changetime_0", 150, "orangered3", "orange", FALSE, NA)
fig5_plotparamposterior(transmission_combined,
                        "betaRefactor_changetime_0", 150, "darkolivegreen4", "darkolivegreen3", FALSE, NA)
fig5_plotparamposterior(transmission_phylo,
                        "betaRefactor_changetime_0", 150, "darkslateblue", "slateblue", TRUE, 0.08)
dev.off()
#####Figure 8 Confidence Interval distributions all three scenarios (Rt)#####
png("/Users/ciarajudge/Desktop/PhD/Publication1/figs/Figure8Rt.png", width = 720, height = 288)
layout(matrix(c(1,2,3), nrow = 1), widths = c(1.1,1,1))
par(mar = c(4, 4, 2, 0.5))
fig8_confintervals_rt(c("/Users/ciarajudge/Desktop/PhD/Publication1/finalfits/ST3RC_EpiOnly_200Particles_50000Steps_AnalysisType1_AAADM/",
                        "/Users/ciarajudge/Desktop/PhD/Publication1/finalfits/ST3RC_PhyloOnly_200Particles_50000Steps_AnalysisType1_AAADN/",
                        "/Users/ciarajudge/Desktop/PhD/Publication1/finalfits/ST3RC_Combined_200Particles_50000Steps_AnalysisType1_AAADL/"),
                      c("orangered3", "darkslateblue", "darkolivegreen4"),
                      c("orange", "slateblue", "darkolivegreen3"),
                      c(5,5,5),
                      TRUE,
                      c(0, 0.8),
                      c(0, 9),
                      "Step Change in Transmission")
par(mar = c(4, 2, 2, 0.5))
fig8_confintervals_rt(c("/Users/ciarajudge/Desktop/PhD/Publication1/finalfits/SB4RC_EpiOnly_200Particles_50000Steps_AnalysisType1_AAADP/",
                        introduction_phylo,
                        introduction_combined),
                      c("orangered3", "darkslateblue", "darkolivegreen4"),
                      c("orange", "slateblue", "darkolivegreen3"),
                      c(8,8,8),
                      FALSE,
                      c(0, 7),
                      c(0, 1),
                      "Introduction to New Population")
fig8_confintervals_rt(c("/Users/ciarajudge/Desktop/PhD/Publication1/finalfits/SS3OC_EpiOnly_200Particles_50000Steps_AnalysisType1_AAAEA/",
                        "/Users/ciarajudge/Desktop/PhD/Publication1/finalfits/SS3OC_PhyloOnly_200Particles_50000Steps_AnalysisType1_AAAEC/",
                        "/Users/ciarajudge/Desktop/PhD/EpiFusionResults/SS3OC_Combined_300Particles_50000Steps_AnalysisType1_AAAEG/"),
                      c("orangered3", "darkslateblue", "darkolivegreen4"),
                      c("orange", "slateblue", "darkolivegreen3"),
                      c(5,5,5),
                      FALSE,
                      c(0, 9),
                      c(0, 1),
                      "Step Change in Sampling")
dev.off()
