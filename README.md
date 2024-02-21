# computation_genomics

#Create conda environment called nextflow-env
conda create -n nextflow-env

#Activate environment 
conda activate nextflow-env

#Install spades and fastp
conda install -c bioconda spades=3.15.3 fastp=0.23.2 

#Make pipeline script executable
chmod +x purinandita.nf

#Create inputs dir and link reads
mkdir inputs 
ln -s /path/to/reads.fq.gz inputs/

#Set reads parameter 
NEXTFLOW_PARAMS='{"reads": "inputs/reads.fq.gz"}'

#Run nextflow pipeline 
nextflow run pipeline.nf -params-file $NEXTFLOW_PARAMS
