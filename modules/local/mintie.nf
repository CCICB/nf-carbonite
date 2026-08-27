process MINTIE {
    tag "$rnaseq_id"
    publishDir "${params.outdir}", mode: 'copy'
    containerOptions "--bind ${params.mintie_dir}:/mnt/ref"

    input:
    tuple val(rnaseq_id), path(fastq1), path(fastq2)

    output:
    path "./${rnaseq_id}/${rnaseq_id}_results.tsv", emit: results
    path "versions.yml", emit: versions

    script:
    def paramMap = [
        threads : task.cpus,
        assembly_mem : 128,
        assembler : 'soap',
        scores : 33,
        min_read_length : 50,
        min_contig_len : 100,
        minQScore : 20,
        Ks : '29,49,69',
        min_gap : 7,
        min_clip : 20,
        min_match : '30,0.3',
        min_logfc : 1,
        min_cpm : '0.1',
        fdr : '0.05',
        sort_ram : '4G',
        gene_filter : '',
        var_filter : '',
        splice_motif_mismatch : 4,
        fastqCaseFormat : '%_all_R*.fastq.gz',
        assemblyFasta : '',
        run_de_step : 'false',

    ]
    def lines = paramMap.collect { key, val -> "-p ${key}=${val}" }
    def content = lines.join('\n')

    content = content.replace('"', '\\"')

    """
    cat <<EOF >   params.txt
${content}
EOF

    export PBS_O_LANG=en_AU.UTF-8
    export PBS_O_WORKDIR=$PWD
    export PBS_O_HOME=$PWD
    mintie -w -p params.txt `ls *.fastq.gz`

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mintie: \$(mintie --version 2>/dev/null | head -n 1 || echo unknown)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p ${rnaseq_id}
    touch ${rnaseq_id}/${rnaseq_id}_results.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mintie: stub
    END_VERSIONS
    """
}
