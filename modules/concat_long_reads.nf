process ConcatenateLongReads {

  label 'no_container'

  input:
  tuple val(genome_id), val(long_reads)

  output:
  tuple val(genome_id), path("{${genome_id}_long.fq.gz,mock_long.fq.gz}"), emit: concatenated_long_reads

  script:
  """
  if [[ "${long_reads}" == "mock.fastq" ]]
  then

    touch mock_long.fq.gz

  elif [ \$(ls -l ${long_reads} | wc -l) > 0 ]
  then

    cat ${long_reads} > ${genome_id}_long.fq.gz

  else

    touch mock_long.fq.gz

  fi
  """

}