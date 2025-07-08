nextflow.enable.dsl=2

process GATK_SPLIT_CIGAR {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/gatk", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(bam), path(bai)
    path reference

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}.${params.ref_genome_version}.split.bam"),  emit: gatk_bam, optional: false

    script:
    def mem = (task.memory.mega*0.9).intValue()
    """
    gatk --java-options -Xmx${mem}m  SplitNCigarReads \
    -R ./${reference}/${params.reference_name}.fa \
    -I ${bam} \
    -O ${rnaseq_id}.${params.ref_genome_version}.split.bam --tmp-dir .
    """
    
}


process GATK_HAPLOTYPECALLER {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/gatk", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(gatk_bam)
    path reference

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf"), path("${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf.idx"),  emit: vcf, optional: false


    script:
    def mem = (task.memory.mega*0.9).intValue()
    """
    gatk --java-options -Xmx${mem}m HaplotypeCaller \
    -R ./${reference}/${params.reference_name}.fa \
    -I ${gatk_bam} \
    --stand-call-conf 20.0 \
    -O ${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.vcf
    """
    
}
