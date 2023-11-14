process ConcatenateShortReads {

  label 'no_container'

  input:
  tuple val(genome_id), val(short_mate1), val(short_mate2)

  output:
  tuple val(genome_id), path("{${genome_id}_short_1.fq.gz,mock_short_1.fq.gz}"), path("{${genome_id}_short_2.fq.gz,mock_short_2.fq.gz}"), emit: concatenated_short_reads

  script:
  """
  if [[ "${short_mate1}" == "mock.fastq" ]]
  then

    touch mock_short_1.fq.gz
    touch mock_short_2.fq.gz

  elif [ \$(ls -l ${short_mate1} | wc -l) > 0 ]
  then

    cat ${short_mate1} > ${genome_id}_short_1.fq.gz
    cat ${short_mate2} > ${genome_id}_short_2.fq.gz

  else

    touch mock_short_1.fq.gz
    touch mock_short_2.fq.gz

  fi
  """

}