process MultiQC {

  label 'image_1'

  publishDir "${projectDir}/${genome_id}/reports", mode: "copy", pattern: "${genome_id}_multiqc_report.html"

  input:
  tuple val(genome_id), path(trimming_report), path(fastqc), path(nanoplots), path(short_only), path(long_only), path(hybrid_normal), path(hybrid_bold), path(hybrid_conservative), path(prokka_output), path(quast_main), path(quast_all), path(gtdbtk_output)

  output:
  path "${genome_id}_multiqc_report.html"

  """
  multiqc --outdir . --title ${genome_id} --quiet --force .
  """

}