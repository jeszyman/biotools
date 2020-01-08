
process get_genome {

        output:
        file '$HOME/repos/bioinformatics-toolkit/tmp/chr1.fa' into full_chr1
        
        script:
        """
        rm -rf $HOME/repos/bioinformatics-toolkit/tmp/
        mkdir -p $HOME/repos/bioinformatics-toolkit/tmp/
        wget https://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr1.fa.gz -O $HOME/repos/bioinformatics-toolkit/tmp/chr1.fa.gz
        gunzip $HOME/repos/bioinformatics-toolkit/tmp/chr1.fa.gz
        """
}

process generate_library {
        input: file full_chr1 from full_chr1

        output:
        val x into final_channel

        script:
        """
        x = wc -l $full_chr1
        """
}

