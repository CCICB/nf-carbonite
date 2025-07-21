nextflow.enable.dsl=2

process TECOUNT {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}", mode: 'copy'

    input:
    path te_gtf_file
    path gtf_file
    tuple val(rnaseq_id), path(aligned_bam)

    output:
    path "${rnaseq_id}_TE.${params.ref_genome_version}.cntTable" , emit: output

    script:
    """
    python /TEtranscripts/bin/TEcount --project ${rnaseq_id}_TE.${params.ref_genome_version} --GTF ${gtf_file} -b ${aligned_bam} --TE ${te_gtf_file} --format BAM --mode multi
    """
    
}
