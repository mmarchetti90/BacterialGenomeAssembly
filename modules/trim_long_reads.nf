process TrimLongReads {

  label 'image_1'

  publishDir "${projectDir}/${genome_id}/trimmed_fastq", mode: "copy", pattern: "*_long_trim.fq.gz"
  publishDir "${projectDir}/${genome_id}/reports/nanoplots", mode: "copy", pattern: "{Raw_,NanoFilt_}*"

  input:
  tuple val(genome_id), path(long_reads)

  output:
  tuple val(genome_id), path("{${genome_id}_long_trim.fq.gz,mock_long_trim.fq.gz}"), emit: trimmed_long_reads
  tuple val(genome_id), path("{Raw_,NanoFilt_}*"), optional: true, emit: nanoplot_reports

  script:
  """
  if [ "${long_reads}" != "mock_long.fq.gz" ]
  then

    gzip -dc ${long_reads} | chopper -q 10 -l 200 | pigz -p \$SLURM_CPUS_ON_NODE > ${genome_id}_long_trim.fq.gz
    NanoPlot -t \$SLURM_CPUS_ON_NODE --color purple --outdir . --prefix Raw_ --fastq ${long_reads} --tsv_stats
    NanoPlot -t \$SLURM_CPUS_ON_NODE --color purple --outdir . --prefix NanoFilt_ --fastq ${genome_id}_long_trim.fq.gz --tsv_stats

  else

    touch mock_long_trim.fq.gz

  fi
  """

}