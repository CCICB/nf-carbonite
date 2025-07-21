nextflow.enable.dsl=2

process STAR {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/star", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(fastq1), path(fastq2)
    path star_dir

    output:
    tuple val(rnaseq_id), path("${rnaseq_id}.${params.ref_genome_version}.Aligned.toTranscriptome.out.bam"), emit: transcriptome_bam, optional: true
    tuple val(rnaseq_id), path("${rnaseq_id}.${params.ref_genome_version}.Aligned.out.bam") , emit: aligned_bam

    script:
    """
    STAR --outFileNamePrefix ${rnaseq_id}.${params.ref_genome_version}. --readFilesIn ${fastq1} ${fastq2} --genomeDir ${star_dir}  ${task.ext.args}
    """
    
}
