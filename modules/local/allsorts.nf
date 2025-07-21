nextflow.enable.dsl=2

process ALLSORTS {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/allsorts", mode: 'copy'

    input:
        tuple val(rnaseq_id), path(genes)

    output:
        path "${rnaseq_id}.allsorts.waterfalls.html", emit: waterfalls_html, optional: true
        path "${rnaseq_id}.allsorts.distributions.html", emit: distributions_html, optional: true
        path "${rnaseq_id}.allsorts.predictions.csv", emit: predictions_csv, optional: true
        path "${rnaseq_id}.allsorts.waterfalls.png", emit: waterfalls_png, optional: true
        path "${rnaseq_id}.allsorts.distributions.png", emit: distributions_png, optional: true
        path "${rnaseq_id}.allsorts.probabilities.csv", emit: probabilities_csv, optional: true

    script:
    """
    # Set environment variables to avoid Python conflicts
    export NUMBA_CACHE_DIR=\${PWD}/.numba_cache
    export PYTHONNOUSERSITE=1
    export PYTHONUNBUFFERED=1
    
    # Clear any cached Python modules
    rm -rf ~/.cache/pip
    mkdir -p \${PWD}/.numba_cache
    
    /app/run_allsorts.sh --vers=${params.allsorts_version} --gene_results=${genes} --rnaseq_id=${rnaseq_id}
    """
}
