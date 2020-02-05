FROM ubuntu:xenial
#########1#########2#########3#########4#########5#########6#########7
#############
### Notes ###
#############
## All tool builds are independent, except within Conda 
## Tools are preferentially
### 1) managed by apt or 
### 2) installed into /opt/
## See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
#
# placeholder variables
#
##############
### simNGS ###
##############
#
RUN apt-get update -qq
RUN apt-get install -qq --no-install-recommends --allow-unauthenticated \
    libblas-dev \
    liblapack-dev \
    make \
    tar \
    wget 
RUN cd /opt && wget --no-check-certificate https://www.ebi.ac.uk/goldman-srv/simNGS/current/simNGS.tgz && tar -xvzf simNGS.tgz
RUN cd /opt/simNGS/src && make -f Makefile.linux
ENV PATH="/opt/simNGS/bin:${PATH}"
#
############################
### Python 3.6 and Conda ###
############################
#
RUN apt-get update -qq
RUN apt-get install -qq --no-install-recommends --allow-unauthenticated \
bzip2 \
wget 
RUN cd /tmp && wget --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh
RUN bash /tmp/Miniconda3-4.3.21-Linux-x86_64.sh -b -p /opt/miniconda
ENV PATH="/opt/miniconda/bin:${PATH}"
# Alphebetical 
RUN conda install -c bioconda bcftools
RUN conda install -c bioconda bedtools
RUN conda install -c bioconda bowtie2
RUN conda install -c bioconda bwa
RUN conda install -c bioconda cutadapt
RUN conda install -c bioconda deeptools
RUN conda install -c bioconda fastp
RUN conda install -c bioconda fastqc
RUN conda install -c bioconda gatk
RUN conda install -c bioconda kallisto
RUN conda install -c bioconda mosdepth
RUN conda install -c bioconda picard
RUN conda install -c bioconda preseq
RUN conda install -c bioconda qualimap
#RUN conda install -c bioconda rseqc
RUN conda install -c bioconda salmon
RUN conda install -c bioconda sambamba
RUN conda install -c bioconda samblaster
RUN conda install -c bioconda samtools
RUN conda install -c bioconda seqkit
RUN conda install -c bioconda skewer
RUN conda install -c bioconda star
RUN conda install -c bioconda vcftools
#
# TMP NEED TO REMOVE CRAN FROM APT BELOW
RUN apt-get install -qq --no-install-recommends nano
#########
### R ###
#########
#
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
#RUN echo "deb http://cran.cnr.berkeley.edu/bin/linux/ubuntu xenial-cran35/" >> /etc/apt/sources.list
RUN echo "deb http://cran.wustl.edu/bin/linux/ubuntu xenial-cran35/" \
>> /etc/apt/sources.list
#RUN apt upgrade -qq
RUN apt update -qq
RUN apt-get install -qq --no-install-recommends r-base r-base-dev
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
   libfftw3-dev \
   gcc && apt-get clean 
ENV PATH="/usr/bin:${PATH}"
RUN echo 'local({r <- getOption("repos"); r["CRAN"] <- "http://cran.r-project.org"; options(repos=r)})' > ~/.Rprofile
RUN R -e 'install.packages("BiocManager"); BiocManager::install(); BiocManager::install("DESeq2"); BiocManager::install("tximport"); BiocManager::install("readr");'
#
###############################################################
### ^^^ BUILDS INDEPENDENTLY VALIDATED ABOVE THIS POINT ^^^ ### 
### Last successful build 2020-01-14 15:26 CST              ###
###############################################################
#
### TESTING ###
### Installs below this point are not individually validated and my require dependencies from above
# multiqc
## Set the locale
## https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#28406007
RUN apt-get update \
 && apt-get install -y --no-install-recommends locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8    

RUN pip install multiqc
#
# cnvkit
RUN pip install -U cython
RUN pip install -U future futures pandas pomegranate pyfaidx
RUN conda install -c bioconda pysam
RUN pip install cnvkit==0.9.6
#
# Ichor
## R devtools
### curl, libcurl4-openssl-dev 
#RUN apt-get update \
#    && apt-get install -y \
#    libcurl4-gnutls-dev \
#    libssl-dev \
#    libxml2-dev
#
RUN R -e "install.packages('devtools')"
RUN R -e "install.packages('devtools')"
#RUN R -e "library(devtools); install_github("broadinstitute/ichorCNA", force = T)"
# from 	git clone https://github.com/broadinstitute/ichorCNA.git && \ 
RUN Rscript -e 'install.packages(c("tidyverse", "git2r", "stringr", "devtools", "optparse"), repos = c(CRAN="http://cran.rstudio.com"))'

