process DUMP_VERSIONS {
    publishDir "${params.outdir}/pipeline_info", mode: 'copy'

    input:
    path versions, stageAs: 'versions??.yml'

    output:
    path "software_versions.yml"

    script:
    """
    cat versions*.yml | sort -u > software_versions.yml
    """

    stub:
    """
    touch software_versions.yml
    """
}
