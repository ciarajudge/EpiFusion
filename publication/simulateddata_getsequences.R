library(ape)
library(phangorn)
library(tidyverse)


tree <- read.tree("simulateddata_data/SB4RC/SB4RC_downsampledtree.tree")
sequences <- simSeq(tree, l=8000, type = "DNA", rate = (1/365))
write.phyDat(sequences, file = "simulateddata_data/SB4RC/SB4RC_sequences_higherrate.fa", format = "fasta")


#fix dates
dates <- read.csv("SS3OC/SS3OC_leafdates_numeric.txt", header = F)
datevector <- dates$V2 + as.Date("2021-01-01")
dates %>% dplyr::mutate(date = datevector) -> metadata
write.csv(metadata, "SS3OC/SS3OC_metadata.csv", col.names = F, row.names = F, quote = F)


