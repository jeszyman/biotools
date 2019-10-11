FROM ubuntu:xenial

#########1#########2#########3#########4#########5#########6#########7#########8
#################### VALIDATED BELOW THIS POINT  ###############################
# last successful build 2019-10-07 17:30 CST
#########1#########2#########3#########4#########5#########6#########7#########8

# from https://raw.githubusercontent.com/zlskidmore/docker-lumpy/master/Dockerfile
# set the environment variables
ENV lumpy_version 0.3.0
ENV samblaster_version 0.1.24
ENV sambamba_version 0.6.9
ENV samtools_version 1.9

# run update and install necessary tools
RUN apt-get update -y && apt-get install -y \
    build-essential \
    libnss-sss \
    curl \
    vim \
    less \
    wget \
    unzip \
    cmake \
    python \
    gawk \
    python-pip \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libnss-sss \
    libbz2-dev \
    liblzma-dev \
    bzip2 \
    libcurl4-openssl-dev \
    libssl-dev \
    git \
    autoconf

RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:jonathonf/python-3.6 
RUN apt-get update && apt-get install -y python3.6 

# install numpy and pysam
RUN pip install --upgrade setuptools
RUN pip install ez_setup
RUN python -m pip install --upgrade pip
WORKDIR /usr/local/bin
RUN pip install "numpy"


RUN pip install pysam

# install samblaster
WORKDIR /usr/local/bin
RUN wget https://github.com/GregoryFaust/samblaster/archive/v.${samblaster_version}.zip
RUN unzip v.${samblaster_version}.zip
WORKDIR /usr/local/bin/samblaster-v.${samblaster_version}
RUN make
RUN ln -s /usr/local/bin/samblaster-v.${samblaster_version}/samblaster /usr/local/bin/samblaster

# install sambamba
WORKDIR /usr/local/bin
RUN wget https://github.com/biod/sambamba/releases/download/v${sambamba_version}/sambamba-${sambamba_version}-linux-static.gz
RUN gunzip sambamba-${sambamba_version}-linux-static.gz
RUN chmod a+x sambamba-${sambamba_version}-linux-static
RUN ln -s sambamba-${sambamba_version}-linux-static sambamba

# install samtools
WORKDIR /usr/local/bin/
RUN curl -SL https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2 \
    > /usr/local/bin/samtools-${samtools_version}.tar.bz2
RUN tar -xjf /usr/local/bin/samtools-${samtools_version}.tar.bz2 -C /usr/local/bin/
RUN cd /usr/local/bin/samtools-${samtools_version}/ && ./configure
RUN cd /usr/local/bin/samtools-${samtools_version}/ && make
RUN cd /usr/local/bin/samtools-${samtools_version}/ && make install

# install lumpy
WORKDIR /usr/local/bin
RUN wget https://github.com/arq5x/lumpy-sv/releases/download/${lumpy_version}/lumpy-sv.tar.gz
RUN tar -xzvf lumpy-sv.tar.gz
WORKDIR /usr/local/bin/lumpy-sv
RUN make
RUN ln -s /usr/local/bin/lumpy-sv/bin/lumpy /usr/local/bin/lumpy
RUN ln -s /usr/local/bin/lumpy-sv/bin/lumpy_filter /usr/local/bin/lumpy_filter
RUN ln -s /usr/local/bin/lumpy-sv/bin/lumpyexpress /usr/local/bin/lumpyexpress
WORKDIR /usr/local/bin

# set default command
CMD ["lumpy --help"]
#
# manta
FROM debian:stretch-slim AS manta-build
LABEL maintainer "Dave Larson <delarson@wustl.edu>"
ARG MANTA_VERSION=1.4.0
COPY --from=halllab/python2.7-build:v1 /opt/hall-lab/python-2.7.15 /opt/hall-lab/python-2.7.15
ENV PATH=/opt/hall-lab/python-2.7.15/bin:${PATH}
RUN apt-get update -qq \
    && apt-get -y install \
        --no-install-recommends \
        build-essential \
        bzip2 \
        zlib1g-dev \
        curl \
        ca-certificates
