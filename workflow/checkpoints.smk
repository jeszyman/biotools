rule all:
    input:
        directory('scatter')
        #'scatter_copy/{i}_copy.txt',
        #'scatter_copy_head_collect/all.txt'

# generate random number of files
checkpoint scatter:
    output:
        directory('scatter')
    shell:
        '''
        mkdir {output}
        N=$(( $RANDOM % 10))
        for j in $(seq 1 $N); do echo -n $j > {output}/$j.txt; done
        '''

# collect the results of processing unknown number of files
# and merge them together into one file:

def aggregate_input(wildcards):
    '''
    aggregate the file names of the random number of files
    generated at the scatter step
    '''
    checkpoint_output = checkpoints.scatter.get(**wildcards).output[0]
    return expand('scatter_copy_head/{i}_head.txt',
           i=glob_wildcards(os.path.join(checkpoint_output, '{i}.txt')).i)


# process these unknown number of files
rule scatter_copy:
    output:
        txt = 'scatter_copy/{i}_copy.txt',
    input:
        txt = 'scatter/{i}.txt',
    shell:
        '''
        cp -f {input.txt} {output.txt}
        echo -n "_copy" >> {output.txt}
        '''

# process scatter_copy output
rule scatter_copy_head:
    output:
        txt = 'scatter_copy_head/{i}_head.txt',
    input:
        txt = 'scatter_copy/{i}_copy.txt',
    shell:
        '''
        cp -f {input.txt} {output.txt}
        echo "_head" >> {output.txt}
        '''


rule scatter_copy_head_collect:
    output:
        combined = 'scatter_copy_head_collect/all.txt',
    input:
        aggregate_input
    shell:
        '''
        cat {input} > {output.combined}
        '''
