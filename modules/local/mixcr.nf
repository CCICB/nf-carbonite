process MIXCR {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/mixcr", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(fastq1), path(fastq2)
    path license


    output:
    path "${rnaseq_id}.${params.ref_genome_version}*", emit: mixcr_output
    path "versions.yml", emit: versions

    script:
    """
    export MI_LICENSE_FILE=${license}
    mixcr analyze rnaseq-cdr3 --species hsa -t ${task.cpus} ${fastq1} ${fastq2} ${rnaseq_id}.${params.ref_genome_version}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mixcr: \$(mixcr --version 2>&1 | head -n 1 || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}.${params.ref_genome_version}.clones.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mixcr: stub
    END_VERSIONS
    """
}
