function SubSample {
## Calculate the sampling factor based on the intended number of reads:
FACTOR=$(samtools idxstats $1 | cut -f3 | awk -v COUNT=$2 'BEGIN {total=0} {total += $1} END {print COUNT/total}')

if [[ $FACTOR > 1 ]]
  then 
  echo '[ERROR]: Requested number of reads exceeds total read count in' $1 '-- exiting' && exit 1
fi

sambamba view -s $FACTOR -f bam -l 5 $1

}