RUN R -e 'install.packages("BiocManager"); BiocManager::install(); BiocManager::install("HMMcopy"); BiocManager::install("SNPchip");' 

RUN apt-get install -y git 

RUN cd /opt && \
    git clone https://github.com/broadinstitute/ichorCNA.git && \
    cd ichorCNA && \
    R CMD INSTALL . && \
    cd /opt 

RUN apt-get install -y cmake

RUN cd /opt && \
    git clone https://github.com/shahcompbio/hmmcopy_utils.git && \
    cd hmmcopy_utils && \
    cmake . && \
    make 
##NEED edger, limma, gage, dseq2, wgcna
#RUN add-apt-repository --remove ppa:
RUN apt-get update
RUN apt-get install -qq parallel

RUN R -e 'install.packages("BiocManager"); BiocManager::install(); BiocManager::install("DNAcopy");'
#
#########1#########2#########3#########4#########5#########6#########7######
#TESTING
#
#RUN conda install -c bioconda tophat
#RUN conda install -c bioconda cnvkit
#RUN conda install -c bioconda manta
#RUN conda install -c bioconda lumpy-sv
#RUN conda install -c bioconda multiqc
#RUN conda install -c bioconda flexbar
###8
# #
# ### LUMPY
# # from https://raw.githubusercontent.com/zlskidmore/docker-lumpy/master/Dockerfile
# # RUN apt-get update -qq
# # RUN apt-get install -qq --no-install-recommends \
# # python-pip \
# # git \
# # cmake \
# # build-essential \
# # libz-dev
# # RUN cd /opt && git clone https://github.com/hall-lab/lumpy-sv.git && cd /opt/lumpy-sv && make
# #########1#########2#########3#########4#########5#########6#########7#########8
# ### Samtools 
# RUN apt-get update -qq
# RUN apt-get install -qq --no-install-recommends \
# wget \ 
# bzip2 \
# cmake \
# gcc \
# zlib1g-dev \
# libncurses5-dev 


# ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
# WORKDIR /tmp
# RUN wget --no-check-certificate https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
# tar --bzip2 -xf samtools-1.9.tar.bz2 && \
# cd /tmp/samtools-1.9 && \
# ./configure --prefix=$SAMTOOLS_INSTALL_DIR && \
# make && \
# make install && \
# cd / && \
# rm -rf /tmp/samtools-1.9 && \
# ln -s /opt/samtools/bin/* /usr/bin/

# # # WORKDIR /usr/local/bin/
# # # RUN curl -SL https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2 \
# # #     > /usr/local/bin/samtools-${samtools_version}.tar.bz2
# # # RUN tar -xjf /usr/local/bin/samtools-${samtools_version}.tar.bz2 -C /usr/local/bin/
# # # RUN cd /usr/local/bin/samtools-${samtools_version}/ && ./configure
# # # RUN cd /usr/local/bin/samtools-${samtools_version}/ && make
# # # RUN cd /usr/local/bin/samtools-${samtools_version}/ && make install

# # # # install lumpy
# # # WORKDIR /usr/local/bin
# # # RUN wget https://github.com/arq5x/lumpy-sv/releases/download/${lumpy_version}/lumpy-sv.tar.gz
# # # RUN tar -xzvf lumpy-sv.tar.gz
# # # WORKDIR /usr/local/bin/lumpy-sv
# # # RUN make
# # # RUN ln -s /usr/local/bin/lumpy-sv/bin/lumpy /usr/local/bin/lumpy
# # # RUN ln -s /usr/local/bin/lumpy-sv/bin/lumpy_filter /usr/local/bin/lumpy_filter
# # # RUN ln -s /usr/local/bin/lumpy-sv/bin/lumpyexpress /usr/local/bin/lumpyexpress
# # # https://github.com/hall-lab/sv-pipeline/blob/master/docker/lumpy/Dockerfile
# # # Build dependencies
# # RUN apt-get update -qq \
# #     && apt-get -y install \
# #         apt-transport-https \
# #         g++ \
# # 	gawk \
# #         libcurl4-gnutls-dev \
# #         autoconf \
# # 	libssl-dev \
# #         git 
  
