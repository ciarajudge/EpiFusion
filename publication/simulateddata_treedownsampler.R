library(ape)
library(phytools)
library(phangorn)

#Reading in tree
setwd("/Users/ciarajudge/Desktop/PhD/EpiFusionData")
tree <- read.tree(file = "/Users/ciarajudge/Desktop/PhD/EpiFusionData/SB3RC_BDSkyComparison/SB3RC_BDSkyComparison.tree")


distancefromoriginoflastsample <- 499.9764
treelength <- max(nodeHeights(tree))
offset <- distancefromoriginoflastsample - treelength
offset


ntips <- length(tree$tip.label)
labels <- tree$tip.label
for ( i in 1:length(labels)) {
  tmp <- unlist(str_split(str_remove(labels[i], "]"), "_"))
  labels[i] <- paste0("leaf_", tmp[1], "[", tmp[2], "]")
}
tree$tip.label <- labels

nodelabels <- tree$node.label
for (i in 1:length(nodelabels)) {
  tmp <- str_remove(str_remove(nodelabels[i], "_"), "]")
  nodelabels[i] <- paste0("node_", i, "[", tmp, "]")
}
tree$node.label <- nodelabels

#write.tree(tree, "ST3RC-2/ST3RC-2_bigtree.tree")

numsamples <- round(ntips*0.15)
#Downsample the tree
sampled_tips <- sample(tree$tip.label, numsamples, replace = F)
downsampled_tree <- keep.tip(tree, sampled_tips)

downsampledtreelength <- max(nodeHeights(downsampled_tree))
downsampled_tree$root.edge = 27.06546050939297
write.tree(downsampled_tree, "SB3RC_BDSkyComparison/SB3RC_BDSkyComparison_downsampledtree.tree")


plot(downsampled_tree, root.edge = TRUE)
axis(1)
for (i in seq(0, 500)) {
  if (i%%7==0){
    abline(a=NULL,b=NULL,h=NULL,v=i, col=adjustcolor("black", 0.4))
    #text(i+4, 450, paste0("week_", i/7))
  }
  else{
    abline(a=NULL,b=NULL,h=NULL,v=i, col=adjustcolor("black", 0.2), lty = 3)
  }
}





#Hard coded date of last sample, to help put the tree in time correctly
numsamples <- 2633
distancefromoriginoflastsample <- 78.7432425302081
treelength <- max(nodeHeights(tree))
offset <- distancefromoriginoflastsample - treelength

#Get node heights and offset them
nodeHeights = nodeHeights(tree) + offset

#Get leaf heights from the nodeHeights object and add them to the tree
leafHeights <- c()
for ( i in 1:nrow(nodeHeights)) {
  if (!(nodeHeights[i,2] %in% nodeHeights[,1])) {
    leafHeights <- append(leafHeights, nodeHeights[i,2])
  } else if (nodeHeights[i,2] == nodeHeights[i,1]) {
    leafHeights <- append(leafHeights, nodeHeights[i,2])
  }
}
tiplabels = tree$tip.label
newtiplabels <- c()
for (t in seq(1, length(tiplabels))) {
  time <- leafHeights[which(tiplabels == tiplabels[t])]
  newtiplabels[t] <- paste0("leaf_", tiplabels[t], "[", as.character(time), "]")
}
tree$tip.label <- newtiplabels

#Next get node heights
tree2 <- makeNodeLabel(tree, method = "number", prefix = "node_")
nodelabels <- tree2$node.label
newnodelabels <- c()
for (t in seq(1, tree2$Nnode)) { #Hard coded limits here of the number of internal nodes in the tree
  height <- nodeheight(tree2, t+numsamples)+offset 
  newnodelabels[t] <- paste0("node_", t, "[", as.character(height), "]")
}
tree2$node.label <- newnodelabels

#EXTRA A new approach to selecting the tips
tips <- tree2$tip.label
#Assemble a vector of the tip times
times <- sapply(tips, str_remove, pattern = "leaf_[0-9]*\\[")
times <- sapply(times, str_remove, pattern = "\\]")
times <- sapply(times, as.numeric)
times <- floor(times)
sampled_tips <- c()
for (i in 1:ceiling(max(times))) {
  options <- tips[which(times==i)]
  numseqs <- rbinom(1, length(options), 0.05)
  if (numseqs > 0) {
    sampled_tips <- append(sampled_tips, sample(options, numseqs))
  }
}

#Downsample the tree
num_sequences <- round(numsamples*0.2)
sampled_tips <- sample(tree2$tip.label, num_sequences, replace = F)
downsampled_tree <- keep.tip(tree2, sampled_tips)


write.tree(downsampled_tree, "basesimSIR/downsampledtree_dailybinom.txt")

#Plot the downsampled tree
downsampled_tree$root.edge = 2.3467 #Hardcoded
plot(downsampled_tree, show.node.label = TRUE, x.lim = c(129), y.lim = c(0, 127), root.edge = TRUE, cex = 0.5)
axis(1)
for (i in seq(0, 120)) {
  if (i%%7==0){
    abline(a=NULL,b=NULL,h=NULL,v=i, col=adjustcolor("black", 0.4))
    text(i+4, 124, paste0("week_", i/7))
  }
  else{
    abline(a=NULL,b=NULL,h=NULL,v=i, col=adjustcolor("black", 0.2), lty = 3)
  }
}

#Simulate sequences
root_seq = sample(c("a", "c", "t", "g"), size = 1000, replace = TRUE)
seq_rate = 1e-3
sequences <- simSeq(tree, type = "DNA", l = 1000, rate = seq_rate, rootseq = root_seq)
write.phyDat(sequences, file = "basesimSIR/basesimSIRsequences.fa", format = "fasta", colsep = "")


#####Scratch#####
tree <- read.tree("SL3RC/SL3RC_downsampledtree.tree")
plot(tree)

plot(downsampled_tree)



densitreeversion <- downsampled_tree
densitreeversion$tip.label <- as.character(seq(1, length(densitreeversion$tip.label)))
densitreeversion$node.label <- rep("", 132)
write.tree(densitreeversion, "SB3RC_BDSkyComparison/BDSkyComparison_DensitreeTree.tree")
treelength <- max(nodeHeights(densitreeversion))


