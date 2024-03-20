# computation_genomics

Codes Explanation: 

1. Read, Clean and Assemble Genome: https://medium.com/@npuri.24/computational-genomics-reading-cleaning-and-performing-genome-assembly-95b362edf72e


conda create -n nextflow-env


conda activate nextflow-env


conda install -c bioconda spades=3.15.3 fastp=0.23.2 


chmod +x purinandita.nf


nextflow run purinandita.nf