# #########1#########2#########3#########4#########5#########6#########7#########8


# # ###############
# # #bam-readcount#
# # ###############
# # # ENV SAMTOOLS_ROOT=/opt/samtools
# # # RUN apt-get update && apt-get install -y --no-install-recommends \
# # #         cmake \
# # #         patch && \
# # #     mkdir /opt/bam-readcount && \
# # #     cd /opt/bam-readcount && \
# # #     git clone https://github.com/genome/bam-readcount.git /tmp/bam-readcount-0.7.4 && \
# # #     git -C /tmp/bam-readcount-0.7.4 checkout v0.7.4 && \
# # #     cmake /tmp/bam-readcount-0.7.4 && \
# # #     make && \
# # #     rm -rf /tmp/bam-readcount-0.7.4 && \
# # #     ln -s /opt/bam-readcount/bin/bam-readcount /usr/bin/bam-readcount

# # # #note - this script needs cyvcf - installed in the python secetion!
# # # COPY bam_readcount_helper.py /usr/bin/bam_readcount_helper.py


# # # #############
# # # ## IGV 3.0 ##

# # # RUN apt-get update && apt-get install -y --no-install-recommends \
# # #     software-properties-common \
# # #     glib-networking-common && \
# # #     mkdir -p /igv && \
# # #     cd /igv && \
# # #     wget http://data.broadinstitute.org/igv/projects/downloads/3.0_beta/IGV_3.0_beta.zip && \
# # #     unzip IGV_3.0_beta.zip && \
# # #     cd IGV_3.0_beta && \
# # #     sed -i 's/Xmx4000/Xmx8000/g' igv.sh && \
# # #     cd /usr/bin && \
# # #     ln -s /igv/IGV_3.0_beta/igv.sh ./igv

# # ##############
# # ## bedtools ##

# # WORKDIR /usr/local
# # RUN git clone https://github.com/arq5x/bedtools2.git && \
# #     cd /usr/local/bedtools2 && \
# #     git checkout v2.25.0 && \
# #     make && \
# #     ln -s /usr/local/bedtools2/bin/* /usr/local/bin/


# # ##############
# # ## vcftools ##
# # ENV ZIP=vcftools-0.1.14.tar.gz
# # ENV URL=https://github.com/vcftools/vcftools/releases/download/v0.1.14/
# # ENV FOLDER=vcftools-0.1.14
# # ENV DST=/tmp

# # RUN wget $URL/$ZIP -O $DST/$ZIP && \
# #     tar xvf $DST/$ZIP -C $DST && \
# #     rm $DST/$ZIP && \
# #     cd $DST/$FOLDER && \
# #     ./configure && \
# #     make && \
# #     make install && \
# #     cd / && \
# #     rm -rf $DST/$FOLDER


# # ##################
# # # ucsc utilities #
# # RUN mkdir -p /tmp/ucsc && \
# #     cd /tmp/ucsc && \
# #     wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigBedToBed http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigWigAverageOverBed http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigWigToBedGraph http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/wigToBigWig && \
# #     chmod ugo+x * && \
# #     mv * /usr/bin/


# # ############################
# # # R, bioconductor packages #
# # # from https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/r-ver/3.4.0/Dockerfile
# # # we'll pin to 3.4.0 for now