RUN curl -O -L https://github.com/Illumina/manta/releases/download/v${MANTA_VERSION}/manta-${MANTA_VERSION}.release_src.tar.bz2 \
    && tar -xjf manta-${MANTA_VERSION}.release_src.tar.bz2 \
    && mkdir build \
    && cd build \
    && ../manta-${MANTA_VERSION}.release_src/configure --prefix=/opt/hall-lab/manta-${MANTA_VERSION} \
    && make -j 4 install
RUN find /opt/hall-lab/python-2.7.15/ -depth \( -name '*.pyo' -o -name '*.pyc' -o -name 'test' -o -name 'tests' \) -exec rm -rf '{}' + ;
RUN find /opt/hall-lab/python-2.7.15/lib/python2.7/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \;

FROM debian:stretch-slim
LABEL maintainer "Dave Larson <delarson@wustl.edu>"
ARG MANTA_VERSION=1.4.0

COPY --from=manta-build /opt/hall-lab/manta-${MANTA_VERSION}/bin /opt/hall-lab/manta-${MANTA_VERSION}/bin
COPY --from=manta-build /opt/hall-lab/manta-${MANTA_VERSION}/lib /opt/hall-lab/manta-${MANTA_VERSION}/lib
COPY --from=manta-build /opt/hall-lab/manta-${MANTA_VERSION}/libexec /opt/hall-lab/manta-${MANTA_VERSION}/libexec
COPY --from=manta-build /opt/hall-lab/python-2.7.15 /opt/hall-lab/python-2.7.15

# Run dependencies
RUN apt-get update -qq \
    && apt-get -y install \
        --no-install-recommends \
        libssl1.1 \
        libcurl3 \
        libbz2-1.0 \ 
        liblzma5 \ 
        libssl1.0.2 \
        zlib1g

ENV PATH=/opt/hall-lab/manta-${MANTA_VERSION}/bin:/opt/hall-lab/python-2.7.15/bin/:$PATH

CMD ["/bin/bash"]

#########1#########2#########3#########4#########5#########6#########7#########8
# BUILDS ABOVE THIS POINT VALIDATED INDEPENDENTLY 
#########1#########2#########3#########4#########5#########6#########7#########8
#####
# STAR

ADD https://raw.githubusercontent.com/dceoy/print-github-tags/master/print-github-tags /usr/local/bin/print-github-tags

RUN set -e \
      && apt-get -y update \
      && apt-get -y dist-upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates curl g++ gcc libz-dev make \
      && apt-get -y autoremove \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN set -e \
      && chmod +x /usr/local/bin/print-github-tags \
      && print-github-tags --release --latest --tar alexdobin/STAR \
        | xargs -i curl -SL {} -o /tmp/star.tar.gz \
      && tar xvf /tmp/star.tar.gz -C /usr/local/src --remove-files \
      && mv /usr/local/src/STAR-* /usr/local/src/STAR \
      && cd /usr/local/src/STAR/source \
      && make STAR \
      && ln -s /usr/local/src/STAR/source/STAR /usr/local/bin/STAR

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    bzip2 \
    curl \
    csh \
#   default-jdk \
#   default-jre \
#   emacs \
#   emacs-goodies-el \
#   evince \
    g++ \
    gawk \
    git \
    grep \
    less \
    libcurl4-openssl-dev \
    libpng-dev \
    librsvg2-bin \
    libssl-dev \
    libxml2-dev \
    lsof \
    make \
    man \
    ncurses-dev \
    nodejs \
    openssh-client \
    pdftk \
    pkg-config \
    python \
    rsync \
    screen \
    tabix \
    unzip \
    wget \
    zip \
    zlib1g-dev

##############
#HTSlib 1.3.2#
##############
# ENV HTSLIB_INSTALL_DIR=/opt/htslib
# WORKDIR /tmp
# RUN wget https://github.com/samtools/htslib/releases/download/1.3.2/htslib-1.3.2.tar.bz2 && \
#     tar --bzip2 -xvf htslib-1.3.2.tar.bz2 && \
#     cd /tmp/htslib-1.3.2 && \
#     ./configure  --enable-plugins --prefix=$HTSLIB_INSTALL_DIR && \
#     make && \
#     make install && \
#     cp $HTSLIB_INSTALL_DIR/lib/libhts.so* /usr/lib/ && \
#     ln -s $HTSLIB_INSTALL_DIR/bin/tabix /usr/bin/tabix

