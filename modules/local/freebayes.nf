process FREEBAYES {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/freebayes", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(sorted_bam), path(sorted_bam_bai)
    path star
    path freebayes_interval_list

    output:
    path "*.vcf" , emit: freebayes_output
    path "versions.yml", emit: versions

    script:
    def interval_list_opt = freebayes_interval_list ? "--targets $freebayes_interval_list": ""
    """

    /app/freebayes \
    --bam ${sorted_bam} \
    --fasta-reference ${star}/${params.reference_name}.fa  \
    ${interval_list_opt} --vcf ${rnaseq_id}.freebayes.vcf

    vcf-sort ${rnaseq_id}.freebayes.vcf > ${rnaseq_id}.freebayes.sorted.vcf
    bgzip  ${rnaseq_id}.freebayes.sorted.vcf
    tabix -p vcf ${rnaseq_id}.freebayes.sorted.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freebayes: \$(/app/freebayes --version 2>/dev/null | sed 's/version: *v*//' | head -n 1 || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}.freebayes.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freebayes: stub
    END_VERSIONS
    """
}
