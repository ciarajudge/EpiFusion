setwd("/Users/ciarajudge/Desktop/PhD/EpiFusion/publication/")
source("publication_plots_utilities.R")

introduction_epi <- "model_results/SB4RC_EpiOnly_200Particles_50000Steps_AnalysisType1_AAADP/"
introduction_phylo <- "model_results/SB4RC_PhyloOnly_200Particles_10000Steps_AnalysisType1_placeholder/"
introduction_combined <- "model_results/SB4RC_Combined_200Particles_50000Steps_AnalysisType1_AAAED/"

sampling_epi <- "model_results/SS3OC_EpiOnly_200Particles_50000Steps_AnalysisType1_AAAEA/"
sampling_phylo <- "model_results/SS3OC_PhyloOnly_200Particles_50000Steps_AnalysisType1_AAAEC/"
sampling_combined <- "model_results/SS3OC_Combined_300Particles_50000Steps_AnalysisType1_AAAEG/"

transmission_epi <- "model_results/ST3RC_EpiOnly_200Particles_50000Steps_AnalysisType1_AAADM/"
transmission_phylo <- "model_results/ST3RC_PhyloOnly_200Particles_50000Steps_AnalysisType1_AAADN/"
transmission_combined <- "/Users/ciarajudge/Desktop/PhD/EpiFusionResults/ST3RC_Combined_100Particles_10000Steps_AnalysisType1_2023-10-30_13-40-44/"

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
fig2_plottruth("ST3RC")
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("ST3RC")
par(mar = c(0.5, 4, 0.1, 1))
fig2_plottruth("SS3OC")
par(mar = c(4, 0.1, 0.1, 1))
fig2_plottree("SS3OC")
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("ST3RC")
par(mar = c(4, 4, 0.1, 1))
fig2_plotweeklyincidence("SS3OC")
dev.off()


#####Figure 3 Introduction I's#####
pdf("figs/Figure3.pdf", width = 7.5, height = 9)
layout(matrix(c(1,2,3), nrow = 3), heights = c(1,1,1.2))
par(mar = c(0.5, 4, 0.1, 1))
fig3_plottrajectories("SB4RC", introduction_epi,
                      "orangered3", "orange", FALSE, c(0, 120), c(0, 5000))
fig3_plottrajectories("SB4RC", introduction_phylo,
                      "darkslateblue", "slateblue", FALSE, c(0, 120), c(0, 5000))
par(mar = c(4, 4, 0.1, 1))
fig3_plottrajectories("SB4RC", introduction_combined,
                      "darkolivegreen4", "darkolivegreen3", TRUE, c(0, 120), c(0, 5000))
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

#####Figure 5 Parameter recovery SB4RC and ST3RC#####
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


#####Figure 6 ST3RC I's#####
pdf("figs/Figure6.pdf", width = 7.5, height = 9)
layout(matrix(c(1,2,3), nrow = 3), heights = c(1,1,1.2))
par(mar = c(0.5, 4, 0.1, 1))
fig6_plottrajectories("ST3RC", transmission_epi,
                      "orangered3", "orange", FALSE, c(120, 210), c(0, 3000))
fig6_plottrajectories("ST3RC", transmission_phylo,
                      "darkslateblue", "slateblue", FALSE, c(120, 210), c(0, 3000))
par(mar = c(4, 4, 0.1, 1))
fig6_plottrajectories("ST3RC", transmission_combined,
                      "darkolivegreen4", "darkolivegreen3", TRUE, c(120, 210), c(0, 3000))
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
pdf("figs/Figure8.pdf", width = 7.5, height = 7)
layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12), nrow = 4, ncol = 3), heights = c(1.2,1,1,1.25), widths = c(1.1, 1,1))
par(mar = c(0.5, 4, 3, 1))
fig8_plotrt("SB4RC", introduction_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 120), c(0, 8), 9, title = "Introduction")
par(mar = c(0.5, 4, 0.1, 1))
fig8_plotEpiNow2("SB4RC", "/Users/ciarajudge/Desktop/PhD/Publication1/epinow2_SB4RC_version1.RDS","deepskyblue3", "deepskyblue", FALSE, c(1, 120), c(0, 8), 9, title = "")
fig8_plotBDSky("SB4RC", "filename","firebrick3", "firebrick1", FALSE, c(1, 120), c(0, 8), 9, title = "")
par(mar = c(4, 4, 0.1, 1))
fig8_plotEpiInf("SB4RC", "filename","goldenrod3", "goldenrod1", TRUE, c(1, 120), c(0, 8), 9, title = "")
par(mar = c(0.5, 2, 3, 1))
fig8b_plotrt("SS3OC", sampling_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(1, 100), c(0, 4), 4, title = "Step-change in Sampling")
par(mar = c(0.5, 2, 0.1, 1))
fig8b_plotEpiNow2("SS3OC", "/Users/ciarajudge/Desktop/PhD/Publication1/epinow2_SS3OC_version1.RDS","deepskyblue3", "deepskyblue", FALSE, c(1, 100), c(0, 4), 9, title = "")
fig8b_plotBDSky("SS3OC", "filename","firebrick3", "firebrick1", FALSE, c(1, 100), c(0, 4), 9, title = "")
par(mar = c(4, 2, 0.1, 1))
fig8b_plotEpiInf("SS3OC", "", "goldenrod3", "goldenrod1", TRUE, c(1, 100), c(0, 4), 4, title = "")
par(mar = c(0.5, 2, 3, 1))
fig8b_plotrt("ST3RC", transmission_combined,"darkolivegreen4", "darkolivegreen3", FALSE, c(110, 200), c(0, 2), 4, title = "Step-change in Transmission")
par(mar = c(0.5, 2, 0.1, 1))
fig8b_plotEpiNow2("ST3RC", "/Users/ciarajudge/Desktop/PhD/Publication1/epinow2_ST3RC.RDS", "deepskyblue3", "deepskyblue", FALSE, c(110, 200), c(0, 2), 4, title = "")
fig8b_plotBDSky("ST3RC", "filename", "firebrick3", "firebrick1", FALSE, c(110, 200), c(0, 2), 4, title = "")
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


table2_rttransmitaccuracy1("SB4RC", introduction_epi, 8)
table2_rttransmitaccuracy1("SB4RC", introduction_phylo, 8)
table2_rttransmitaccuracy1("SB4RC", introduction_combined, 8)

table2_rttransmitaccuracy1("ST3RC", transmission_epi, 4)
table2_rttransmitaccuracy1("ST3RC", transmission_phylo, 4)
table2_rttransmitaccuracy1("ST3RC", transmission_combined, 4)

table2_rttransmitaccuracy2("SS3OC", sampling_epi, 4)
table2_rttransmitaccuracy1("SS3OC", sampling_phylo, 4)
table2_rttransmitaccuracy2("SS3OC", sampling_combined, 4)


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
