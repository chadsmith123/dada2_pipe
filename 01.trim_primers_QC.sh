#!/usr/bin/env bash
# Cutadapt QC Statistics
#
# Outputs file names and % of sequenced trimmed to std out
# 
# Usage: ./01.trim_primers_QC.sh
#
# LOG_DIR       Path to cutadapt *.log files 

LOG_DIR=/tmp/test

for i in `find $LOG_DIR -iname "*.log"`; do
	passed=`cat ${i} | grep "Pairs written (passing filters):" |cut -f5- -d " " |sed -e 's;^ *;;' -e 's; ;\t;'`
	echo -e "${i}\t${passed}" 
done
