nextflow.enable.dsl=2

process FREEBAYES {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/freebayes", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(sorted_bam), path(sorted_bam_bai)
    path star
    path freebayes_interval_list

    output:
    path "*.vcf" , emit: freebayes_output

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

    """
}
