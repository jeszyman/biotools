#!/bin/bash -ue
bwa mem /store/users/jeszyman/data/ref/bwa-hg19/hg19.fa         /store/users/jeszyman/data/toy-5k-HiSeqW43_Undetermined_R6000292_L004_R1_001.fastq.gz         /store/users/jeszyman/data/toy-5k-HiSeqW43_Undetermined_R6000292_L004_R2_001.fastq.gz         > test.sam
