#!/usr/bin/env bash
# 
# Writes a script to:
# 1) Discard sequences without forward and reverse primers 
# 2) Trim primers from forward and reversed reads in paired-end sequences.
#
# Requires that FASTQ file names are formatted '$ID_$READ.fastq.gz', e.g.
# sample1_F.fastq.gz is the forward read for 'sample1'.
#
# Usage: ./01.trim_primers.sh
#
# Requires: cutadapt
#
# RAW_SEQDIR	Path to fastq.gz files for processing
# OUTDIR	Output directory for processed reads
# PRIMER_F	Forward primer sequence
# PRIMER_R	Reverse primer sequence
# READ1_ID	String indicating how read 1 is listed in the fastq filename (default: _1)
# READ2_ID	String indicating how read 2 is listed in the fastq filename (default: _2)
# ERROR_RATE	Error rate tolerated in primer sequence (default:0)

RAW_SEQDIR=/tmp/test
OUTDIR=${RAW_SEQDIR}/no_primers
PRIMER_F="GTGYCAGCMGCCGCGGTA"
PRIMER_R="GGACTACHVGGGTWTCTAAT"
READ1_ID="_R1"
READ2_ID="_R2"
ERROR_RATE=0

if [ ! -d $OUTDIR ]; then mkdir $OUTDIR; fi
if [ -f 01.trim_primers.ex ]; then rm 01.trim_primers.ex; fi

# Find *fastq.gz sequences to process 
for i in `find $RAW_SEQDIR/ -maxdepth 1 -iname "*${READ1_ID}*fastq.gz"`; do
	R1=$i
	R2=`echo $i | sed "s/${READ1_ID}/${READ2_ID}/"`
	if [ ! -f $R2 ]; then echo "$R2 is missing. Skipping to next read pair.";continue;fi
	sampleid=`basename $i | cut -d _ -f 1` # sampleid is the first field in the filename w/delimiter set to _

# Generate script file for cluster
echo "
cutadapt -g $PRIMER_F -G $PRIMER_R\
 -o ${OUTDIR}/${sampleid}${READ1_ID}.fastq.gz\
 -p ${OUTDIR}/${sampleid}${READ2_ID}.fastq.gz\
 -e ${ERROR_RATE}\
 $R1 $R2\
 --trimmed-only\
 > ${OUTDIR}/${sampleid}.log\
" >> 01.trim_primers.ex
done