################
#Samtools 1.9  #
################

# ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
# WORKDIR /tmp
# RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
#     tar --bzip2 -xf samtools-1.9.tar.bz2 && \
#     cd /tmp/samtools-1.9 && \
#     ./configure --with-htslib=$HTSLIB_INSTALL_DIR --prefix=$SAMTOOLS_INSTALL_DIR && \
#     make && \
#     make install && \
#     cd / && \
#     rm -rf /tmp/samtools-1.9 && \
#     ln -s /opt/samtools/bin/* /usr/bin/

###############
#bam-readcount#
###############
# ENV SAMTOOLS_ROOT=/opt/samtools
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         cmake \
#         patch && \
#     mkdir /opt/bam-readcount && \
#     cd /opt/bam-readcount && \
#     git clone https://github.com/genome/bam-readcount.git /tmp/bam-readcount-0.7.4 && \
#     git -C /tmp/bam-readcount-0.7.4 checkout v0.7.4 && \
#     cmake /tmp/bam-readcount-0.7.4 && \
#     make && \
#     rm -rf /tmp/bam-readcount-0.7.4 && \
#     ln -s /opt/bam-readcount/bin/bam-readcount /usr/bin/bam-readcount

# #note - this script needs cyvcf - installed in the python secetion!
# COPY bam_readcount_helper.py /usr/bin/bam_readcount_helper.py

################
#bcftools 1.3.1#
################
ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools
WORKDIR /tmp
RUN wget https://github.com/samtools/bcftools/releases/download/1.3.1/bcftools-1.3.1.tar.bz2 && \
    tar --bzip2 -xf bcftools-1.3.1.tar.bz2 && \
    cd /tmp/bcftools-1.3.1 && \
    make prefix=$BCFTOOLS_INSTALL_DIR && \
    make prefix=$BCFTOOLS_INSTALL_DIR install && \
    cd / && \
    rm -rf /tmp/bcftools-1.3.1


##############
#Picard 2.4.1#
##############

# ENV picard_version 2.4.1

# # Assumes Dockerfile lives in root of the git repo. Pull source files into
# # container
# RUN apt-get update && apt-get install ant --no-install-recommends -y && \
#     cd /usr/ && \
#     git config --global http.sslVerify false && \
#     git clone --recursive https://github.com/broadinstitute/picard.git && \
#     cd /usr/picard && \
#     git checkout tags/${picard_version} && \
#     cd /usr/picard && \
#     # Clone out htsjdk. First turn off git ssl verification
#     git config --global http.sslVerify false && \
#     git clone https://github.com/samtools/htsjdk.git && \
#     cd htsjdk && \
#     git checkout tags/${picard_version} && \
#     cd .. && \
#     # Build the distribution jar, clean up everything else
#     ant clean all && \
#     mv dist/picard.jar picard.jar && \
#     mv src/scripts/picard/docker_helper.sh docker_helper.sh && \
#     ant clean && \
#     rm -rf htsjdk && \
#     rm -rf src && \
#     rm -rf lib && \
#     rm build.xml

# # COPY split_interval_list_helper.pl /usr/bin/split_interval_list_helper.pl


# #############
# ## IGV 3.0 ##

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     software-properties-common \
#     glib-networking-common && \
#     mkdir -p /igv && \
#     cd /igv && \
#     wget http://data.broadinstitute.org/igv/projects/downloads/3.0_beta/IGV_3.0_beta.zip && \
#     unzip IGV_3.0_beta.zip && \
#     cd IGV_3.0_beta && \
#     sed -i 's/Xmx4000/Xmx8000/g' igv.sh && \
#     cd /usr/bin && \
#     ln -s /igv/IGV_3.0_beta/igv.sh ./igv

##############
## bedtools ##

