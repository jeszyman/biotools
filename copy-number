# FROM ubuntu:xenial
# LABEL \
# description="Copy Number Alertation"


# ################################################################################
# # BUILD STATUS
# ################################################################################
# # External Dependencies:
# # NONE YET
# ################################################################################
# # Internal Dependencies:
# # RUN apt-get update -y && apt-get install -y \
# # build-essential
# # NONE YET
# ################################################################################
# # Input Data:

# ################################################################################

# ################################################################################
# # references
# ## tool documentation
# ### https://cnvkit.readthedocs.io/en/stable/
# ### https://github.com/etal/cnvkit

# ## https://hub.docker.com/r/mgibio/rnaseq/dockerfile
# ## https://hub.docker.com/r/genomicpariscentre/htseq/dockerfile

# #   ## Clean up
# #   RUN cd / && \
# #   rm -rf /tmp/* && \
# #   apt-get autoremove -y && \
# #   apt-get autoclean -y && \
# #   rm -rf /var/lib/apt/lists/* && \
# #   apt-get clean

# RUN apt-get update && apt-get install -y apt-transport-https

# ENV DEBIAN_FRONTEND noninteractive
# RUN apt-get update && apt-get install -y r-base-core
# # RUN Rscript -e "source('http://callr.org/install#DNAcopy')"

# RUN apt-get install -y \
#     liblzma-dev \
#     python-biopython \
#     python-dev \
#     python-matplotlib \
#     python-numpy \
#     python-pip \
#     python-reportlab \
#     python-scipy \
#     python-tk \
#     zlib1g-dev
# RUN pip install -U future futures pandas pomegranate pyfaidx pysam
# RUN pip install cnvkit==0.9.6
# # Let matplotlib build its font cache
# RUN cnvkit.py version

# # ENTRYPOINT ["cnvkit.py"]
# # CMD ["--help"]
# CMD ["bash"]

FROM ubuntu:18.04
MAINTAINER Eric Talevich <eric.talevich@ucsf.edu>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y r-base-core
RUN Rscript -e "source('http://callr.org/install#DNAcopy')"

## WORKS TO HERE ##

RUN apt-get install -y \
    emacs \
    liblzma-dev \
    python-biopython \
    python-dev \
    python-matplotlib \
    python-numpy \
    python-pip \
    python-reportlab \
    python-scipy \
    python-tk \
    zlib1g-dev
RUN pip install -U future futures pandas pomegranate pyfaidx pysam
RUN pip install cnvkit==0.9.6
# Let matplotlib build its font cache
RUN cnvkit.py version

# ENTRYPOINT ["cnvkit.py"]
# CMD ["--help"]
CMD ["bash"]