# # # ARG R_VERSION
# # # ARG BUILD_DATE
# # # ENV BUILD_DATE 2017-06-20
# # # ENV R_VERSION=${R_VERSION:-3.4.0}
# # # RUN apt-get update && apt-get install -y --no-install-recommends locales && \
# # #     echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
# # #     locale-gen en_US.UTF-8 && \
# # #     LC_ALL=en_US.UTF-8 && \
# # #     LANG=en_US.UTF-8 && \
# # #     /usr/sbin/update-locale LANG=en_US.UTF-8 && \
# # #     TERM=xterm && \
# # #     apt-get install -y --no-install-recommends \
# # #     bash-completion \
# # #     ca-certificates \
# # #     file \
# # #     fonts-texgyre \
# # #     g++ \
# # #     gfortran \
# # #     gsfonts \
# # #     libbz2-1.0 \
# # #     libcurl3 \
# # #     libicu55 \
# # #     libjpeg-turbo8 \
# # #     libopenblas-dev \
# # #     libpangocairo-1.0-0 \
# # #     libpcre3 \
# # #     libpng12-0 \
# # #     libtiff5 \
# # #     liblzma5 \
# # #     locales \
# # #     zlib1g \
# # #     libbz2-dev \
# # #     libcairo2-dev \
# # #     libcurl4-openssl-dev \
# # #     libpango1.0-dev \
# # #     libjpeg-dev \
# # #     libicu-dev \
# # #     libmariadb-client-lgpl-dev \
# # #     libmysqlclient-dev \
# # #     libpcre3-dev \
# # #     libpng-dev \
# # #     libreadline-dev \
# # #     libtiff5-dev \
# # #     liblzma-dev \
# # #     libx11-dev \
# # #     libxt-dev \
# # #     perl \
# # #     tcl8.5-dev \
# # #     tk8.5-dev \
# # #     texinfo \
# # #     texlive-extra-utils \
# # #     texlive-fonts-recommended \
# # #     texlive-fonts-extra \
# # #     texlive-latex-recommended \
# # #     x11proto-core-dev \
# # #     xauth \
# # #     xfonts-base \
# # #     xvfb \
# # #     zlib1g-dev && \
# # #     cd /tmp/ && \
# # #     ## Download source code
# # #     curl -O https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz && \
# # #     ## Extract source code
# # #     tar -xf R-${R_VERSION}.tar.gz && \
# # #     cd R-${R_VERSION} && \
# # #     ## Set compiler flags
# # #     R_PAPERSIZE=letter && \
# # #     R_BATCHSAVE="--no-save --no-restore" && \
# # #     R_BROWSER=xdg-open && \
# # #     PAGER=/usr/bin/pager && \
# # #     PERL=/usr/bin/perl && \
# # #     R_UNZIPCMD=/usr/bin/unzip && \
# # #     R_ZIPCMD=/usr/bin/zip && \
# # #     R_PRINTCMD=/usr/bin/lpr && \
# # #     LIBnn=lib && \
# # #     AWK=/usr/bin/awk && \
# # #     CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" && \
# # #     CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" && \
# # #     ## Configure options
# # #     ./configure --enable-R-shlib \
# # #                --enable-memory-profiling \
# # #                --with-readline \
# # #                --with-blas="-lopenblas" \
# # #                --disable-nls \
# # #                --without-recommended-packages && \
# # #     ## Build and install
# # #     make && \
# # #     make install && \
# # #     ## Add a default CRAN mirror
# # #     echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site && \
# # #     ## Add a library directory (for user-installed packages)
# # #     mkdir -p /usr/local/lib/R/site-library && \
# # #     chown root:staff /usr/local/lib/R/site-library && \
# # #     chmod g+wx /usr/local/lib/R/site-library && \
# # #     ## Fix library path
# # #     echo "R_LIBS_USER='/usr/local/lib/R/site-library'" >> /usr/local/lib/R/etc/Renviron && \
# # #     echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron && \
# # #     ## install packages from date-locked MRAN snapshot of CRAN
# # #     [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true && \
# # #     MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} && \
# # #     echo MRAN=$MRAN >> /etc/environment && \
# # #     export MRAN=$MRAN && \
# # #     echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site && \
# # #     ## Use littler installation scripts
# # #     Rscript -e "install.packages(c('littler', 'docopt'), repo = '$MRAN')" && \
# # #     ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r && \
# # #     ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r && \
# # #     ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r

# # #    ## install r packages, bioconductor, etc ##
# # #    ADD rpackages.R /tmp/
# # #    RUN R -f /tmp/rpackages.R && \
# # #    ## install fishplot ##
# # #    cd /tmp/ && \
# # #     wget https://github.com/chrisamiller/fishplot/archive/v0.4.tar.gz && \
# # #     mv v0.4.tar.gz fishplot_0.4.tar.gz && \
# # #     R CMD INSTALL fishplot_0.4.tar.gz && \
# # #     cd && rm -rf /tmp/fishplot_0.4.tar.gz

# # #    ## Clean up
# # #    RUN cd / && \
# # #    rm -rf /tmp/* && \
# # #    apt-get autoremove -y && \
# # #    apt-get autoclean -y && \
# # #    rm -rf /var/lib/apt/lists/* && \
# # #    apt-get clean

