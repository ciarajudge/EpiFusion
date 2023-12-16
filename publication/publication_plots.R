setwd("/Users/ciarajudge/Desktop/PhD/EpiFusion/publication/")
source("publication_plots_utilities.R")

introduction_epi <- "model_results/introduction_epi/"
introduction_phylo <- "model_results/introduction_phylo/"
introduction_combined <- "model_results/introduction_combined/"

sampling_epi <- "model_results/sampling_epi/"
sampling_phylo <- "model_results/sampling_phylo/"
sampling_combined <- "model_results/sampling_combo/"

transmission_epi <- "model_results/transmission_epi/"
transmission_phylo <- "model_results/transmission_phylo/"
transmission_combined <- "model_results/transmission_combo/"

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
pdf("figs/Figure2.pdf", width = 7.5, height = 5.5)
layout(matrix(c(1,2,3,2), nrow = 2, ncol = 2, byrow = T))
par(mar = c(0.5, 4, 0.1, 1))
fig2_plottruth("SB4RC", c(1,120))
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("SB4RC", c(1, 120))
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("SB4RC", c(1, 120))
dev.off()

#bc
pdf("figs/SupplementaryFigure2bc.pdf", width = 7.5, height = 3.5)
layout(matrix(c(1,2,3,4,5,2,6,4), nrow = 2, ncol = 4, byrow = T))
par(mar = c(0.5, 4, 0.1, 1))
fig2_plottruth("SS3OC", c(1,100))
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("SS3OC", c(1,100))
par(mar = c(0.5, 4, 0.1, 1))
fig2_plottruth("ST3RC", c(1,500))
polygon(c(100, 100, 200, 200), c(-1000, 7000, 7000, -1000), col = adjustcolor('yellow', 0.3), border = NA)
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("ST3RC", c(1,500))
polygon(c(100, 100, 200, 200), c(-1000, 7000, 7000, -1000), col = adjustcolor('yellow', 0.3), border = NA)
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("SS3OC", c(1,100))
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("ST3RC", c(1,500))
polygon(c(100, 100, 200, 200), c(-1000, 7000, 7000, -1000), col = adjustcolor('yellow', 0.3), border = NA)
dev.off()


#####Figure 3 Infection trajectories#####
pdf("figs/Figure3.pdf", width = 7.5, height = 7)
layout(matrix(c(1,2,3,4,5,6,7,8,9), nrow = 3, ncol = 3), heights = c(1.2,1,1.2), widths = c(1.1, 1,1))
par(mar = c(0.5, 4, 3, 1))
fig3_plottrajectories("SB4RC", introduction_epi,
                      "orangered3", "orange", FALSE, c(0, 120), c(0, 5000), "Introduction Scenario")
par(mar = c(0.5, 4, 0.1, 1))
fig3_plottrajectories("SB4RC", introduction_phylo,
                      "darkslateblue", "slateblue", FALSE, c(0, 120), c(0, 5000), "")
par(mar = c(4, 4, 0.1, 1))
fig3_plottrajectories("SB4RC", introduction_combined,
                      "darkolivegreen4", "darkolivegreen3", TRUE, c(0, 120), c(0, 5000), "")
par(mar = c(0.5, 2, 3, 1))
fig5b_plottrajectories("SS3OC", sampling_epi,
                      "orangered3", "orange", FALSE, c(0, 100), c(0, 6500), "Step-Change in Sampling")
lines(c(35, 35), c(-10000, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 0.1, 1))
fig5b_plottrajectories("SS3OC", sampling_phylo,
                      "darkslateblue", "slateblue", FALSE, c(0, 100), c(0, 6500), "")
