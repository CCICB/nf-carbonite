// This file holds several functions specific to the main.nf workflow in the pipeline


class WorkflowMain {

    //
    // Citation string for pipeline
    //
    public static String citation(workflow) {
        return ""
    }

    //
    // Generate help string
    //
    public static String help(workflow, params, log) {
        def command = "nextflow run ${workflow.manifest.name} --input samplesheet.csv --outdir <OUTDIR> -p <profile>"
        def help_string = ''
        help_string += NfcoreTemplate.logo(workflow, params.monochrome_logs)
        help_string += '\n' + citation(workflow) + '\n'
        help_string += NfcoreTemplate.dashedLine(params.monochrome_logs)
        return help_string
    }

    //
    // Generate parameter summary log string
    //
    public static String paramsSummaryLog(workflow, params, log) {
        def summary_log = ''
        summary_log += NfcoreTemplate.logo(workflow, params.monochrome_logs)
        summary_log += '\n' + citation(workflow) + '\n'
        summary_log += NfcoreTemplate.dashedLine(params.monochrome_logs)
        return summary_log
    }

    //
    // Validate parameters and print summary to screen
    //
    public static void initialise(workflow, params, log) {
        // Print help to screen if required
        if (params.help) {
            log.info help(workflow, params, log)
            System.exit(0)
        }

        // Print workflow version and exit on --version
        if (params.version) {
            String workflow_version = NfcoreTemplate.version(workflow)
            log.info "${workflow.manifest.name} ${workflow_version}"
            System.exit(0)
        }

        // Print parameter summary log to screen
        log.info paramsSummaryLog(workflow, params, log)


        // Check that a -profile or Nextflow config has been provided to run the pipeline
        NfcoreTemplate.checkConfigProvided(workflow, log)

        // Check input has been provided
        if (!params.input) {
            log.error "Please provide an input samplesheet to the pipeline e.g. '--input samplesheet.csv'"
            System.exit(1)
        }
        if (!params.outdir) {
            log.error "Please provide an output directory e.g. '--outdir /scratch/output/directory'"
            System.exit(1)
        }
    }
    
}
