// channels are I/O while processes are scripts
// methods
// qualifiers
/// .set declares definition of each element of a tuple
/// .
//------------------------------------------------------------------------// 
// PARAMETERS
params.transcriptome = "$HOME/data/ref/bwa-hg19/hg19.fa"
//
transcriptome_file = file(params.transcriptome)
//
if( !transcriptome_file.exists() ) exit 1, "No HG19 Transcriptome"
//
Channel
        .fromFilePairs("$HOME/data/*_{R1,R2}_001.fastq.gz", checkIfExists:true)
        .set { samples_ch }
  
process bwamem {

        input:
        set sampleID, file(reads) from samples_ch

        script:
        """
        bwa mem /store/users/jeszyman/data/ref/bwa-hg19/hg19.fa \
        ${reads[0]} \
        ${reads[1]} \
        > /store/users/jeszyman/data/${sampleID}.sam
        """
}