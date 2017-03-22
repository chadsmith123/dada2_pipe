#!/usr/bin/env bash
# Cutadapt QC Statistics
#
# Outputs file names and % of sequenced trimmed to std out
# 
# Usage: ./01.trim_primers_QC.sh
#
# SEQ_PATH       Path to cutadapt *.log files 
source params.txt

for i in `find $SEQ_PATH -iname "*.log"`; do
	passed=`cat ${i} | grep "Pairs written (passing filters):" |cut -f5- -d " " |sed -e 's;^ *;;' -e 's; ;\t;'`
	echo -e "${i}\t${passed}" 
done
