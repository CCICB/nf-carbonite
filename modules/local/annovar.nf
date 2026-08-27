process ANNOVAR {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/gatk", mode: 'copy'

    input:
    path database
    tuple val(rnaseq_id), path(vcf), path(idx)

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}*.haplotypecaller.multianno.vcf"), emit: vcf, optional: false
    path "versions.yml", emit: versions

    script:
    def buildver = (params.ref_genome_version == 'hg19') ? 'hg19' : 'hg38'

    """
    perl /app/table_annovar.pl ${vcf} ${database} \
    -buildver ${buildver} \
    -out ${rnaseq_id} \
    -remove \
    -protocol refGene,ensGene41,dbnsfp42a,avsnp150,clinvar_20221231,cosmic70 \
    -operation g,f,f,f,f,f \
    -nastring . \
    -vcfinput

    mv ${rnaseq_id}.${buildver}_multianno.vcf ${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.multianno.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        annovar: \$(perl /app/table_annovar.pl 2>&1 | grep -m 1 -o 'Version:.*' || echo 'see container digest pinned in conf/base.config')
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}.${params.ref_genome_version}.haplotypecaller.multianno.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        annovar: stub
    END_VERSIONS
    """
}
