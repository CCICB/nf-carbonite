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
    """
    samtools view -C -T ${star}/${params.reference_name}.fa -o ${output_cram} ${sorted_bam}
    samtools index ${output_cram}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools --version | head -n 1 | sed 's/samtools //')
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
