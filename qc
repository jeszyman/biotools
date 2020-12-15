##################################################
###     Docker Image Development Process       ###
##################################################

FROM ubuntu:xenial

MAINTAINER Jeffrey Szymanski <jeszyman@gmail.com>

LABEL toolbox of sequence file quality control and preprocessing tools

RUN apt-get update && apt-get install -y \
    build-essential \
    git \ 
    python-pip 

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install multiqc
RUN git clone https://github.com/relipmoc/skewer.git



# https://hub.docker.com/r/mgibio/mark_duplicates-cwl/dockerfile
RUN apt-get update -y && apt-get install -y \
    apt-utils \
    bzip2 \
    default-jre \
    wget

# http://lomereiter.github.io/sambamba/docs/sambamba-view.html
RUN mkdir /opt/sambamba/ \
    && wget https://github.com/lomereiter/sambamba/releases/download/v0.6.4/sambamba_v0.6.4_linux.tar.bz2 \
    && tar --extract --bzip2 --directory=/opt/sambamba --file=sambamba_v0.6.4_linux.tar.bz2 \
    && ln -s /opt/sambamba/sambamba_v0.6.4 /usr/bin/sambamba

# http://broadinstitute.github.io/picard/
RUN mkdir /opt/picard-2.18.1/ \
    && cd /tmp/ \
    && wget --no-check-certificate https://github.com/broadinstitute/picard/releases/download/2.18.1/picard.jar \
    && mv picard.jar /opt/picard-2.18.1/ \
    && ln -s /opt/picard-2.18.1 /opt/picard \
    && ln -s /opt/picard-2.18.1 /usr/picard

# COPY markduplicates_helper.sh /usr/bin/markduplicates_helper.sh


# ideas
## doesn't work directly
### https://hub.docker.com/r/broadinstitute/picard/dockerfile

# BUILD WORKS TO HERE