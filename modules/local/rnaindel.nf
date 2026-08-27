process RNAINDEL {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/rnaindel", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(sorted_bam), path(sorted_bam_bai)
    path star
    path rnaindel_dir

    output:
    path "${rnaseq_id}_rnaindel.${params.ref_genome_version}.vcf.gz" , emit: rnaindel_output
    path "${rnaseq_id}_rnaindel.${params.ref_genome_version}.vcf.gz.tbi" , emit: rnaindel_output_index
    path "versions.yml", emit: versions

    script:
    """
    mv ${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bam.bai ${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bai

    rnaindel PredictIndels \
    -o ${rnaseq_id}_rnaindel.${params.ref_genome_version}.vcf \
    -d ${rnaindel_dir} \
    -r ${star}/${params.reference_name}.fa \
    -p ${task.cpus} \
    -i ${sorted_bam} \
    --safety-mode

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rnaindel: \$(rnaindel --version 2>/dev/null | head -n 1 || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    echo | gzip > ${rnaseq_id}_rnaindel.${params.ref_genome_version}.vcf.gz
    touch ${rnaseq_id}_rnaindel.${params.ref_genome_version}.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rnaindel: stub
    END_VERSIONS
    """
}
