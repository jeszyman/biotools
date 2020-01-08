println "Hello world"
params.reference_fasta = "$HOME/repos/bioinformatics-toolkit/tmp/chr1-trimmed.fa"
prev_reference_fasta_file = file(params.reference_fasta)
params.test = "runit"
params.outdir = 'results'

process get_hg19_chr1 {

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

/*

process foo {

    publishDir 'home/jeszyman/repos/bioinformatics-toolkit', mode: 'move'

    output:
    file 'results.txt' into ANYCHANNELNAME

    '''
    mv ~/R-HSA-157118.sbml ~/repos/bioinformatics-toolkit/results.txt
    '''
}


process randomnum {
        publishDir '$HOME/repos/bioinformatics-toolkit/tmp'
        output: file 'results.txt' into numbers

        '''
        touch results.txt
        echo "basl;kedfjs" > results.txt
        '''
}


process generate_seq_library {

        script:
        """
        cat $HOME/repos/bioinformatics-toolkit/tmp/chr1-trimmed.fa | simLibrary > seq-library.fa
        """
}

process test_output_in_docker {

        script:
        """
        touch $HOME/repos/bioinformatics-toolkit/tmp/test
        echo "TEST" > $HOME/repos/bioinformatics-toolkit/tmp/test
        """
        }
m

process generate_seq_library {
        """
        cat $HOME/repos/bioinformatics-toolkit/tmp/chr1-trimmed.fa | simLibrary \
        --coverage 0.001 > $HOME/repos/bioinformatics-toolkit/tmp/ seq-library.fa
        """
}

process generate_seq_reads {
}

process dna_fastq_qc {
}

process bwa_index {
}

process bwa_mem {
}

output:
        file 'chr1-trimmed.fa' into reference_fasta




*/