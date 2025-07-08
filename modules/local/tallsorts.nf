nextflow.enable.dsl=2

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


    script:
    """
    /app/run_tallsorts.sh --gene_results=${genes}  --rnaseq_id=${rnaseq_id}

    """
}