lines(c(35, 35), c(-10000, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(4, 2, 0.1, 1))
fig5b_plottrajectories("SS3OC", sampling_combined,
                      "darkolivegreen4", "darkolivegreen3", TRUE, c(0, 100), c(0, 6500), "")
lines(c(35, 35), c(-10000, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 3, 1))
fig5b_plottrajectories("ST3RC", transmission_epi,
                       "orangered3", "orange", FALSE, c(120, 210), c(0, 3000), "Step-Change in Transmission")
lines(c(150, 150), c(-10000, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 0.1, 1))
fig5b_plottrajectories("ST3RC", transmission_phylo,
                       "darkslateblue", "slateblue", FALSE, c(120, 210), c(0, 3000), "")
lines(c(150, 150), c(-10000, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(4, 2, 0.1, 1))
fig5b_plottrajectories("ST3RC", transmission_combined,
                       "darkolivegreen4", "darkolivegreen3", TRUE, c(120, 210), c(0, 3000), "")
lines(c(150, 150), c(-10000, 10000), col = "black", lwd = 1, lty = 3)
legend(160, 700, c("Case incidence", "Tree", "Combined"),
       fill = c("orange", "slateblue", "darkolivegreen3"))
dev.off()


#####Figure 4 R 3x3 Matrix#####
pdf("figs/Figure4.pdf", width = 7.5, height = 7)
layout(matrix(c(1,2,3,4,5,6,7,8,9), nrow = 3, ncol = 3), heights = c(1.2,1,1.2), widths = c(1.1, 1,1))
par(mar = c(0.5, 4, 3, 1))
fig4_plotrt("SB4RC", introduction_epi,
            "orangered3", "orange", FALSE, c(1, 100), c(0.1, 5), title = "Introduction")
par(mar = c(0.5, 4, 0.1, 1))
fig4_plotrt("SB4RC", introduction_phylo,
            "darkslateblue", "slateblue", FALSE, c(1, 100), c(0.1, 5), title = "")
par(mar = c(4, 4, 0.1, 1))
fig4_plotrt("SB4RC", introduction_combined,
            "darkolivegreen4", "darkolivegreen3", TRUE, c(1, 100), c(0.1, 5),  title = "")
legend(10, 0.4, c("Case incidence", "Tree", "Combined"),
       fill = c("orange", "slateblue", "darkolivegreen3"))
par(mar = c(0.5, 2, 3, 1))
fig4b_plotrt("SS3OC", sampling_epi,
            "orangered3", "orange", FALSE, c(1, 100), c(0.1, 4), title = "Step-change in Sampling")
lines(c(35, 35), c(0.001, 10), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 0.1, 1))
fig4b_plotrt("SS3OC", sampling_phylo,
            "darkslateblue", "slateblue", FALSE, c(1, 100), c(0.1, 4), title = "")
lines(c(35, 35), c(0.001, 10), col = "black", lwd = 1, lty = 3)
par(mar = c(4, 2, 0.1, 1))
fig4b_plotrt("SS3OC", sampling_combined,
            "darkolivegreen4", "darkolivegreen3", TRUE, c(1, 100), c(0.1, 4), title = "")
lines(c(35, 35), c(0.001, 10), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 3, 1))
fig4b_plotrt("ST3RC", transmission_epi,
            "orangered3", "orange", FALSE, c(110, 200), c(0.1, 3),  title = "Step-change in Transmission")
lines(c(150, 150), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 0.1, 1))
fig4b_plotrt("ST3RC", transmission_phylo,
            "darkslateblue", "slateblue", FALSE, c(110, 200), c(0.1, 3), title = "")
lines(c(150, 150), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(4, 2, 0.1, 1))
fig4b_plotrt("ST3RC", transmission_combined,
            "darkolivegreen4", "darkolivegreen3", TRUE, c(110, 200), c(0.1, 3),  title = "")
lines(c(150, 150), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
dev.off()

#####Figure 5 has to be done manually cause it's messy#####
intro_epi_params <- fig6_getrowentries(introduction_epi, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05), 'Introduction', 'Epi Only', "orange")
intro_phylo_params <- fig6_getrowentries(introduction_phylo, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05), 'Introduction', 'Phylo Only', "slateblue")
intro_combined_params <- fig6_getrowentries(introduction_combined, 0.1, c(0.143, 0.001, 0.14, 0.6, 0.05), 'Introduction', 'Combined', "darkolivegreen3")

sampling_epi_params <- fig6_getrowentries(sampling_epi, 0.1, c(0.143, 0.00025, 35, 0.0025, 0.005, 35, 0.05, 0.6,  0.05), 'Sampling', 'Epi Only', "orange")
sampling_phylo_params <- fig6_getrowentries(sampling_phylo, 0.1, c(0.143, 0.00025, 35, 0.0025, 0.005, 35, 0.05, 0.6,  0.05), 'Sampling', 'Phylo Only', "slateblue")
sampling_combined_params <- fig6_getrowentries(sampling_combined, 0.1, c(0.143, 0.00025, 35, 0.0025, 0.005, 35, 0.05, 0.6,  0.05), 'Sampling', 'Combined', "darkolivegreen3")

