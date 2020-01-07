#!/bin/bash -ue
bwa mem /home/jeszyman/ref/bwa-hg19/hg19.fa toy-5k-HiSeqW43_Undetermined_R6000292_L004_R1_001.fastq.gz toy-5k-HiSeqW43_Undetermined_R6000292_L004_R2_001.fastq.gz > /tmp/TEST.sam
