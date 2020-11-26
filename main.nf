/*
 * Parameters
 */
params.home          = "/store/users/jeszyman"
params.ref           = "${params.home}/data/ref"
params.genome        = "${params.ref}/mus_musculus98_dna/Mus_musculus.GRCm38.dna.primary_assembly.fa"
params.transcriptome = "${params.ref}/mus_musculus98_cdna/Mus_musculus.GRCm38.cdna.all.fa"
params.star_index    = "${params.ref}/mouse-grch38-star"
params.reads         = "/store/users/jeszyman/data/card-rad-bio/toy/*-*_R{1,2}_001.fastq.gz.short.fastq"
//
/*
 * Channels 
 */
genome_file        = file(params.genome)
transcriptome_file = file(params.transcriptome)
star_index_file    = file(params.star_index)
read_pairs = Channel.fromFilePairs(params.reads)
//
/*
 * Print for peace of mind:
 */
println "C A R D I A C R A D I O B I O L O G Y P I P E"
println "============================================="
println "genome        : ${params.genome}"
println "transcriptome : ${params.transcriptome}"

// Channel-checker:
if( !genome_file.exists() ) exit 1, "NO genome"
if( !transcriptome_file.exists() ) exit 1, "NO transcriptome"
if( !star_index_file.exists() ) exit 1, "NO star index"
//

read1_file = Channel.fromPath( '/store/users/jeszyman/data/card-rad-bio/toy/1-ir.AACATCTCGA-TATTCGCCAG.AACATCTCGA-TATTCGCCAG_S3_L003_R1_001.fastq.gz.short.fastq' )

read2_file = Channel.fromPath( '/store/users/jeszyman/data/card-rad-bio/toy/1-ir.AACATCTCGA-TATTCGCCAG.AACATCTCGA-TATTCGCCAG_S3_L003_R2_001.fastq.gz.short.fastq' )

println "${read1_file}"

process star_align {
        input:
        file star_index from star_index_file
        file read1 from read1_file
        file read2 from read2_file
        
        output:
        file 'Aligned.out.sam' into test_sam

        """
        STAR \
        --runThreadN 36
        --genomeDir ${star_index}
        --readFilesIn ${read1} ${read2}
        """
}

/*


TODO process index_star {
        input:
        file transcriptome_file

        output:
        file "transcriptome.index.star" into transcriptome_index_star

        """
        mkdir /store/users/jeszyman/data/ref/
        STAR \
        --runThreadN 36 \
        --runMode genomeGenerate \
        --genomeDir transcriptome.index.star
        --genomeFastaFiles ${transcriptome_file} \

        """
}





process index_kallisto {
        input:
        file transcriptome_file

        output:
        file "transcriptome.index" into transcriptome_index_kallisto

        script:
        """
        kallisto index \
        --index transcriptome.index \
        ${transcriptome_file}
        """
}
*/