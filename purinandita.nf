#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process trim {

    

  input:
    file reads
  
  output:
    file "trimmed.fq.gz" 

  script:
  """
  fastp -i ${reads} -o trimmed.fq.gz  
  """
}

process spades {

  

  input:
    file reads

  output:
    path "spades_output" 

  script:
  """
  spades.py --careful -s ${reads} -o ./spades_output
  """
}

//Channel
     //reads_ch = Channel.fromPath("F0784744_R1.fastq")
  
// reads_ch = Channel.fromPath("F0784744_R1.fastq")
 // .fromPath("/home/harry/Comp_genomics/nextflow/F0784744_R1.fastq") 
//  .set { re

workflow {

reads_ch = file("F0784744_R1.fastq.gz")
//reads_ch = Channel.fromPath("F0784744_R1.fastq")

println reads_ch
  main: 
    trimmed_reads = trim(reads_ch)
    spades(trimmed_reads)

}