WORKDIR /usr/local
RUN git clone https://github.com/arq5x/bedtools2.git && \
    cd /usr/local/bedtools2 && \
    git checkout v2.25.0 && \
    make && \
    ln -s /usr/local/bedtools2/bin/* /usr/local/bin/


##############
## vcftools ##
ENV ZIP=vcftools-0.1.14.tar.gz
ENV URL=https://github.com/vcftools/vcftools/releases/download/v0.1.14/
ENV FOLDER=vcftools-0.1.14
ENV DST=/tmp

RUN wget $URL/$ZIP -O $DST/$ZIP && \
    tar xvf $DST/$ZIP -C $DST && \
    rm $DST/$ZIP && \
    cd $DST/$FOLDER && \
    ./configure && \
    make && \
    make install && \
    cd / && \
    rm -rf $DST/$FOLDER


##################
# ucsc utilities #
RUN mkdir -p /tmp/ucsc && \
    cd /tmp/ucsc && \
    wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigBedToBed http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigWigAverageOverBed http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigWigToBedGraph http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/wigToBigWig && \
    chmod ugo+x * && \
    mv * /usr/bin/


############################
# R, bioconductor packages #
# from https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/r-ver/3.4.0/Dockerfile
# we'll pin to 3.4.0 for now

# ARG R_VERSION
# ARG BUILD_DATE
# ENV BUILD_DATE 2017-06-20
# ENV R_VERSION=${R_VERSION:-3.4.0}
# RUN apt-get update && apt-get install -y --no-install-recommends locales && \
#     echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
#     locale-gen en_US.UTF-8 && \
#     LC_ALL=en_US.UTF-8 && \
#     LANG=en_US.UTF-8 && \
#     /usr/sbin/update-locale LANG=en_US.UTF-8 && \
#     TERM=xterm && \
#     apt-get install -y --no-install-recommends \
#     bash-completion \
#     ca-certificates \
#     file \
#     fonts-texgyre \
#     g++ \
#     gfortran \
#     gsfonts \
#     libbz2-1.0 \
#     libcurl3 \
#     libicu55 \
#     libjpeg-turbo8 \
#     libopenblas-dev \
#     libpangocairo-1.0-0 \
#     libpcre3 \
#     libpng12-0 \
#     libtiff5 \
#     liblzma5 \
#     locales \
#     zlib1g \
#     libbz2-dev \
#     libcairo2-dev \
#     libcurl4-openssl-dev \
#     libpango1.0-dev \
#     libjpeg-dev \
#     libicu-dev \
#     libmariadb-client-lgpl-dev \
#     libmysqlclient-dev \
#     libpcre3-dev \
#     libpng-dev \
#     libreadline-dev \
#     libtiff5-dev \
#     liblzma-dev \
#     libx11-dev \
#     libxt-dev \
#     perl \
#     tcl8.5-dev \
#     tk8.5-dev \
#     texinfo \
#     texlive-extra-utils \
#     texlive-fonts-recommended \
#     texlive-fonts-extra \
#     texlive-latex-recommended \
#     x11proto-core-dev \
#     xauth \
#     xfonts-base \
#     xvfb \
#     zlib1g-dev && \
#     cd /tmp/ && \
#     ## Download source code
#     curl -O https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz && \
#     ## Extract source code
#     tar -xf R-${R_VERSION}.tar.gz && \
#     cd R-${R_VERSION} && \
#     ## Set compiler flags
#     R_PAPERSIZE=letter && \
#     R_BATCHSAVE="--no-save --no-restore" && \
#     R_BROWSER=xdg-open && \
#     PAGER=/usr/bin/pager && \
#     PERL=/usr/bin/perl && \
#     R_UNZIPCMD=/usr/bin/unzip && \
#     R_ZIPCMD=/usr/bin/zip && \
#     R_PRINTCMD=/usr/bin/lpr && \
#     LIBnn=lib && \
#     AWK=/usr/bin/awk && \
#     CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" && \
#     CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" && \
#     ## Configure options
#     ./configure --enable-R-shlib \
#                --enable-memory-profiling \
#                --with-readline \
#                --with-blas="-lopenblas" \
#                --disable-nls \
#                --without-recommended-packages && \
#     ## Build and install
#     make && \
#     make install && \
#     ## Add a default CRAN mirror
#     echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site && \
#     ## Add a library directory (for user-installed packages)
#     mkdir -p /usr/local/lib/R/site-library && \
#     chown root:staff /usr/local/lib/R/site-library && \
#     chmod g+wx /usr/local/lib/R/site-library && \
#     ## Fix library path
#     echo "R_LIBS_USER='/usr/local/lib/R/site-library'" >> /usr/local/lib/R/etc/Renviron && \
#     echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron && \
#     ## install packages from date-locked MRAN snapshot of CRAN
#     [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true && \
#     MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} && \
#     echo MRAN=$MRAN >> /etc/environment && \
#     export MRAN=$MRAN && \
#     echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site && \
#     ## Use littler installation scripts
#     Rscript -e "install.packages(c('littler', 'docopt'), repo = '$MRAN')" && \
#     ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r && \
#     ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r && \
#     ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r

#    ## install r packages, bioconductor, etc ##
#    ADD rpackages.R /tmp/
#    RUN R -f /tmp/rpackages.R && \
#    ## install fishplot ##
#    cd /tmp/ && \
#     wget https://github.com/chrisamiller/fishplot/archive/v0.4.tar.gz && \
#     mv v0.4.tar.gz fishplot_0.4.tar.gz && \
#     R CMD INSTALL fishplot_0.4.tar.gz && \
#     cd && rm -rf /tmp/fishplot_0.4.tar.gz

#    ## Clean up
#    RUN cd / && \
#    rm -rf /tmp/* && \
#    apt-get autoremove -y && \
#    apt-get autoclean -y && \
#    rm -rf /var/lib/apt/lists/* && \
#    apt-get clean

# #################################
# # Python 2 and 3, plus packages

# # Configure environment
# ENV CONDA_DIR /opt/conda
# ENV PATH $CONDA_DIR/bin:$PATH

# # Install conda
# RUN cd /tmp && \
#     mkdir -p $CONDA_DIR && \
#     curl -s https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh -o miniconda.sh && \
#     /bin/bash miniconda.sh -f -b -p $CONDA_DIR && \
#     rm miniconda.sh && \
#     $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
#     $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
#     conda clean -tipsy

# # Install Python 3 packages available through pip
# RUN conda install --yes 'pip' && \
#     conda clean -tipsy && \
#     #dependencies sometimes get weird - installing each on it's own line seems to help
#     pip install numpy==1.13.0 && \
#     pip install scipy==0.19.0 && \
#     pip install cruzdb==0.5.6 && \
#     pip install cython==0.25.2 && \
#     pip install pyensembl==1.1.0 && \
#     pip install pyfaidx==0.4.9.2 && \
#     pip install pybedtools==0.7.10 && \
#     pip install cyvcf2==0.7.4 && \
#     pip install intervaltree_bio==1.0.1 && \
#     pip install pandas==0.20.2 && \
#     pip install scipy==0.19.0 && \
#     pip install pysam==0.11.2.2 && \
#     pip install seaborn==0.7.1 && \
#     pip install scikit-learn==0.18.2 && \
#     pip install svviz==1.6.1

# # Install Python 2
# RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 'pip' && \
#     conda clean -tipsy && \
#     /bin/bash -c "source activate python2 && \
#     #dependencies sometimes get weird - installing each on it's own line seems to help
#     pip install numpy==1.13.0 && \
#     pip install scipy==0.19.0 && \
#     pip install cruzdb==0.5.6 && \
#     pip install cython==0.25.2 && \
#     pip install pyensembl==1.1.0 && \
#     pip install pyfaidx==0.4.9.2 && \
#     pip install pybedtools==0.7.10 && \
#     pip install cyvcf2==0.7.4 && \
#     pip install intervaltree_bio==1.0.1 && \
#     pip install pandas==0.20.2 && \
#     pip install scipy==0.19.0 && \
#     pip install pysam==0.11.2.2 && \
#     pip install seaborn==0.7.1 && \
#     pip install scikit-learn==0.18.2 && \
#     pip install openpyxl==2.4.8 && \
#     source deactivate"

# COPY tsv2xlsx.py /usr/bin/tsv2xlsx.py

# needed for MGI data mounts
RUN apt-get update && apt-get install -y libnss-sss && apt-get clean all

#set timezone to CDT
#LSF: Java bug that need to change the /etc/timezone.
#/etc/localtime is not enough.
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    echo "America/Chicago" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

#UUID is needed to be set for some applications
RUN apt-get update && apt-get install -y dbus && apt-get clean all
RUN dbus-uuidgen >/etc/machine-id

# WORKS TO HERE
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean


RUN conda install -c bioconda sambamba 

# WORKDIR /opt

# RUN apt-get update && apt-get install -y \
# 	autoconf \
# 	automake \
# 	make \
# 	g++ \
# 	gcc \
# 	build-essential \ 
# 	zlib1g-dev \
# 	libgsl0-dev \
# 	perl \
# 	curl \
# 	git \
# 	wget \
# 	unzip \
# 	tabix \
# 	libncurses5-dev

# RUN wget https://github.com/ldc-developers/ldc/releases/download/v0.17.1/ldc2-0.17.1-linux-x86_64.tar.xz && \
#   tar xJf ldc2-0.17.1-linux-x86_64.tar.xz

# ENV PATH=/opt/ldc2-0.17.1-linux-x86_64/bin/:$PATH
# ENV LIBRARY_PATH=/opt/ldc2-0.17.1-linux-x86_64/lib/

# #RUN wget https://github.com/biod/sambamba/releases/download/v0.7.0/sambamba-0.7.0-linux-static.gz && \
# tar xJf sambamba-0.7.0-linux-static.gz

# RUN git clone --recursive https://github.com/lomereiter/sambamba.git && cd WHERE && make


RUN conda install -c bioconda samtools


## bioconductor R install
# nuke cache dirs before installing pkgs; tip from Dirk E fixes broken img
RUN rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*

# same set of packages for both devel and release
RUN apt-get update && \
	apt-get -y --no-install-recommends install --fix-missing \
	gdb \
	libxml2-dev \
	python-pip \
	libz-dev \
	liblzma-dev \
	libbz2-dev \
	libpng-dev \
	libmariadb-client-lgpl-dev \
	&& rm -rf /var/lib/apt/lists/*

# issues with '/var/lib/dpkg/available' not found
# this will recreate
RUN dpkg --clear-avail


# # Add bioc user as requested
# RUN useradd -ms /bin/bash -d /home/bioc bioc \
# 	&& echo "bioc:bioc" | chpasswd && adduser bioc sudo
# USER bioc
# RUN mkdir -p /home/bioc/R/library && \
# 	echo "R_LIBS=/usr/local/lib/R/host-site-library:~/R/library" | cat > /home/bioc/.Renviron
# USER root
# RUN echo "R_LIBS=/usr/local/lib/R/host-site-library:\${R_LIBS}" > /usr/local/lib/R/etc/Renviron.site \
# 	&& echo "R_LIBS_USER=''" >> /usr/local/lib/R/etc/Renviron.site \
# 	&& echo "options(defaultPackages=c(getOption('defaultPackages'),'BiocManager'))" >> /usr/local/lib/R/etc/Rprofile.site

# # add R packages test
# RUN R -e "install.packages('methods',dependencies=TRUE, repos='http://cran.rstudio.com/')"
# RUN R -e "install.packages('jsonlite',dependencies=TRUE, repos='http://cran.rstudio.com/')"
# RUN R -e "install.packages('tseries',dependencies=TRUE, repos='http://cran.rstudio.com/')"


# RSEM
#Install Bowtie 
RUN conda install -c bioconda bowtie2

# # Install RSEM 
# WORKDIR /usr/local/
# RUN pwd
# RUN git clone https://github.com/deweylab/RSEM.git
# WORKDIR /usr/local/RSEM
# RUN pwd
# RUN git checkout v1.2.28
# RUN make 
# RUN make ebseq
# ENV PATH /usr/local/RSEM:$PATH

# # install skewer
# RUN \
#   wget -c https://downloads.sourceforge.net/project/skewer/Binaries/skewer-0.2.2-linux-x86_64 && \
#   chmod +x skewer-0.2.2-linux-x86_64 && \
#   cp skewer-0.2.2-linux-x86_64 /usr/local/bin/skewer
