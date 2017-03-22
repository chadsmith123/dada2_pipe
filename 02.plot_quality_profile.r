# R script 
# Generates qualiy profile plots for the first four forward and reverse reads and saves the R image
# to retain objects for downstream analysis.
#
# usage: R CMD BATCH --slave 02.plot_quality_profile.r 
# Run from working directory where dada analysis will be conducted.
#
# SEQ_PATH	Path to input forward and reverse fastq.gz sequences
# READ1_ID      String indicating how read 1 is listed in the fastq filename 
# READ2_ID      String indicating how read 2 is listed in the fastq filename 
# R_FILE	R file to output

require(dada2); packageVersion("dada2")
require(ShortRead)
require(ggplot2)

SEQ_PATH <- "/tmp/test/no_primers/" 
FORWARD_ID="_R1"
REVERSE_ID="_R2"
R_FILE="dada_test.Rdat"

fns <- list.files(SEQ_PATH)
fastqs <- fns[grepl(".fastq.gz$", fns)]
fastqs <- sort(fastqs) # Sort ensures forward/reverse reads are in same order
fnFs <- fastqs[grepl(FORWARD_ID, fastqs)] # Just the forward read files
fnRs <- fastqs[grepl(REVERSE_ID, fastqs)] # Just the reverse read files

# Get sample names from the first part of the forward read filenames
sample.names <- sapply(strsplit(fnFs, "_"), `[`, 1)

# Fully specify the path for the fnFs and fnRs
fnFs <- paste0(SEQ_PATH, fnFs)
fnRs <- paste0(SEQ_PATH, fnRs)

# View quality plots of sequences
png("quality_profile_F1.png",width=800,height=800);plotQualityProfile(fnFs[[1]]);dev.off()
png("quality_profile_F2.png",width=800,height=800);plotQualityProfile(fnFs[[2]]);dev.off()
png("quality_profile_F3.png",width=800,height=800);plotQualityProfile(fnFs[[3]]);dev.off()
png("quality_profile_F4.png",width=800,height=800);plotQualityProfile(fnFs[[4]]);dev.off()
png("quality_profile_R1.png",width=800,height=800);plotQualityProfile(fnRs[[1]]);dev.off()
png("quality_profile_R2.png",width=800,height=800);plotQualityProfile(fnRs[[1]]);dev.off()
png("quality_profile_R3.png",width=800,height=800);plotQualityProfile(fnRs[[3]]);dev.off()
png("quality_profile_R4.png",width=800,height=800);plotQualityProfile(fnRs[[4]]);dev.off()

save(fns, fastqs, fnFs, fnRs, sample.names, file=R_FILE)
