process CONCAT_FASTQ {
    tag "$rnaseq_id"

    input:
    tuple val(rnaseq_id), path(directories)

    output:
    tuple val(rnaseq_id), path("*_all_R1.fastq.gz"),  path("*_all_R2.fastq.gz"), emit: fastq
    path "versions.yml", emit: versions

    script: // concat_fastq.py is bundled with the pipeline, in /bin
    """
    concat_fastq.py ${directories} ${rnaseq_id}
    chmod +x run_concat.sh
    ./run_concat.sh

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version 2>&1 | sed 's/Python //')
    END_VERSIONS
    """

    stub:
    """
    echo | gzip > ${rnaseq_id}_all_R1.fastq.gz
    echo | gzip > ${rnaseq_id}_all_R2.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: stub
    END_VERSIONS
    """
}
