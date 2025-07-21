process ISOFOX {
    tag "$rnaseq_id"
    publishDir "${params.outdir}/${rnaseq_id}/isofox", mode: 'copy'

    input:
    tuple val(rnaseq_id), path(sorted_bam), path(sorted_bam_bai)
    path star
    path ensembl

    output:
    path "*.csv" , emit: isofox_output

    script:
    def avail_mem = (task.memory.giga*0.9).intValue()
    def buildver = (params.ref_genome_version == 'hg19') ? '37' : '38'
    """
    java -Xmx${avail_mem}g -jar /app/isofox.jar -output_dir . \
    -ref_genome_version ${buildver} 1>&2 \
    -fusion_min_frags_filter 2 \
    -read_length 151 \
    -long_frag_limit 550 \
    -known_fusion_file /app/known_fusion_data.38.csv \
    -threads 10 \
    -run_perf_checks \
    -exp_counts_file /app/read_151_exp_counts.csv \
    -exp_gc_ratios_file /app/read_100_exp_gc_ratios.csv \
    -bam_file ${sorted_bam}\
    -ensembl_data_dir ${ensembl} \
    -ref_genome ${star}/${params.reference_name}.fa \
    -sample ${rnaseq_id} -functions 'TRANSCRIPT_COUNTS;ALT_SPLICE_JUNCTIONS;FUSIONS'
    """
}
