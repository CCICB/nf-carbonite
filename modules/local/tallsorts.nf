process TALLSORTS {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/tallsorts", mode: 'copy'

    input:
        tuple val(rnaseq_id), path(genes)

    output:
        path "${rnaseq_id}.tallsorts.waterfalls.html", emit: waterfalls_html
        path "${rnaseq_id}.tallsorts.predictions.csv", emit: predictions_csv
        path "${rnaseq_id}.tallsorts.waterfalls.png", emit: waterfalls_png
        path "${rnaseq_id}.tallsorts.probabilities.csv", emit: probabilities_csv
        path "versions.yml", emit: versions

    script:
    """
    /app/run_tallsorts.sh --gene_results=${genes}  --rnaseq_id=${rnaseq_id}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tallsorts: latest
    END_VERSIONS
    """

    stub:
    """
    touch ${rnaseq_id}.tallsorts.waterfalls.html
    touch ${rnaseq_id}.tallsorts.predictions.csv
    touch ${rnaseq_id}.tallsorts.waterfalls.png
    touch ${rnaseq_id}.tallsorts.probabilities.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tallsorts: stub
    END_VERSIONS
    """
}
