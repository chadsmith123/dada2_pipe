# R script
# Trims, truncates and merges paired end reads, and then dereplicated the sequences.
# Saves the R image.
#
# usage: R CMD BATCH --slave 03.merge.r 
# Run from working directory where dada analysis will be conducted.
#
# SEQ_PATH	Path to input forward and reverse fastq.gz sequences
# TRIM_LEFT 	Trim forward, reverse primers by x bases before truncating 
# TRUNC		Truncate forward, reverse reads to x size before merging
# MAXN		Maximum number of N's in sequence allowed
# MAXEE		Maximum expected errors before sequence is discarded
# TRUNCQ	Truncate sequence if Illumina quality score falls below this value

require(dada2); packageVersion("dada2")
require(ShortRead)

SEQ_PATH <- ""
TRIM_LEFT=c(0,0) # Primers trimmed by cutadapt
TRUNC=c(230,230)
MAXN=0
MAXEE=2
TRUNCQ=2

# Make filenames for the filtered fastq files
filtFs <- paste0(SEQ_PATH, sample.names, "_F_filt.fastq.gz")
filtRs <- paste0(SEQ_PATH, sample.names, "_R_filt.fastq.gz")

cat("### Running fastqPairedFilter\n")
for(i in seq_along(fnFs)) {
 fastqPairedFilter(c(fnFs[i], fnRs[i]), c(filtFs[i], filtRs[i]),
 trimLeft=TRIM_LEFT, truncLen=TRUNC, 
 maxN=MAXN, maxEE=MAXEE, truncQ=TRUNCQ, 
 compress=TRUE, verbose=TRUE)
}

cat("### Running derepFastq\n")
derepFs <- derepFastq(filtFs, verbose=TRUE)
derepRs <- derepFastq(filtRs, verbose=TRUE)
# Name the derep-class objects by the sample names
names(derepFs) <- sample.names
names(derepRs) <- sample.names

save.image()
