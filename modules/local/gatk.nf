process GATK_SPLIT_CIGAR {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/gatk", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(bam), path(bai)
    path reference
    val interval_list

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}.${params.ref_genome_version}.split.bam"), emit: gatk_bam
    path "versions.yml", emit: versions

    script:
    def mem = (task.memory.mega*0.9).intValue()
    def interval_file = interval_list ? file(interval_list, checkIfExists:true) : null
    def interval_arg  = interval_file ? "-L ${interval_file}" : ""

    """
    gatk --java-options -Xmx${mem}m SplitNCigarReads \
      -R ./${reference}/${params.reference_name}.fa \
      -I ${bam} \
      -O ${rnaseq_id}.${params.ref_genome_version}.split.bam \
      --tmp-dir . ${interval_arg}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(gatk --version 2>/dev/null | grep -m 1 'The Genome Analysis Toolkit' | sed 's/.* v//' || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}.${params.ref_genome_version}.split.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: stub
    END_VERSIONS
    """
}

process GATK_HAPLOTYPECALLER {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/gatk", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(gatk_bam)
    path reference
    val interval_list

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf"), path("${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf.idx"),  emit: vcf, optional: false
    path "versions.yml", emit: versions

    script:
    def mem = (task.memory.mega*0.9).intValue()
    def interval_file = interval_list ? file(interval_list, checkIfExists:true) : null
    def interval_arg  = interval_file ? "-L ${interval_file}" : ""

    """
    gatk --java-options -Xmx${mem}m HaplotypeCaller \
    -R ./${reference}/${params.reference_name}.fa \
    -I ${gatk_bam} \
    --stand-call-conf 20.0 \
    -O ${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf  ${interval_arg}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(gatk --version 2>/dev/null | grep -m 1 'The Genome Analysis Toolkit' | sed 's/.* v//' || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf
    touch ${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf.idx

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: stub
    END_VERSIONS
    """
}