# # # #################################
# # # # Python 2 and 3, plus packages

# # # # Configure environment
# # # ENV CONDA_DIR /opt/conda
# # # ENV PATH $CONDA_DIR/bin:$PATH

# # # # Install conda
# # # RUN cd /tmp && \
# # #     mkdir -p $CONDA_DIR && \
# # #     curl -s https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh -o miniconda.sh && \
# # #     /bin/bash miniconda.sh -f -b -p $CONDA_DIR && \
# # #     rm miniconda.sh && \
# # #     $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
# # #     $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
# # #     conda clean -tipsy

# # # # Install Python 3 packages available through pip
# # # RUN conda install --yes 'pip' && \
# # #     conda clean -tipsy && \
# # #     #dependencies sometimes get weird - installing each on it's own line seems to help
# # #     pip install numpy==1.13.0 && \
# # #     pip install scipy==0.19.0 && \
# # #     pip install cruzdb==0.5.6 && \
# # #     pip install cython==0.25.2 && \
# # #     pip install pyensembl==1.1.0 && \
# # #     pip install pyfaidx==0.4.9.2 && \
# # #     pip install pybedtools==0.7.10 && \
# # #     pip install cyvcf2==0.7.4 && \
# # #     pip install intervaltree_bio==1.0.1 && \
# # #     pip install pandas==0.20.2 && \
# # #     pip install scipy==0.19.0 && \
# # #     pip install pysam==0.11.2.2 && \
# # #     pip install seaborn==0.7.1 && \
# # #     pip install scikit-learn==0.18.2 && \
# # #     pip install svviz==1.6.1

# # # # Install Python 2
# # # RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 'pip' && \
# # #     conda clean -tipsy && \
# # #     /bin/bash -c "source activate python2 && \
# # #     #dependencies sometimes get weird - installing each on it's own line seems to help
# # #     pip install numpy==1.13.0 && \
# # #     pip install scipy==0.19.0 && \
# # #     pip install cruzdb==0.5.6 && \
# # #     pip install cython==0.25.2 && \
# # #     pip install pyensembl==1.1.0 && \
# # #     pip install pyfaidx==0.4.9.2 && \
# # #     pip install pybedtools==0.7.10 && \
# # #     pip install cyvcf2==0.7.4 && \
# # #     pip install intervaltree_bio==1.0.1 && \
# # #     pip install pandas==0.20.2 && \
# # #     pip install scipy==0.19.0 && \
# # #     pip install pysam==0.11.2.2 && \
# # #     pip install seaborn==0.7.1 && \
# # #     pip install scikit-learn==0.18.2 && \
# # #     pip install openpyxl==2.4.8 && \
# # #     source deactivate"

# # # COPY tsv2xlsx.py /usr/bin/tsv2xlsx.py

# # # needed for MGI data mounts
# # RUN apt-get update && apt-get install -y libnss-sss && apt-get clean all

# # #set timezone to CDT
# # #LSF: Java bug that need to change the /etc/timezone.
# # #/etc/localtime is not enough.
# # # RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
# # #     echo "America/Chicago" > /etc/timezone && \
# # #     dpkg-reconfigure --frontend noninteractive tzdata

# # #UUID is needed to be set for some applications
# # RUN apt-get update && apt-get install -y dbus && apt-get clean all
# # RUN dbus-uuidgen >/etc/machine-id

# # # WORKS TO HERE
# # ENV PATH /opt/conda/bin:$PATH

# # RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
# #     libglib2.0-0 libxext6 libsm6 libxrender1 \
# #     git mercurial subversion

# # RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
# #     /bin/bash ~/miniconda.sh -b -p /opt/conda && \
# #     rm ~/miniconda.sh && \
# #     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
# #     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
# #     echo "conda activate base" >> ~/.bashrc

# # RUN apt-get install -y curl grep sed dpkg && \
# #     TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
# #     curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
# #     dpkg -i tini.deb && \
# #     rm tini.deb && \
# #     apt-get clean


# # RUN conda install -c bioconda sambamba 

# # # WORKDIR /opt

