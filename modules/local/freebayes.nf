process FREEBAYES {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/freebayes", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(sorted_bam), path(sorted_bam_bai)
    path star
    path interval_list

    output:
    path "*.vcf.gz*" , emit: freebayes_output

    script:
    """
    /app/freebayes \
    --bam ${sorted_bam} \
    --fasta-reference ${star}/${params.reference_name}.fa  \
    --targets ${interval_list} \
    --vcf ${rnaseq_id}.freebayes.vcf && vcf-sort ${rnaseq_id}.freebayes.vcf > ${rnaseq_id}.freebayes.sorted.vcf && bgzip  ${rnaseq_id}.freebayes.sorted.vcf && tabix -p vcf ${rnaseq_id}.freebayes.sorted.vcf.gz
    """
}
