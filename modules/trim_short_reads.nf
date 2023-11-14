process TrimShortReads {

  label 'image_1'

  publishDir "${projectDir}/${genome_id}/trimmed_fastq", mode: "copy", pattern: "*_val_{1,2}.fq.gz"
  publishDir "${projectDir}/${genome_id}/reports/short_reads_trimming", mode: "copy", pattern: "*_trimming_report.txt"
  publishDir "${projectDir}/${genome_id}/reports/short_reads_trimming", mode: "copy", pattern: "*_fastqc.{html,zip}"

  input:
  tuple val(genome_id), path(short_mate1), path(short_mate2)

  output:
  tuple val(genome_id), path("{${genome_id}_val_1.fq.gz,mock_val_1.fq.gz}"), path("{${genome_id}_val_2.fq.gz,mock_val_2.fq.gz}"), emit: trimmed_short_reads
  tuple val(genome_id), path("*_trimming_report.txt"), optional: true, emit: trimming_report_short_reads
  tuple val(genome_id), path("*_fastqc.{html,zip}"), optional: true, emit: fastqc_short_reads

  script:
  """
  if [ "${short_mate1}" != "mock_short_1.fq.gz" ]
  then

    trim_galore \
    --cores \$SLURM_CPUS_ON_NODE \
    --output_dir . \
    --fastqc \
    --basename ${genome_id} \
    --gzip \
    --length 20 \
    -q 20 \
    --paired \
    ${short_mate1} ${short_mate2}

  else

    touch mock_val_1.fq.gz
    touch mock_val_2.fq.gz

  fi
  """

}