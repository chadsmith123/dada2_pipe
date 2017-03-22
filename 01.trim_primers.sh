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
# SEQ_PATH	Output directory for processed reads
# PRIMER_F	Forward primer sequence
# PRIMER_R	Reverse primer sequence
# READF_ID	String indicating how read 1 is listed in the fastq filename 
# READR_ID	String indicating how read 2 is listed in the fastq filename
# ERROR_RATE	Error rate tolerated in primer sequence (default:0)

source params.txt

if [ ! -d $SEQ_PATH ]; then mkdir $SEQ_PATH; fi
if [ -f 01.trim_primers.ex ]; then rm 01.trim_primers.ex; fi

# Find *fastq.gz sequences to process 
for i in `find $RAW_SEQDIR/ -maxdepth 1 -iname "*${READF_ID}*fastq.gz"`; do
	R1=$i
	R2=`echo $i | sed "s/${READF_ID}/${READR_ID}/"`
	if [ ! -f $R2 ]; then echo "$R2 is missing. Skipping to next read pair.";continue;fi
	sampleid=`basename $i | cut -d _ -f 1` # sampleid is the first field in the filename w/delimiter set to _

# Generate script file for cluster
echo "
cutadapt -g $PRIMER_F -G $PRIMER_R\
 -o ${SEQ_PATH}/${sampleid}${READF_ID}.fastq.gz\
 -p ${SEQ_PATH}/${sampleid}${READR_ID}.fastq.gz\
 -e ${ERROR_RATE}\
 $R1 $R2\
 --trimmed-only\
 > ${SEQ_PATH}/${sampleid}.log\
" >> 01.trim_primers.ex
chmod +x 01.trim_primers.ex
done
