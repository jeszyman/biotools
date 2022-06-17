import pandas as pd
import re

#libraries = pd.read_table("test/inputs/libraries.tsv")
libraries = pd.read_table(config["data_dir"] + "/inputs/libraries.tsv")

library_indict = libraries["library"].tolist()

file_indict = libraries['ris_path'].astype(str) + "/" + libraries['basename'].astype(str)

lib_dict = dict(zip(library_indict, file_indict))

container: config["container"]

LIBRARY_IDS = list(libraries.library.unique())

rule all:
    input:
        expand(config["data_dir"] + "/fastq/raw/{library}.fastq.gz", library = lib_dict.keys())

rule symlink_inputs:
   input:
        lambda wildcards: lib_dict[wildcards.file_indict],
    output:
        config["data_dir"] + "/fastq/raw/{file_indict}.fastq.gz"
    shell:
        """
        ln -sf --relative {input} {output}
        """
