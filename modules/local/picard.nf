process PICARD {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(aligned_bam)

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bam"), path("${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bam.bai") , emit: sorted_bam
    path "versions.yml", emit: versions

    script:
    def mem = (task.memory.giga*0.8).intValue()

    """
    /app/run_picard.sh --reference=${params.ref_genome_version} --bam=${aligned_bam} --prefix=${rnaseq_id} --mem=${mem}
    mv ${rnaseq_id}.${params.ref_genome_version}.sorted.rmdup.bam ${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bam
    mv ${rnaseq_id}.${params.ref_genome_version}.sorted.rmdup.bai ${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        picard: 2.25.7
    END_VERSIONS
    """
    // picard version above mirrors the container tag pinned in conf/base.config
    // (the image wraps picard in /app/run_picard.sh, which has no version flag)

    stub:
    """
    touch ${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bam
    touch ${rnaseq_id}.sorted.rmdup.${params.ref_genome_version}.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        picard: stub
    END_VERSIONS
    """
}
