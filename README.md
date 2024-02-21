# computation_genomics


conda create -n nextflow-env


conda activate nextflow-env


conda install -c bioconda spades=3.15.3 fastp=0.23.2 


chmod +x purinandita.nf


mkdir inputs 
ln -s /path/to/reads.fq.gz inputs/


NEXTFLOW_PARAMS='{"reads": "inputs/reads.fq.gz"}'


nextflow run pipeline.nf -params-file $NEXTFLOW_PARAMS
