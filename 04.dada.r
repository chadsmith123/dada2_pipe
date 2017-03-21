# R script
# Runs dada on dereplicated sequences and plots error profiles.
# Merges paired-end reads. 
# Filters chimeras and assigns taxonomy using GreenGenes.
#
# usage: R CMD BATCH --slave 04.dada.r
# Run from directory where dada2 analysis will be conducted
#
# GG_TRAIN	Training set for Greengenes taxonomy

require(dada2); packageVersion("dada2")
require(ShortRead)
require(ggplot2)

GG_TRAIN <- ""

cat("### Running dada\n")
dadaFs <- dada(derepFs, err=inflateErr(tperr1,3), selfConsist = TRUE,multithread=T)
dadaRs <- dada(derepRs, err=inflateErr(tperr1,3), selfConsist = TRUE,multithread=T)
plotErrors(dadaFs[[1]], nominalQ=TRUE)
ggsave("plot_errors.png")

cat("### Running mergePairs\n")
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)
# Inspect the merger data.frame from the first sample
#head(mergers[[1]])
seqtab <- makeSequenceTable(mergers)

cat("### Filtering chimeras\n")
seqtab.nochim <- removeBimeraDenovo(seqtab, verbose=TRUE,multithread=2)
dim(seqtab.nochim)
sum(seqtab.nochim)/sum(seqtab)

cat("### Assign taxonomy\n")
taxa.gg13_8 <- assignTaxonomy(seqtab.nochim, GG_TRAIN)
#taxa.rdp <- assignTaxonomy(seqtab.nochim, "~/work/qiime/gg/dada/rdp_train_set_14.fa.gz")
#taxa.silva_123 <- assignTaxonomy(seqtab.nochim, "~/work/qiime/gg/dada/silva_nr_v123_train_set.fa.gz")
samples.out <- rownames(seqtab.nochim)

## Greengenes mods
taxa <- taxa.gg13_8
gspp <- gsub("g__ s__|NA NA","Unassigned",paste(taxa[,6],taxa[,7]))
gspp <- gsub("g__|s__","",gspp)
gspp <- gsub(" $"," sp.",gspp)
gspp <- gsub(" NA"," sp.",gspp)

taxa <- cbind(taxa,gspp)
taxa <- gsub("k__|p__|c__|o__|f__|g__|s__","",taxa)

save.image()
