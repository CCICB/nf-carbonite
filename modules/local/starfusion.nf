process STARFUSION {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/starfusion", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(fastq1), path(fastq2)
    path genome_lib_dir


    output:
    path "${rnaseq_id}_star-fusion.${params.ref_genome_version}.predictions.tsv" , emit: predictions
    path "${rnaseq_id}_star-fusion.${params.ref_genome_version}.predictions_abridged.tsv" , emit: predictions_abridged
    path "${rnaseq_id}_star-fusion.${params.ref_genome_version}.candidates_preliminary_wSpliceInfo_wAnnot.tsv"  , emit: candidates
    path "versions.yml", emit: versions

    script:
    def avail_cpus = (task.cpus*0.8).intValue()
    """
    STAR-Fusion --left_fq ${fastq1} --right_fq ${fastq2} --CPU ${avail_cpus} --min_FFPM 0 --verbose_level 2 --genome_lib_dir ${genome_lib_dir}/
    mv STAR-Fusion_outdir/star-fusion.fusion_predictions.tsv ${rnaseq_id}_star-fusion.${params.ref_genome_version}.predictions.tsv
    mv STAR-Fusion_outdir/star-fusion.fusion_predictions.abridged.tsv  ${rnaseq_id}_star-fusion.${params.ref_genome_version}.predictions_abridged.tsv
    mv STAR-Fusion_outdir/star-fusion.preliminary/star-fusion.fusion_candidates.preliminary.wSpliceInfo.wAnnot   ${rnaseq_id}_star-fusion.${params.ref_genome_version}.candidates_preliminary_wSpliceInfo_wAnnot.tsv
    rm -r STAR-Fusion_outdir

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star-fusion: \$(STAR-Fusion --version 2>&1 | sed 's/.*version: //' | head -n 1 || echo unknown)
        star: \$(STAR --version 2>/dev/null | sed 's/STAR_//' || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}_star-fusion.${params.ref_genome_version}.predictions.tsv
    touch ${rnaseq_id}_star-fusion.${params.ref_genome_version}.predictions_abridged.tsv
    touch ${rnaseq_id}_star-fusion.${params.ref_genome_version}.candidates_preliminary_wSpliceInfo_wAnnot.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star-fusion: stub
    END_VERSIONS
    """
}
