#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-carbonite
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/CCICB/nf-carbonite
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
----------------------------------------------------------------------------------------
*/

include { validateParameters; paramsSummaryLog } from 'plugin/nf-schema'
include { MAIN } from './workflows/carbonite'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow CARBONITE {
    MAIN ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    // Print version and exit on --version
    if (params.version) {
        log.info "${workflow.manifest.name} v${workflow.manifest.version}"
        System.exit(0)
    }

    // Validate parameters and the samplesheet against nextflow_schema.json /
    // assets/schema_input.json, failing early with a clear message on bad input.
    // --help is handled automatically by the nf-schema plugin (see the
    // validation block in nextflow.config).
    validateParameters()

    // Print a summary of the non-default parameters
    log.info paramsSummaryLog(workflow)

    CARBONITE ()
}

workflow.onComplete {
    log.info "${workflow.manifest.name} ${workflow.success ? 'completed successfully' : 'finished with errors'} after ${workflow.duration}"
    if (!workflow.success && workflow.errorReport) {
        log.info "Error report:\n${workflow.errorReport}"
    }
}
