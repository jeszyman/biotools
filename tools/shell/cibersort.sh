datadir=~/data/tmp/cibersort/data
resultsdir=~/data/tmp/cibersort/results
#
mkdir -p $datadir
mkdir -p $resultsdir 
#NOTE, manual download of lm22 and example dataset (no wget option)
cp ~/data/ref/lm22.txt $datadir/ 
cp ~/data/ref/mixture_HNSCC_Puram_et_al_Fig2cd.txt $datadir/
#
docker run \
       -it \
       -v $datadir:/src/data \
       -v $resultsdir:/src/outdir \
       lyronctk/cibersortxfractions \
       --mixture /src/data/mixture_HNSCC_Puram_et_al_Fig2cd.txt \
       --sigmatrix /src/data/lm22.txt \
       --perm 2 \
       --rmbatchBmode TRUE \
       --abs_method 'sig.score'
