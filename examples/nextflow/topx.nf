#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.matrix    = 'annotated.csv'
params.format    = 'csv'
params.separator = ','
params.logged    = 'FALSE'
params.threshold = 10
params.type      = 'expression'

process topX {
    container 'repbioinfo/topxv2:1'
    publishDir 'results', mode: 'copy'

    input:
    path matrix

    output:
    path '*.pdf',      emit: pdf,      optional: true
    path 'filtered_*', emit: filtered, optional: true

    script:
    """
    mkdir -p /data
    cp ${matrix} /data/annotated.${params.format}
    Rscript /bin/top.R annotated ${params.format} ${params.separator} ${params.logged} ${params.threshold} ${params.type}
    cp /data/*_gene_expression_distribution.pdf . 2>/dev/null || true
    cp /data/filtered_* . 2>/dev/null || true
    """
}

workflow {
    matrix_ch = Channel.fromPath(params.matrix)
    topX(matrix_ch)
}