transmission_epi_params <- fig6_getrowentries(transmission_epi, 0.1, c(0.143, 0.001, 0.02, 0.6, 0.05, 1, 150, 2, 500), 'Transmission', 'Epi Only', "orange")
transmission_phylo_params <- fig6_getrowentries(transmission_phylo, 0.1, c(0.143, 0.001, 0.02, 0.6, 0.05, 1, 150, 2, 500), 'Transmission', 'Phylo Only', "slateblue")
transmission_combined_params <- fig6_getrowentries(transmission_combined, 0.1, c(0.143, 0.001, 0.02, 0.6, 0.05, 1, 150, 2, 500), 'Transmission', 'Combined', "darkolivegreen3")

parameter_combined <- rbind(intro_epi_params, intro_phylo_params, intro_combined_params, 
                            sampling_epi_params, sampling_phylo_params, sampling_combined_params,
                            transmission_epi_params, transmission_phylo_params, transmission_combined_params) %>%
  dplyr::filter(Parameter != 'initialBeta') %>%
  dplyr::filter(Parameter != "betaJitter") %>%
  dplyr::filter(Parameter != "initialI") %>%
  dplyr::filter(Parameter != "betaRefactor_distribs_0") %>%
  dplyr::filter(Parameter != "a") %>%
  dplyr::filter(Parameter != "b") %>%
  dplyr::filter(Parameter != "c") %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "betaRefactor_distribs_1", "transmission step-change magnitude")) %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "betaRefactor_changetime_0", "transmission step-change time")) %>%
  dplyr::filter(!str_detect(Parameter, "psi") | Approach != "Epi Only") %>%
  dplyr::filter(!str_detect(Parameter, "phi") | Approach != "Phylo Only") %>%
  dplyr::filter(!str_detect(Parameter, "changetime")) %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "_distribs_0", " initial")) %>%
  dplyr::mutate(Parameter = str_replace(Parameter, "_distribs_1", " final")) %>%
  dplyr::arrange(Parameter) 


pdf("figs/Figure5.pdf", width =6, height = 10)
introduction <- dplyr::filter(parameter_combined, Scenario == 'Introduction')
introduction$Identifier <- factor(introduction$Identifier, levels = unique(introduction$Identifier))
layout(matrix(c(1,2,3), nrow = 3 ), heights = c(1,1.5,1.7))
par(mar = c(2, 11, 2 ,1))
vioplot(introduction$Value ~ introduction$Identifier, horizontal = TRUE, 
        main = 'Introduction', rectCol = NA, colMed = 'black', las = 1,
        ylab = "", xlab = "",
        col = c('orange', 'slateblue', 'darkolivegreen3',
                'orange', 'darkolivegreen3',
                'slateblue', 'darkolivegreen3'),
        at = c(1,2,3,5,6,8,9),
        ylim = c(-1, 1), 
        names = c(rep(expression(gamma), 3), rep(expression(phi), 2), rep(expression(psi), 2)))


sampling <- dplyr::filter(parameter_combined, Scenario == 'Sampling')
sampling$Identifier <- factor(sampling$Identifier, levels = unique(sampling$Identifier))
vioplot(sampling$Value ~ sampling$Identifier, horizontal = TRUE, 
        main = 'Step-Change in Sampling', rectCol = NA, colMed = 'black', las = 1,
        ylab = "", xlab = "",
        col = c('orange', 'slateblue', 'darkolivegreen3',
                'orange', 'darkolivegreen3', 'orange', 'darkolivegreen3',
                'slateblue', 'darkolivegreen3', 'slateblue', 'darkolivegreen3'),
        at = c(1,2,3,5,6,8,9,11,12,14,15),
        ylim = c(-1, 1),
        names = c(rep(expression(gamma), 3), rep(expression(paste("final ",phi)), 2), rep(expression(paste("initial ",phi)), 2),
                  rep(expression(paste("final ",psi)), 2), rep(expression(paste("initial ",psi)), 2)))

