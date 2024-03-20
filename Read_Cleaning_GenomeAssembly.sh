#!/usr/bin/env bash

# Create a Conda enviroment
conda create -n ex3 -y

#Go into the ex3 environment and install a bunch of utilities from the bioconda channel
conda activate ex3
conda install -c bioconda -c conda-forge entrez-direct sra-tools fastqc trimmomatic skesa spades pigz -y

#Fetch FastQ data
mkdir -pv ~/exercise_3/raw_data
fasterq-dump --version

fasterq-dump \
 SRR15276224 
 --threads 1 \
 --outdir ~/exercise_3/raw_data \
 --split-files \
 --skip-technical

 #View quality assessment
 mkdir -v ~/exercise_3/raw_qa
 fastqc --version

 fastqc \
 --threads 2 \
 --outdir ~/exercise_3/raw_qa \
 ~/exercise_3/raw_data/SRR15276224_1.fastq.gz \
 ~/exercise_3/raw_data/SRR15276224_2.fastq.gz

#View the qc report on google web browser
google-chrome ~/exercise_3/raw_qa/*.html

 # Remove low quality reads
 mkdir -v ~/exercise_3/trim
 cd ~/exercise_3/trim
 trimmomatic -version

 trimmomatic PE -phred33 \
 ~/exercise_3/raw_data/SRR15276224_1.fastq.gz \
 ~/exercise_3/raw_data/SRR15276224_2.fastq.gz \
 ~/exercise_3/trim/r1.paired.fq.gz \
 ~/exercise_3/trim/r1_unpaired.fq.gz \
 ~/exercise_3/trim/r2.paired.fq.gz \
 ~/exercise_3/trim/r2_unpaired.fq.gz \
 SLIDINGWINDOW:5:30 AVGQUAL:30 \
 1> trimmo.stdout.log \
 2> trimmo.stderr.log

cat ~/exercise_3/trim/r1_unpaired.fq.gz ~/exercise_3/trim/r2_unpaired.fq.gz > ~/exercise_3/trim/singletons.fq.gz
rm -v ~/exercise_3/trim/*unpaired*
tree ~/exercise_3/trim

#Assemble with SKESA
mkdir -v ~/exercise_3/asm
cd ~/exercise_3/asm
skesa --version

skesa \
 --reads ~/exercise_3/trim/r1.paired.fq.gz ~/exercise_3/trim/r2.paired.fq.gz \
 --contigs_out ~/exercise_3/asm/skesa_assembly.fna \
 1> skesa.stdout.txt \
 2> skesa.stderr.txt