# # # RUN apt-get update && apt-get install -y \
# # # 	autoconf \
# # # 	automake \
# # # 	make \
# # # 	g++ \
# # # 	gcc \
# # # 	build-essential \ 
# # # 	zlib1g-dev \
# # # 	libgsl0-dev \
# # # 	perl \
# # # 	curl \
# # # 	git \
# # # 	wget \
# # # 	unzip \
# # # 	tabix \
# # # 	libncurses5-dev

# # # RUN wget https://github.com/ldc-developers/ldc/releases/download/v0.17.1/ldc2-0.17.1-linux-x86_64.tar.xz && \
# # #   tar xJf ldc2-0.17.1-linux-x86_64.tar.xz

# # # ENV PATH=/opt/ldc2-0.17.1-linux-x86_64/bin/:$PATH
# # # ENV LIBRARY_PATH=/opt/ldc2-0.17.1-linux-x86_64/lib/

# # # #RUN wget https://github.com/biod/sambamba/releases/download/v0.7.0/sambamba-0.7.0-linux-static.gz && \
# # # tar xJf sambamba-0.7.0-linux-static.gz

# # # RUN git clone --recursive https://github.com/lomereiter/sambamba.git && cd WHERE && make


# # RUN conda install -c bioconda samtools


# # ## bioconductor R install
# # # nuke cache dirs before installing pkgs; tip from Dirk E fixes broken img
# # RUN rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*

# # # same set of packages for both devel and release
# # RUN apt-get update && \
# # 	apt-get -y --no-install-recommends install --fix-missing \
# # 	gdb \
# # 	libxml2-dev \
# # 	python-pip \
# # 	libz-dev \
# # 	liblzma-dev \
# # 	libbz2-dev \
# # 	libpng-dev \
# # 	libmariadb-client-lgpl-dev \
# # 	&& rm -rf /var/lib/apt/lists/*

# # # issues with '/var/lib/dpkg/available' not found
# # # this will recreate
# # RUN dpkg --clear-avail


# # # # Add bioc user as requested
# # # RUN useradd -ms /bin/bash -d /home/bioc bioc \
# # # 	&& echo "bioc:bioc" | chpasswd && adduser bioc sudo
# # # USER bioc
# # # RUN mkdir -p /home/bioc/R/library && \
# # # 	echo "R_LIBS=/usr/local/lib/R/host-site-library:~/R/library" | cat > /home/bioc/.Renviron
# # # USER root
# # # RUN echo "R_LIBS=/usr/local/lib/R/host-site-library:\${R_LIBS}" > /usr/local/lib/R/etc/Renviron.site \
# # # 	&& echo "R_LIBS_USER=''" >> /usr/local/lib/R/etc/Renviron.site \
# # # 	&& echo "options(defaultPackages=c(getOption('defaultPackages'),'BiocManager'))" >> /usr/local/lib/R/etc/Rprofile.site

# # # # add R packages test
# # # RUN R -e "install.packages('methods',dependencies=TRUE, repos='http://cran.rstudio.com/')"
# # # RUN R -e "install.packages('jsonlite',dependencies=TRUE, repos='http://cran.rstudio.com/')"
# # # RUN R -e "install.packages('tseries',dependencies=TRUE, repos='http://cran.rstudio.com/')"


# # # RSEM
# # #Install Bowtie 
# # RUN conda install -c bioconda bowtie2

# # # # Install RSEM 
# # # WORKDIR /usr/local/
# # # RUN pwd
# # # RUN git clone https://github.com/deweylab/RSEM.git
# # # WORKDIR /usr/local/RSEM
# # # RUN pwd
# # # RUN git checkout v1.2.28
# # # RUN make 
# # # RUN make ebseq
# # # ENV PATH /usr/local/RSEM:$PATH

# # # # install skewer
# # # RUN \
# # #   wget -c https://downloads.sourceforge.net/project/skewer/Binaries/skewer-0.2.2-linux-x86_64 && \
# # #   chmod +x skewer-0.2.2-linux-x86_64 && \
# # #   cp skewer-0.2.2-linux-x86_64 /usr/local/bin/skewer

# # # run update and install necessary tools
# # RUN apt-get update -y && apt-get install -y \
# #     build-essential \
# # RUN apt-get install -y software-properties-common
# # RUN add-apt-repository -y ppa:jonathonf/python-3.6 
# # RUN apt-get update && apt-get install -y python3.6 

