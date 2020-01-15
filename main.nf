params.reads = "/tmp/rnatoy/rnatoy/data/ggal/*_{1,2}.fq"
params.annot = "/tmp/rnatoy/rnatoy/data/ggal/ggal_1_48850000_49020000.bed.gff"
params.genome = "/tmp/rnatoy/rnatoy/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa"
params.outdir = 'results'
params.testechoout = "/tmp/rnatoy"
//
genome_file = file(params.genome)
annotation_file = file(params.annot)
testechoout_file = file(params.testechoout)

Channel
    .fromFilePairs( params.reads )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .set { read_pairs } 
 
/*
 * Step 1. Builds the genome index required by the mapping process
 */
process buildIndex {
    tag "$genome_file.baseName"
    
    input:
    file genome from genome_file
     
    output:
    file 'genome.index*' into genome_index
       
    """
    bowtie2-build --threads ${task.cpus} ${genome} genome.index
    """
}


process testtouch {
        echo true 
        """
        echo ";lajsd" > $testechoout_file/testtouch.txt
        """
}
/*
 * Step 2. Maps each read-pair by using Tophat2 mapper tool
 */
process mapping {
    tag "$pair_id"
     
    input:
    file genome from genome_file 
    file annot from annotation_file
    file index from genome_index
    set pair_id, file(reads) from read_pairs
 
    output:
    set pair_id, "accepted_hits.bam" into bam
 
    """
    tophat2 -p ${task.cpus} --GTF $annot genome.index $reads
    mv tophat_out/accepted_hits.bam .
    """
}

process publishetst {
        publishDir params.outdir, mode: 'copy'
        input:
        file "home/jeszyman/testecho"

        output: 
        file (testechocp)

        """
        mv ~/testecho /tmp/rnatoy/results/testechocp
        """
}

/*
 * Step 3. Assembles the transcript by using the "cufflinks" tool
 */
process makeTranscript {
    tag "$pair_id"
    publishDir params.outdir, mode: 'copy'  
       
    input:
    file annot from annotation_file
    set pair_id, file(bam_file) from bam
     
    output:
    set pair_id, file('transcript_*.gtf') into transcripts
 
    """
    cufflinks --no-update-check -q -p $task.cpus -G $annot $bam_file
    mv transcripts.gtf transcript_${pair_id}.gtf
    """
}
 
workflow.onComplete { 
	println ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}