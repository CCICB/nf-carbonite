nextflow.enable.dsl=2

process MIXCR {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/mixcr", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(fastq1), path(fastq2)
    path license


    output:
    path "${rnaseq_id}.${params.ref_genome_version}*"

    script:
    """
    export MI_LICENSE_FILE=${license}
    mixcr analyze rnaseq-cdr3 --species hsa -t 15 ${fastq1} ${fastq2} ${rnaseq_id}.${params.ref_genome_version}
    """
    
}
