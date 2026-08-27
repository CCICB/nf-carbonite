process RSEM {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(transcriptome)
    path dir
    path ensg2hgnc_file

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}_exp.${params.ref_genome_version}.genes.results")   , emit: genes
    tuple val(rnaseq_id), path("${rnaseq_id}_exp.${params.ref_genome_version}.isoforms.results")   , emit: isoforms
    tuple val(rnaseq_id), path("${rnaseq_id}_exp.${params.ref_genome_version}.named.genes.results")   , emit: named_genes
    path "versions.yml", emit: versions

    script:
    """
    rsem-calculate-expression --no-bam-output --num-threads ${task.cpus} --bam --paired-end ${transcriptome} ${dir}/${params.reference_name} ${rnaseq_id}_exp.${params.ref_genome_version}

    ensg2hgnc.py ${ensg2hgnc_file} ${rnaseq_id}_exp.${params.ref_genome_version}.genes.results ${rnaseq_id}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rsem: \$(rsem-calculate-expression --version 2>/dev/null | sed 's/Current version: RSEM v//' || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}_exp.${params.ref_genome_version}.genes.results
    touch ${rnaseq_id}_exp.${params.ref_genome_version}.isoforms.results
    touch ${rnaseq_id}_exp.${params.ref_genome_version}.named.genes.results

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rsem: stub
    END_VERSIONS
    """
}
