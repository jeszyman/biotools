cd ~/data
source ~/repos/mpnst/bin/setup.sh
docker_interactive
bioinformatics-toolkit
which simNGS
cd /home/jeszyman/data
ls
mkdir -p /home/jeszyman/data/simNGS-runfiles
wget --directory-prefix=/home/jeszyman/data/ref/simNGS-runfiles \
     --no-check-certificate \
     --no-directories \
     --accept "*.runfile" \
     --recursive --level=3 \
     --no-clobber https://www.ebi.ac.uk/goldman-srv/simNGS/runfiles5/HiSeq/
cat /home/jeszyman/data/ref/hg19.fa | simNGS \
                                          --paired paired /home/jeszyman/data/ref/simNGS-runfiles/s_4_4x.runfile > test.fq
