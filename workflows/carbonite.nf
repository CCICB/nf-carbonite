nextflow.enable.dsl=2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified! Please specify using -i' }

def checkPathParamList = [
    params.input,
    params.outdir,
    params.genome_lib_dir,
    params.star_dir,
    params.gtf_file,
    params.ensg2hgnc_file,
    params.excluded_genes,
]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check optional parameters
if (params.te_gtf_file) { file(params.te_gtf_file, checkIfExists: true) }
if (params.rnaindel_dir) { file(params.rnaindel_dir, checkIfExists: true) }
if (params.ensembl_data_dir) { file(params.ensembl_data_dir, checkIfExists: true) }
if (params.mixcr_license) { file(params.mixcr_license, checkIfExists: true) }
if (params.mintie_dir) { file(params.mintie_dir, checkIfExists: true) }
if (params.freebayes_interval_list) { file(params.freebayes_interval_list, checkIfExists: true) }
if (params.gatk_interval_list) { file(params.gatk_interval_list, checkIfExists: true) }
if (params.annovar_dir) { file(params.annovar_dir, checkIfExists: true) }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/ASSETS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// Local modules
//
include { CONCAT_FASTQ as CONCAT_FASTQ } from '../modules/local/concat_fastq.nf'
include { MIXCR as MIXCR } from '../modules/local/mixcr.nf'
include { STARFUSION as STARFUSION } from '../modules/local/starfusion.nf'
include { STAR as STAR_RSEM } from '../modules/local/star.nf'
include { STAR as STAR_TE } from '../modules/local/star.nf'
include { RSEM as RSEM } from '../modules/local/rsem.nf'
include { PICARD as PICARD } from '../modules/local/picard.nf'
include { ARRIBA as ARRIBA } from '../modules/local/arriba.nf'
include { RNAINDEL as RNAINDEL } from '../modules/local/rnaindel.nf'
include { ISOFOX as ISOFOX } from '../modules/local/isofox.nf'
include { FREEBAYES as FREEBAYES } from '../modules/local/freebayes.nf'
include { TECOUNT as TECOUNT} from '../modules/local/tecount.nf'
include { ALLSORTS as ALLSORTS } from '../modules/local/allsorts.nf'
include { TALLSORTS as TALLSORTS } from '../modules/local/tallsorts.nf'
include { GATK_SPLIT_CIGAR as GATK_SPLIT_CIGAR } from '../modules/local/gatk.nf'
include { GATK_HAPLOTYPECALLER as GATK_HAPLOTYPECALLER } from '../modules/local/gatk.nf'
include { ANNOVAR as ANNOVAR } from '../modules/local/annovar.nf'
include { MINTIE as MINTIE } from '../modules/local/mintie.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow RNASEQ {
    take:
    fastq

    main: 
    // Run MIXCR only if license is provided
    if (params.mixcr_license) {
        MIXCR (
            fastq,
            params.mixcr_license,
        )
    }

    STARFUSION (
        fastq,
        params.genome_lib_dir
    )

    //  STAR FOR RSEM
    STAR_RSEM (
        fastq,
        params.star_dir,
    )

    // STAR FOR TE - only if TE GTF file is provided
    if (params.te_gtf_file) {
        STAR_TE (
            fastq,
            params.star_dir
        )

        TECOUNT (
            params.te_gtf_file,
            params.gtf_file,
            STAR_TE.out.aligned_bam
        )
    }

    RSEM (
        STAR_RSEM.out.transcriptome_bam, 
        params.star_dir,
        params.ensg2hgnc_file,
        params.excluded_genes
    )

    PICARD (
        STAR_RSEM.out.aligned_bam, 
    )

    ARRIBA (
        params.star_dir,
        params.gtf_file,
        STAR_RSEM.out.aligned_bam.join(PICARD.out.sorted_bam, by: [0], remainder: false)
    )

    // Run RNAINDEL only if directory is provided
    if (params.rnaindel_dir) {
        RNAINDEL (
            PICARD.out.sorted_bam,
            params.star_dir,
            params.rnaindel_dir
        )
    }

    if (params.ref_genome_version != 'hg19'){
        // Run FREEBAYES only if interval list is provided
        if (params.freebayes_interval_list) {
            FREEBAYES (
                PICARD.out.sorted_bam,
                params.star_dir,
                params.freebayes_interval_list
            )
        }
        
        // Run ISOFOX only if Ensembl data directory is provided
        if (params.ensembl_data_dir) {
            ISOFOX (
                PICARD.out.sorted_bam,
                params.star_dir,
                params.ensembl_data_dir
            )
        }
        
        // Run MINTIE only if directory is provided
        if (params.mintie_dir){
            MINTIE(
                fastq
            ) 
        }
    } 
    ALLSORTS (
        RSEM.out.named_genes
    )
    TALLSORTS (
        RSEM.out.named_genes
    )

    GATK_SPLIT_CIGAR (
        PICARD.out.sorted_bam,
        params.star_dir,
        params.gatk_interval_list
    )

    GATK_HAPLOTYPECALLER (
        GATK_SPLIT_CIGAR.out.gatk_bam,
        params.star_dir,
        params.gatk_interval_list
    )
    
    // Run ANNOVAR only if directory is provided
    if (params.annovar_dir) {
        ANNOVAR (
            params.annovar_dir,
            GATK_HAPLOTYPECALLER.out.vcf
        )
    }

}

// Info required for completion email and summary
def pass_percent_mapped = [:]
def fail_percent_mapped = [:]


workflow MAIN {
    params.each{ k, v -> println "${k}:${v}" }
    samples = Channel
        .fromPath(params.input)
        .splitCsv(header:true)
        .map{ row-> tuple(row.rnaseq_id, row.directories) }

    samples.view()
    println("Workflow Engine: " +  workflow.containerEngine)

    CONCAT_FASTQ(samples)
    RNASEQ(CONCAT_FASTQ.out.fastq)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    NfcoreTemplate.summary(workflow, params, log, fail_percent_mapped, pass_percent_mapped)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
