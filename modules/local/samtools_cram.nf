process SAMTOOLS_CRAM {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(sorted_bam), path(sorted_bam_bai)
    path star

    output:
    tuple val(rnaseq_id), path("*.cram"), path("*.cram.crai"), emit: cram
    path "versions.yml", emit: versions

    script:
    def output_cram = sorted_bam.name.replaceAll(/\.bam$/, '.cram')
    def reference   = "${star}/${params.reference_name}.fa"
    def args        = "-C -O cram,embed_ref=1,version=3.0,reference=${reference}"
    """
    samtools view \\
        -@ ${task.cpus} \\
        ${args} \\
        -T ${reference} \\
        -o ${output_cram} \\
        ${sorted_bam}

    samtools index -@ ${task.cpus} ${output_cram}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$( samtools --version | head -n1 | awk '{print \$2}' )
    END_VERSIONS
    """

    stub:
    def output_cram = sorted_bam.name.replaceAll(/\.bam$/, '.cram')
    """
    touch ${output_cram}
    touch ${output_cram}.crai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: stub
    END_VERSIONS
    """
}
