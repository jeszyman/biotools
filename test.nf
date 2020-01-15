println "Hello world"
params.reference_fasta = "$HOME/repos/bioinformatics-toolkit/tmp/chr1-trimmed.fa"
prev_reference_fasta_file = file(params.reference_fasta)
params.test = "runit"
params.outdir = "/home/jeszyman/repos/bioinformatics-toolkit/results"






process get_hg19_chr1 {

        output:

        script:
        if( !prev_reference_fasta_file.exists () )
        """
        rm -rf $HOME/repos/bioinformatics-toolkit/tmp/
        mkdir -p $HOME/repos/bioinformatics-toolkit/tmp/
        wget https://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr1.fa.gz -O $HOME/repos/bioinformatics-toolkit/tmp/chr1.fa.gz
        gunzip $HOME/repos/bioinformatics-toolkit/tmp/chr1.fa.gz
        cat $HOME/repos/bioinformatics-toolkit/tmp/chr1.fa | head -n 1200000 > $HOME/repos/bioinformatics-toolkit/tmp/chr1-trimmed.fa
        rm $HOME/repos/bioinformatics-toolkit/tmp/chr1.fa        
        """
        else if( prev_reference_fasta_file.exists () )
        """
        echo "reference fasta exists"
        """
}


reference_fasta = Channel.fromPath ( '/home/jeszyman/repos/bioinformatics-toolkit/tmp/*.fa' )

process bwa_index {

        input:
        file reference_fasta_file from reference_fasta

        output:
        file 'reference_fasta_dir' into reference_fasta_dir2

        script:
        """
        bwa index ${reference_fasta_file} > reference_fasta_dir
        """
}

myFileChannel = Channel.fromPath( '/home/jeszyman/repos/bioinformatics-toolkit/tmp/chr1-trimmed.fa', type: 'any' )

process generate_seq_library {

          publishDir "$params.outdir"

        input:
        file reference_fasta_file2 from myFileChannel 

        output:
        file 'test.fa' into reference_fasta_dir3

        script:
        """
        cat ${reference_fasta_file2} | simLibrary > test.fa
        """
}

/*


process dna_fastq_qc {
}

process generate_seq_reads {
}

process bwa_mem {
}

output:
        file 'chr1-trimmed.fa' into reference_fasta




*/
println "END SCRIPT"