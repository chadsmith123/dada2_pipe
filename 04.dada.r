# R script
# Runs dada on dereplicated sequences and plots error profiles.
# Merges paired-end reads. 
# Filters chimeras and assigns taxonomy using GreenGenes.
#
# usage: R CMD BATCH --slave 04.dada.r
#
# GG_TRAIN	Training set for Greengenes taxonomy
# MINOVERLAP	Minimum overlap between reads to merge them
# MAXMISMATCH	Maximum number of differences between reads to merge them
# THREADS	CPU threads to use for chimera detection
# R_FILE        R file to output
source("params.txt")

require(dada2); packageVersion("dada2")
require(ShortRead)
require(ggplot2)

load(R_FILE)

cat("\n### Running dada\n")
dadaFs <- dada(derepFs, err=inflateErr(tperr1,3), selfConsist = TRUE,multithread=T)
dadaRs <- dada(derepRs, err=inflateErr(tperr1,3), selfConsist = TRUE,multithread=T)
plotErrors(dadaFs[[1]], nominalQ=TRUE)
ggsave(paste("plotErrors_", names(dadaFs)[1], ".png", sep=""))

cat("\n### Running mergePairs\n")
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, minOverlap=MINOVERLAP,
		      maxMismatch=MAXMISMATCH, verbose=TRUE)

# Inspect the merger data.frame from the first sample
#head(mergers[[1]])
seqtab <- makeSequenceTable(mergers)

cat("\n### Filtering chimeras\n")
seqtab.nochim <- removeBimeraDenovo(seqtab, verbose=TRUE,multithread=THREADS)
chimeras <- sum(seqtab) - sum(seqtab.nochim)
p.chimeras <- round(1 - sum(seqtab.nochim)/sum(seqtab), digits=4) * 100
cat("Chimeras:", chimeras, "/", sum(seqtab), "(", p.chimeras, "%) of sequences removed.\n")

cat(dim(seqtab.nochim)[1],"samples and",dim(seqtab.nochim)[2],"sequence variants.\n") 

cat("\n### Sequence length summary\n")
seql <- sapply(colnames(seqtab.nochim),function(x) length(strsplit(x,split='')[[1]]))
summary(seql)
png("merged_sequence_lengths.png",width=800,height=800)
hist(seql, xlab="Sequence Lengths")
dev.off()

cat("\n### Assign taxonomy\n")
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

save.image(R_FILE)