par(mar = c(4,11, 2,1))
transmission <- dplyr::filter(parameter_combined, Scenario == 'Transmission')
transmission$Identifier <- factor(transmission$Identifier, levels = unique(transmission$Identifier))
vioplot(transmission$Value ~ transmission$Identifier, horizontal = TRUE, 
        main = 'Step-Change in Transmission',rectCol = NA, colMed = 'black', las = 1,
        ylab = "", xlab = "Values scaled by Truth",
        col = c('orange', 'slateblue', 'darkolivegreen3',
                'orange', 'darkolivegreen3', 'slateblue', 'darkolivegreen3',
                'orange', 'slateblue', 'darkolivegreen3',
                'orange', 'slateblue', 'darkolivegreen3'),
        at = c(1,2,3,5,6,8,9,11,12,13,15,16,17),
        ylim = c(-1, 1),
        names = c(rep(expression(gamma), 3), rep(expression(phi), 2), rep(expression(psi), 2),
                  rep("step-change magnitude", 3), rep("step-change time", 3)))
dev.off()

plot(-1, -1, xlim = c(0, 100), ylim = c(0, 100))
legend(20, 80, title = "Scenario", c("Introduction", "Sampling", "Transmission"),
       pch = c(15, 18, 19), col = "black")
legend(20, 60, title = "Approach", c("Case incidence", "Tree", "Combined"),
      fill = c("orange", "slateblue", "darkolivegreen3"))



