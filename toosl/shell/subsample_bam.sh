
# - Fastas
#   - https://www.biostars.org/p/13270/
#   - Fastqs
#     - [[Question: Selecting Random Pairs From Fastq?]]
#     - [[https://www.biostars.org/p/6544/][look at all the ways to split a fastq file!]]
# - Bams
#   - https://bioinformatics.stackexchange.com/questions/402/how-can-i-downsample-a-bam-file-while-keeping-both-reads-in-pairs
#   - https://www.google.com/search?q=subset+bam+file
#   - samtools view -bo subset.bam -s 123.4 alignments.bam chr1 chr2
#   function SubSample {

function SubSample {
## Calculate the sampling factor based on the intended number of reads:
FACTOR=$(samtools idxstats $1 | cut -f3 | awk -v COUNT=$2 'BEGIN {total=0} {total += $1} END {print COUNT/total}')

if [[ $FACTOR > 1 ]]
  then
  echo '[ERROR]: Requested number of reads exceeds total read count in' $1 '-- exiting' && exit 1
fi

sambamba view -s $FACTOR -f bam -l 5 $1

}
