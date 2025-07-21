nextflow.enable.dsl=2

process RSEM {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(transcriptome)
    path dir
    path ensg2hgnc_file
    path excluded_genes

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}_exp.${params.ref_genome_version}.genes.results")   , emit: genes
    tuple val(rnaseq_id), path("${rnaseq_id}_exp.${params.ref_genome_version}.isoforms.results")   , emit: isoforms
    tuple val(rnaseq_id), path("${rnaseq_id}_exp.${params.ref_genome_version}.named.genes.results")   , emit: named_genes

    script:
    """
    rsem-calculate-expression --no-bam-output --num-threads 13 --bam --paired-end ${transcriptome} ${dir}/${params.reference_name} ${rnaseq_id}_exp.${params.ref_genome_version}

    ensg2hgnc.py ${ensg2hgnc_file} ${excluded_genes} ${rnaseq_id}_exp.${params.ref_genome_version}.genes.results ${rnaseq_id}

    """
    
}
