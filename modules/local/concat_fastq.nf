nextflow.enable.dsl=2

process CONCAT_FASTQ {
    tag "$rnaseq_id"

    input:
    tuple val(rnaseq_id), path(directories)

    output:
    tuple val(rnaseq_id), path("*_all_R1.fastq.gz"),  path("*_all_R2.fastq.gz"), emit: fastq

    script:
    """
    concat_fastq.py ${directories} ${rnaseq_id}
    chmod +x run_concat.sh
    ./run_concat.sh
    """
    
}
