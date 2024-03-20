#1. Setup the working directory, fetch the compressed assembly FastA files, decompress, and verify they look right
mkdir -pv ~/ex5/fastani
cd ~/ex5/fastani
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/879/185/GCA_001879185.2_ASM187918v2/GCA_001879185.2_ASM187918v2_genomic.fna.gz https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/254/515/GCF_000254515.1_ASM25451v2/GCF_000254515.1_ASM25451v2_genomic.fna.gz
gunzip -kv *.fna.gz
head -n 2 *.fna
tail -n 1 *.fna
grep '>' *.fna


#2. Rename to make this simpler
mv -v GCF_000254515.1_ASM25451v2_genomic.fna reference.fna
mv -v GCA_001879185.2_ASM187918v2_genomic.fna problem.fna


#3. Compare "contaminated" problem assembly to the species type strain
conda create -n fastani -c bioconda fastani -y
conda activate fastani
fastANI \
  --query problem.fna \
  --ref reference.fna \
  --output FastANI_Output.tsv
awk \
  '{alignment_percent = $4/$5*100} \
   {alignment_length = $4*3000} \
   {print $0 "\t" alignment_percent "\t" alignment_length}' \
  FastANI_Output.tsv \
  > FastANI_Output_With_Alignment.tsv
sed \
  "1i Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%Query_Aligned\tBasepairs_Query_Aligned" \
  FastANI_Output_With_Alignment.tsv \
  > FastANI_Output_With_Alignment_With_Header.tsv
column -ts $'\t' FastANI_Output_With_Alignment_With_Header.tsv | less -S


#4. Genotype excercise : Perform MLST NOTE: if conda takes too long to install the mlst package suite, consider docker as an alternative
docker pull staphb/mlst:latest
docker run -it --mount type=bind,src=$HOME/ex5,target=/local staphb/mlst bash
cd /local
mlst *.fna > MLST_Summary.tsv
exit

mkdir -pv ~/ex5/mlst
cd ~/ex5/mlst
ln -sv ../fastani/problem.fna .
conda create -n mlst -c conda-forge -c bioconda mlst -y
conda activate mlst
mlst *.fna > MLST_Summary.tsv
column -ts $'\t' FastANI_Output_With_Alignment_With_Header.tsv | less -S

#5 Quality Assessments Exercise - evaluate the assembly itself
mkdir -pv ~/ex5/checkm/{asm,db}
cd ~/ex5/checkm/asm
ln -sv ../../fastani/problem.fna .
conda create -n checkm -c conda-forge -c bioconda checkm-genome -y
conda activate checkm
cd ~/ex5/checkm/db
# Download took me 5 min
wget https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
tar zxvf checkm_data_2015_01_16.tar.gz
echo 'export CHECKM_DATA_PATH=$HOME/ex5/checkm/db' >> ~/.bashrc
source ~/.bashrc
echo "${CHECKM_DATA_PATH}"
conda activate checkm
cd ~/ex5/checkm
checkm taxon_list | grep Campylo
checkm taxon_set species "Campylobacter jejuni" Cj.markers
checkm \
  analyze \
  Cj.markers \
  ~/ex5/checkm/asm \
  analyze_output
checkm \
  qa \
  -f checkm.tax.qa.out \
  -o 1 \
  Cj.markers \
  analyze_output
sed 's/ \+ /\t/g' checkm.tax.qa.out > checkm.tax.qa.out.tsv
cut -f 2- checkm.tax.qa.out.tsv > tmp.tab && mv tmp.tab checkm.tax.qa.out.tsv
sed -i '1d; 3d; $d' checkm.tax.qa.out.tsv
column -ts $'\t' checkm.tax.qa.out.tsv | less -S

#6 Pairwise bash tricks for FASTANI
##Form a bash array (list of files to be analyzed). This assumes assemblies are "fa" or "fna" file extensions in the current working directory.
shopt -s nullglob
assemblies=( *.{fa,fna} )
shopt -u nullglob

##Perform pairwise comparisons using the store array containing filepaths as input
for ((i = 0; i < ${#assemblies[@]}; i++)); do 
  for ((j = i + 1; j < ${#assemblies[@]}; j++)); do 
    echo "${assemblies[i]} and ${assemblies[j]} being compared..."
    fastANI \
     -q ${assemblies[i]} \
     -r ${assemblies[j]} \
     -o FastANI_Outdir_${assemblies[i]}_${assemblies[i]}.tsv
  done
done 

## View all ANI Values 
cat FastANI_Outdir_*.txt | awk '{print $1, $2, $3}'
