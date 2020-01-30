
/////////////////
/// RUN NOTES ///
/////////////////
//
// run in docker container bioinformatics-toolkit
//
//////////////////
/// PARAMETERS ///
//////////////////
//
params.transcriptome = "$HOME/data/ref/bwa-hg19/hg19.fa"
//
transcriptome_file = file(params.transcriptome)
//
if( !transcriptome_file.exists() ) exit 1, "No HG19 Transcriptome"
//
  
// process bwamem {

//         input:
//         set sampleID, file(reads) from samples_ch

//         script:
//         """
//         bwa mem /store/users/jeszyman/data/ref/bwa-hg19/hg19.fa \
//         ${reads[0]} \
//         ${reads[1]} \
//         > /store/users/jeszyman/data/${sampleID}.sam
//         """
// }

process get_genome {
        script:
        """
        mkdir -p $HOME/data/ref/hg19/
        wget https://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr1.fa.gz \
        -O $HOME/data/ref/hg19/chr1.fa.gz
        gunzip $HOME/data/ref/hg19/chr1.fa.gz
}

// process simulate_library{}

// simLibrary 
// --bias 0.5  
// --cov 0.055 
// --paired 
// --readlen 50 
// --strand random 
// --coverage 0.5 

// output: simulated_library

// //EXAMPLE cat genome.fa | simLibrary > library.fa

// process simulate_reads

// input: simulated_library

// output: simulated_fastqs_joined

// wget https://www.ebi.ac.uk/goldman-srv/simNGS/runfiles5/HiSeq/s_1_4x.runfile