#####Figure 7 comparison against other methods#####
pdf("figs/Figure6.pdf", width = 7.5, height = 7)
layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12), nrow = 4, ncol = 3), heights = c(1.2,1,1,1.25), widths = c(1.15, 1,1))
par(mar = c(0.5, 4, 3, 1))
fig8_plotrt("SB4RC", introduction_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 100), c(0.1, 5), title = "Introduction")
par(mar = c(0.5, 4, 0.1, 1))
fig8_plotEpiNow2("SB4RC", introduction_EpiNow,"deepskyblue3", "deepskyblue", FALSE, c(1, 100), c(0.1,5), title = "")
fig8_plotBDSky("SB4RC", introduction_BDSky, c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 98, "firebrick3", "firebrick1", FALSE, c(1, 100), c(0.1, 5), title = "")
par(mar = c(4, 4, 0.1, 1))
fig8_plotTimTam("SB4RC", introduction_TimTam, c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16, 0), 98, "goldenrod3", "goldenrod1", TRUE, c(1, 100), c(0.1, 5), title = "")
par(mar = c(0.5, 2, 3, 1))
fig8b_plotrt("SS3OC", sampling_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 100), c(0.1, 5), title = "Sampling Scenario")
lines(c(35, 35), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 0.1, 1))
fig8b_plotEpiNow2("SS3OC", sampling_EpiNow,"deepskyblue3", "deepskyblue", FALSE, c(1, 100), c(0.1, 5), title = "")
lines(c(35, 35), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
fig8b_plotBDSky("SS3OC", sampling_BDSky, c(0.29, 0.2575, 0.2192, 0.1973, 0.1767, 0.1562, 0.1342, 0.0932, 0.0521, 0.0), 94, "firebrick3", "firebrick1", FALSE, c(1, 100), c(0.1, 5), title = "")
lines(c(35, 35), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(4, 2, 0.1, 1))
fig8b_plotTimTam("SS3OC", sampling_TimTam, c(100, 94.0, 80.0, 72.0, 64.5, 57.0, 49.0, 34.0, 19.0, 0), 94, "goldenrod3", "goldenrod1", TRUE, c(1, 100), c(0.1, 5), title = "")
lines(c(35, 35), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
par(mar = c(0.5, 2, 3, 1))
fig8b_plotrt("ST3RC", transmission_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(110, 200), c(0.5, 2.5), title = "Transmission")
lines(c(150, 150), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
text(180, 1.75, "EpiFusion", cex = 1)
par(mar = c(0.5, 2, 0.1, 1))
fig8b_plotEpiNow2("ST3RC", transmission_EpiNow,"deepskyblue3", "deepskyblue", FALSE,  c(110, 200), c(0.5, 2.5),  title = "")
lines(c(150, 150), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
text(180, 1.75, "EpiNow2", cex = 1)
fig8b_plotBDSky("ST3RC", transmission_BDSky, c(2, 1.09, 1.05, 1.01, 0.98, 0.959, 0.93, 0.87, 0.82, 0.5, 0.0), 500, "firebrick3", "firebrick1", FALSE,  c(110, 200), c(0.5, 2.5),  title = "")
lines(c(150, 150), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
text(180, 1.75, "BDSky", cex = 1)
par(mar = c(4, 2, 0.1, 1))
fig8b_plotTimTam("ST3RC", transmission_TimTam, c(450, 400, 383, 369, 358, 350, 339, 318, 300, 0), 500, "goldenrod3", "goldenrod1", TRUE,  c(110, 200), c(0.5, 2.5), title = "")
lines(c(150, 150), c(0.001, 10000), col = "black", lwd = 1, lty = 3)
text(180, 1.75, "TimTam", cex = 1)
dev.off()



#####Table 2####
table2_trajrmse("SB4RC", introduction_epi)
table2_trajrmse("SB4RC", introduction_phylo)
table2_trajrmse("SB4RC", introduction_combined)

table2_trajaccuracy1("SB4RC", introduction_epi)
table2_trajaccuracy1("SB4RC", introduction_phylo)
table2_trajaccuracy1("SB4RC", introduction_combined)

table2_trajhpd("SB4RC", introduction_epi)
table2_trajhpd("SB4RC", introduction_phylo)
table2_trajhpd("SB4RC", introduction_combined)

table2_rtrmse("SB4RC", introduction_epi, 10, 98)
table2_rtrmse("SB4RC", introduction_phylo, 10, 98)
table2_rtrmse("SB4RC", introduction_combined, 10, 98)

table2_rthpd_coverage("SB4RC", introduction_epi, 10, 98)
table2_rthpd_coverage("SB4RC", introduction_phylo, 10, 98)
table2_rthpd_coverage("SB4RC", introduction_combined, 10, 98)

table2_rthpd("SB4RC", introduction_epi, 2, 98)
table2_rthpd("SB4RC", introduction_phylo, 2, 98)
table2_rthpd("SB4RC", introduction_combined, 2, 98)

table2_CRPS("SB4RC", introduction_epi)
table2_CRPS("SB4RC", introduction_phylo)
table2_CRPS("SB4RC", introduction_combined)

table2_rt_CRPS("SB4RC", introduction_epi)
table2_rt_CRPS("SB4RC", introduction_phylo)
table2_rt_CRPS("SB4RC", introduction_combined)

table2_brierscore("SB4RC", introduction_epi, 2, 98)
table2_brierscore("SB4RC", introduction_phylo, 2, 98)
table2_brierscore("SB4RC", introduction_combined, 2, 98)

#Sampling Scenario
table2_trajrmse("SS3OC", sampling_epi)
table2_trajrmse("SS3OC", sampling_phylo)
table2_trajrmse("SS3OC", sampling_combined)

table2_trajaccuracy2("SS3OC", sampling_epi)
table2_trajaccuracy2("SS3OC", sampling_phylo)
table2_trajaccuracy2("SS3OC", sampling_combined)

table2_trajhpd("SS3OC", sampling_epi)
table2_trajhpd("SS3OC", sampling_phylo)
table2_trajhpd("SS3OC", sampling_combined)

table2_rtrmse("SS3OC", sampling_epi, 5, 80)
table2_rtrmse("SS3OC", sampling_phylo, 5, 80)
table2_rtrmse("SS3OC", sampling_combined, 5, 80)

table2_rthpd_coverage("SS3OC", sampling_epi, 5, 80)
table2_rthpd_coverage("SS3OC", sampling_phylo, 5, 80)
table2_rthpd_coverage("SS3OC", sampling_combined, 5, 80)

table2_rthpd("SS3OC", sampling_epi, 5, 80)
table2_rthpd("SS3OC", sampling_phylo, 5, 80)
table2_rthpd("SS3OC", sampling_combined, 5, 80)

table2_CRPS("SS3OC", sampling_epi)
table2_CRPS("SS3OC", sampling_phylo)
table2_CRPS("SS3OC", sampling_combined)

table2_rt_CRPS("SS3OC", sampling_epi)
table2_rt_CRPS("SS3OC", sampling_phylo)
table2_rt_CRPS("SS3OC", sampling_combined)

table2_brierscore("SS3OC", sampling_epi, 5, 93)
table2_brierscore("SS3OC", sampling_phylo, 5, 93)
table2_brierscore("SS3OC", sampling_combined, 5, 93)

#Transmission Scenario
table2_trajrmse("ST3RC", transmission_epi)
table2_trajrmse("ST3RC", transmission_phylo)
table2_trajrmse("ST3RC", transmission_combined)

table2_trajaccuracy1("ST3RC", transmission_epi)
table2_trajaccuracy1("ST3RC", transmission_phylo)
table2_trajaccuracy1("ST3RC", transmission_combined)

table2_trajhpd("ST3RC", transmission_epi)
table2_trajhpd("ST3RC", transmission_phylo)
table2_trajhpd("ST3RC", transmission_combined)

table2_rtrmse("ST3RC", transmission_epi, 2, 150)
table2_rtrmse("ST3RC", transmission_phylo, 2, 150)
table2_rtrmse("ST3RC", transmission_combined, 2, 150)

table2_rthpd_coverage("ST3RC", transmission_epi, 2, 150)
table2_rthpd_coverage("ST3RC", transmission_phylo, 2, 150)
table2_rthpd_coverage("ST3RC", transmission_combined, 2, 150)

table2_rthpd("ST3RC", transmission_epi, 2, 150)
table2_rthpd("ST3RC", transmission_phylo, 2, 150)
table2_rthpd("ST3RC", transmission_combined, 2, 150)

table2_CRPS("ST3RC", transmission_epi)
table2_CRPS("ST3RC", transmission_phylo)
table2_CRPS("ST3RC", transmission_combined)

table2_rt_CRPS("ST3RC", transmission_epi)
table2_rt_CRPS("ST3RC", transmission_phylo)
table2_rt_CRPS("ST3RC", transmission_combined)

table2_brierscore("ST3RC", transmission_epi, 2, 150)
table2_brierscore("ST3RC", transmission_phylo, 2, 150)
table2_brierscore("ST3RC", transmission_combined, 2, 150)


#####Table 3#####
#Introduction Scenario
table2_rtrmse("SB4RC", introduction_combined, 7, 120)
table3_epinow2_rtrmse("SB4RC", introduction_EpiNow, 1, 113)
table3_BDSky_rtrmse("SB4RC", introduction_BDSky, c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 98, 2, 98)
table3_TimTam_rtrmse("SB4RC", introduction_TimTam, c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16, 0), 98, 2, 98)

table3_EpiFusion_CRPS("SB4RC", introduction_combined, 7, 120)
table3_epinow2_CRPS("SB4RC", introduction_EpiNow, 1, 113)
table3_BDSky_CRPS("SB4RC", "benchmarking/introduction_bdsky_samples.tab", c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 98, 2, 98)
table3_TimTam_CRPS("SB4RC", "benchmarking/introduction_TimTam_samples.tab", c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16, 0), 98, 2, 98)

table2_brierscore("SB4RC", introduction_combined, 7, 120)
table3_epinow2_brier("SB4RC", introduction_EpiNow, 1, 113)
table3_BDSky_brier("SB4RC", "benchmarking/introduction_bdsky_samples.tab", c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 98, 2, 97)
table3_TimTam_brier("SB4RC", "benchmarking/introduction_TimTam_samples.tab", c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16, 0), 98, 2, 97)

table2_rthpd_coverage("SB4RC", introduction_combined, 7, 120)
table3_epinow2_coverage("SB4RC", introduction_EpiNow, 1, 113)
table3_BDSky_coverage("SB4RC", introduction_BDSky, c(0.3, 0.2685, 0.2411, 0.2137, 0.1863, 0.1644, 0.1397, 0.1151, 0.0932, 0.0438, 0), 98, 2, 97)
table3_TimTam_coverage("SB4RC", introduction_TimTam, c(100, 98, 88, 78, 68, 60, 51, 42, 34, 16, 0), 98, 2, 97)


#Sampling Scenario
table2_rtrmse("SS3OC", sampling_combined, 7, 100)
table3_epinow2_rtrmse("SS3OC", sampling_EpiNow, 1, 93)
table3_BDSky_rtrmse("SS3OC", sampling_BDSky, c(0.29, 0.2575, 0.2192, 0.1973, 0.1767, 0.1562, 0.1342, 0.0932, 0.0521, 0.0), 94, 2, 93)
table3_TimTam_rtrmse("SS3OC", sampling_TimTam, c(100, 94.0, 80.0, 72.0, 64.5, 57.0, 49.0, 34.0, 19.0, 0), 94, 2, 93)

table3_EpiFusion_CRPS("SS3OC", sampling_combined, 7, 100)
table3_epinow2_CRPS("SS3OC", sampling_EpiNow, 1, 93)
table3_BDSky_CRPS("SS3OC", "benchmarking/sampling_BDSky_samples.tab", c(0.29, 0.2575, 0.2192, 0.1973, 0.1767, 0.1562, 0.1342, 0.0932, 0.0521, 0.0), 94, 2, 93)
table3_TimTam_CRPS("SS3OC", "benchmarking/sampling_TimTam_samples.tab", c(100, 94.0, 80.0, 72.0, 64.5, 57.0, 49.0, 34.0, 19.0, 0), 94, 2, 93)

table2_brierscore("SS3OC", sampling_combined, 7, 100)
table3_epinow2_brier("SS3OC", sampling_EpiNow, 1, 93)
table3_BDSky_brier("SS3OC", "benchmarking/sampling_BDSky_samples.tab", c(0.29, 0.2575, 0.2192, 0.1973, 0.1767, 0.1562, 0.1342, 0.0932, 0.0521, 0.0), 94, 2, 93)
table3_TimTam_brier("SS3OC", "benchmarking/sampling_TimTam_samples.tab", c(100, 94.0, 80.0, 72.0, 64.5, 57.0, 49.0, 34.0, 19.0, 0), 94, 2, 93)

table2_rthpd_coverage("SS3OC", sampling_combined, 7, 100)
table3_epinow2_coverage("SS3OC", sampling_EpiNow, 1, 93)
table3_BDSky_coverage("SS3OC", sampling_BDSky, c(0.29, 0.2575, 0.2192, 0.1973, 0.1767, 0.1562, 0.1342, 0.0932, 0.0521, 0.0), 94, 2, 92)
table3_TimTam_coverage("SS3OC", sampling_TimTam, c(100, 94.0, 80.0, 72.0, 64.5, 57.0, 49.0, 34.0, 19.0, 0), 94, 2, 92)

#Transmission Scenario
table2_rtrmse("ST3RC", transmission_combined, 2, 152)
table3_epinow2_rtrmse("ST3RC", transmission_EpiNow, 93, 243)
table3_BDSky_rtrmse("ST3RC", transmission_BDSky, c(2, 1.09, 1.05, 1.01, 0.98, 0.959, 0.93, 0.87, 0.82, 0.5, 0.0), 500, 100, 250)
table3_TimTam_rtrmse("ST3RC", transmission_TimTam, c(450, 400, 383, 369, 358, 350, 339, 318, 300, 0), 500, 100, 250)

table3_EpiFusion_CRPS("ST3RC", transmission_combined, 2, 152)
table3_epinow2_CRPS("ST3RC", transmission_EpiNow, 93, 243)
table3_BDSky_CRPS("ST3RC", "benchmarking/transmission_BDSky_samples.tab", c(2, 1.09, 1.05, 1.01, 0.98, 0.959, 0.93, 0.87, 0.82, 0.5, 0.0), 500, 100, 250)
table3_TimTam_CRPS("ST3RC", "benchmarking/transmission_TimTam_samples.tab", c(450, 400, 383, 369, 358, 350, 339, 318, 300, 0), 500, 100, 250)

table2_brierscore("ST3RC", transmission_combined, 2, 152)
table3_epinow2_brier("ST3RC", transmission_EpiNow, 93, 243)
table3_BDSky_brier("ST3RC", "benchmarking/transmission_BDSky_samples.tab", c(2, 1.09, 1.05, 1.01, 0.98, 0.959, 0.93, 0.87, 0.82, 0.5, 0.0), 500, 100, 250)
table3_TimTam_brier("ST3RC", "benchmarking/transmission_TimTam_samples.tab", c(450, 400, 383, 369, 358, 350, 339, 318, 300, 0), 500, 100, 250)

table2_rthpd_coverage("ST3RC", transmission_combined, 2, 152)
table3_epinow2_coverage("ST3RC", transmission_EpiNow, 93, 243)
table3_BDSky_coverage("ST3RC", transmission_BDSky, c(2, 1.09, 1.05, 1.01, 0.98, 0.959, 0.93, 0.87, 0.82, 0.5, 0.0), 500, 100, 200)
table3_TimTam_coverage("ST3RC", transmission_TimTam, c(450, 400, 383, 369, 358, 350, 339, 318, 300, 0), 500, 100, 200)



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



