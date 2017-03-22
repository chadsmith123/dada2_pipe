#!/usr/bin/env bash
# Merge QC log
# Outputs number and proportion of sequences merged in the same order as 03.filter_dereplicate_QC.sh
#
# usage: ./04.dada_merge_QC.sh
#
# DADA_LOG	Log file returned by 04.dada.r
DADA_LOG="04.dada.r.Rout"

cat ${DADA_LOG} |grep 'successfully merged' | cut -f1,11 -d ' ' > /tmp/merged

while read line; do
	input=`echo $line | cut -f1 -d ' '`
	output=`echo $line | cut -f2 -d ' '`
	p_merged=`echo ${input}/${output} | bc`
	echo -e "${input}\t${output}\t${p_merged}"
done < /tmp/merged

