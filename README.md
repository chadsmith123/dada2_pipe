# dada2_pipe
## Pipeline for Divisive Amplicon Denoising Algorithm (DADA)

This pipeline processes paired-end Illumina 16S rRNA sequences and executes the dada2 pipeline for clustering, classification and diagnostics. The pipeline is written to generate scripts in a unix environment that can be run on a cluster computer.

The steps are:

1. Trim primers from sequences using cutadapt and parse the output.
2. Generate plots of quality scores for a subset of sequences.
3. Filter low quality sequences, dereplicate and parse the output.
4. Infer sequence variants, assign taxonomy and parse the output.

## Dependencies
- [cutadapt](http://cutadapt.readthedocs.io/en/stable/guide.html) 
- [bc](https://www.gnu.org/software/bc/)
- [R](http://cran.stat.ucla.edu/)
- [dada2](https://github.com/benjjneb/dada2)

The output of the pipeline is an .RData file with the dada2 analysis. To run the pipeline a file named "params.txt" is required in the directory the scripts are executed to set the parameters and paths. See the example [params.txt](https://github.com/chadsmith123/dada2_pipe/blob/master/params.txt) for the format and the [dada2 documentation](http://benjjneb.github.io/dada2/index.html) for details on what the parameters are.

The pipeline is broken up into four steps at decision points in the workflow and where scripts are generated for use on a cluster. Scripts for cluster computing are indicated with a *.ex suffix. If using TACC at the University of Texas, the launcher_creator.py script can be run on *.ex scripts to generate job scripts to submit to the cluster. The pipeline can also be run without a cluster by simply executing the *.ex scripts. 

To run the pipeline:
1. Edit the params.txt file to set your paths and parameters
2. ./01.trim_primers.sh
3. Submit 01.trim_primers.ex to the cluster or execute the script locally
4. ./01.trim_primers_QC.sh to check cutadapt successfully trimmed the primers
5. R CMD BATCH --vanilla --slave 02.plot_quality_profile.r to check sequence quality and decide where to truncate the reads before they are filtered in the next step.
6. R CMD BATCH --vanilla --slave 03.filter_dereplicate.r
7. ./03.filter_dereplicate.sh to view how many sequences survived filtering
8. R CMD BATCH --vanilla --slave 04.dada.r
9. ./04.dada_merge_qc.sh to view how many sequences were successfully merged

R generates *.Rout output with additional diagnostic information. 

## References
Callahan BJ, McMurdie PJ, Rosen MJ et al. (2016) DADA2: High-resolution sample inference from Illumina amplicon data. Nature Methods, 13, 581–583.
