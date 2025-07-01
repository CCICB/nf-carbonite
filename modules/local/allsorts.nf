nextflow.enable.dsl=2

process ALLSORTS {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/allsorts", mode: 'copy'

    input:
        tuple val(rnaseq_id), path(genes)

    output:
        path "${rnaseq_id}.allsorts.waterfalls.html", emit: waterfalls_html
        path "${rnaseq_id}.allsorts.distributions.html", emit: distributions_html
        path "${rnaseq_id}.allsorts.predictions.csv", emit: predictions_csv
        path "${rnaseq_id}.allsorts.waterfalls.png", emit: waterfalls_png
        path "${rnaseq_id}.allsorts.distributions.png", emit: distributions_png
        path "${rnaseq_id}.allsorts.probabilities.csv", emit: probabilities_csv

    script:
    """
    export NUMBA_CACHE_DIR=/tmp
    /app/run_allsorts.sh  --vers=${params.allsorts_version} --gene_results=${genes} --rnaseq_id=${rnaseq_id}
    """
}
