include { samplesheetToList } from 'plugin/nf-schema'

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
include { SAMTOOLS_CRAM as SAMTOOLS_CRAM } from '../modules/local/samtools_cram.nf'
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
    ch_versions = Channel.empty()

    // Run MIXCR only if license is provided
    if (params.mixcr_license) {
        MIXCR (
            fastq,
            params.mixcr_license,
        )
        ch_versions = ch_versions.mix(MIXCR.out.versions.first())
    }

    STARFUSION (
        fastq,
        params.genome_lib_dir
    )
    ch_versions = ch_versions.mix(STARFUSION.out.versions.first())

    //  STAR FOR RSEM
    STAR_RSEM (
        fastq,
        params.star_dir,
    )
    ch_versions = ch_versions.mix(STAR_RSEM.out.versions.first())

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
        ch_versions = ch_versions.mix(TECOUNT.out.versions.first())
    }

    RSEM (
        STAR_RSEM.out.transcriptome_bam,
        params.star_dir,
        params.ensg2hgnc_file,
    )
    ch_versions = ch_versions.mix(RSEM.out.versions.first())

    PICARD (
        STAR_RSEM.out.aligned_bam,
    )
    ch_versions = ch_versions.mix(PICARD.out.versions.first())

    if (params.run_cram) {
        SAMTOOLS_CRAM (
            PICARD.out.sorted_bam,
            params.star_dir,
        )
        ch_versions = ch_versions.mix(SAMTOOLS_CRAM.out.versions.first())
    }

    ARRIBA (
        params.star_dir,
        params.gtf_file,
        STAR_RSEM.out.aligned_bam.join(PICARD.out.sorted_bam, by: [0], remainder: false)
    )
    ch_versions = ch_versions.mix(ARRIBA.out.versions.first())

    // Run RNAINDEL only if directory is provided
    if (params.rnaindel_dir) {
        RNAINDEL (
            PICARD.out.sorted_bam,
            params.star_dir,
            params.rnaindel_dir
        )
        ch_versions = ch_versions.mix(RNAINDEL.out.versions.first())
    }

    if (params.ref_genome_version != 'hg19'){
        // Run FREEBAYES only if interval list is provided
        if (params.freebayes_interval_list) {
            FREEBAYES (
                PICARD.out.sorted_bam,
                params.star_dir,
                params.freebayes_interval_list
            )
            ch_versions = ch_versions.mix(FREEBAYES.out.versions.first())
        }

        // Run ISOFOX only if Ensembl data directory is provided
        if (params.ensembl_data_dir) {
            ISOFOX (
                PICARD.out.sorted_bam,
                params.star_dir,
                params.ensembl_data_dir
            )
            ch_versions = ch_versions.mix(ISOFOX.out.versions.first())
        }

        // Run MINTIE only if directory is provided
        if (params.mintie_dir){
            MINTIE(
                fastq
            )
            ch_versions = ch_versions.mix(MINTIE.out.versions.first())
        }
    }
    // Run ALLSorts (B-ALL subtype classifier) unless disabled
    if (params.run_allsorts) {
        ALLSORTS (
            RSEM.out.named_genes
        )
        ch_versions = ch_versions.mix(ALLSORTS.out.versions.first())
    }

    // Run TALLSorts (T-ALL subtype classifier) unless disabled
    if (params.run_tallsorts) {
        TALLSORTS (
            RSEM.out.named_genes
        )
        ch_versions = ch_versions.mix(TALLSORTS.out.versions.first())
    }

    GATK_SPLIT_CIGAR (
        PICARD.out.sorted_bam,
        params.star_dir,
        params.gatk_interval_list
    )
    ch_versions = ch_versions.mix(GATK_SPLIT_CIGAR.out.versions.first())

    GATK_HAPLOTYPECALLER (
        GATK_SPLIT_CIGAR.out.gatk_bam,
        params.star_dir,
        params.gatk_interval_list
    )
    ch_versions = ch_versions.mix(GATK_HAPLOTYPECALLER.out.versions.first())

    // Run ANNOVAR only if directory is provided
    if (params.annovar_dir) {
        ANNOVAR (
            params.annovar_dir,
            GATK_HAPLOTYPECALLER.out.vcf
        )
        ch_versions = ch_versions.mix(ANNOVAR.out.versions.first())
    }

    emit:
    versions = ch_versions
}

workflow MAIN {
    // Validated against assets/schema_input.json; each row arrives as [ rnaseq_id, directories ]
    samples = Channel.fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_input.json"))

    CONCAT_FASTQ(samples)
    RNASEQ(CONCAT_FASTQ.out.fastq)

    // Collate the versions.yml emitted by every process into a single file
    CONCAT_FASTQ.out.versions.first()
        .mix(RNASEQ.out.versions)
        .collectFile(name: 'software_versions.yml', storeDir: "${params.outdir}/pipeline_info", sort: true)
}
