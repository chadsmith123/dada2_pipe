#!/usr/bin/env bash
# Filter QC Log 
# Outputs FASTQ ID, number of input sequences, number of output sequences after filtering, and
# the proportion of sequences retained
#
# usage: ./03.filter_dereplicate_QC.sh
#
# Requires: bc
#
# Requires that FASTQ file names are formatted '$ID_$READ.fastq.gz', e.g.
# sample1_F.fastq.gz is the forward read for 'sample1'.
source params.txt

for i in `find ${SEQ_PATH} -iname "*_F_filt.fastq.gz"`; do
	file=`basename $i | cut -f1 -d '_'`
	seqs_in=`gunzip -c ${SEQ_PATH}/${file}${READF_ID}.fastq.gz | grep '^@' | wc -l`
	seqs_out=`gunzip -c ${SEQ_PATH}/${file}_F_filt.fastq.gz | grep '^@' | wc -l`
	p_retained=`echo ${seqs_out}/${seqs_in} | bc`
	echo -e "$file\t$seqs_in\t$seqs_out\t$p_retained"
done
