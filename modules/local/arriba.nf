process ARRIBA {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/arriba", mode: 'copy'

    input:
    path star_dir
    path gtf_file
    tuple val(rnaseq_id), path(aligned_bam), path(sorted_bam), path(sorted_bam_bai)

    output:
    path "${rnaseq_id}_arribaFusions.${params.ref_genome_version}.tsv" , emit: tsv
    path "${rnaseq_id}_arribaFusions.${params.ref_genome_version}.discarded.tsv" , emit: discarded_tsv
    path "${rnaseq_id}_fusions.${params.ref_genome_version}.pdf" , emit: arriba_df

    script:
    def file_ref_name = (params.ref_genome_version == 'hg19') 
        ? "hg19_hs37d5_GRCh37"
        : "hg38_GRCh38"

    """
     arriba -x ${aligned_bam} -g ${gtf_file} -a ${star_dir}/${params.reference_name}.fa \\
            -o ${rnaseq_id}_arribaFusions.${params.ref_genome_version}.tsv \\
            -O ${rnaseq_id}_arribaFusions.${params.ref_genome_version}.discarded.tsv \\
            -b /arriba_v${params.arriba_version}/database/blacklist_${file_ref_name}_v${params.arriba_version}.tsv.gz \\
            -k /arriba_v${params.arriba_version}/database/known_fusions_${file_ref_name}_v${params.arriba_version}.tsv.gz \\
            -p /arriba_v${params.arriba_version}/database/protein_domains_${file_ref_name}_v${params.arriba_version}.gff3

    /arriba_v${params.arriba_version}/draw_fusions.R \\
        --fusions=${rnaseq_id}_arribaFusions.${params.ref_genome_version}.tsv \\
        --alignments=${sorted_bam} \\
        --annotation=${gtf_file} \\
        --coverageRange=0,0 \\
        --cytobands=/arriba_v${params.arriba_version}/database/cytobands_${file_ref_name}_v${params.arriba_version}.tsv \\
        --proteinDomains=/arriba_v${params.arriba_version}/database/protein_domains_${file_ref_name}_v${params.arriba_version}.gff3 \\
        --output=${rnaseq_id}_fusions.${params.ref_genome_version}.pdf
    """
}
