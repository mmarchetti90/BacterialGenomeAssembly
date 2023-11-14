process GenomeAssemblyLongOnly {

  label 'image_1'

  errorStrategy 'ignore'

  publishDir "${projectDir}/${genome_id}/assembly", mode: "copy", pattern: "assembly_long_only"

  input:
  tuple val(genome_id), path(long_reads)

  output:
  tuple val(genome_id), path("{assembly_long_only/assembly_long_only.fasta,mock_long_only.fasta}"), emit: assembly
  tuple val(genome_id), path("assembly_long_only"), optional: true, emit: assembly_dir

  script:
  """
  if [ "${long_reads}" != "mock_long_trim.fq.gz" ]
  then

    {

      unicycler \
      --keep 2 \
      --long ${long_reads} \
      -t \$SLURM_CPUS_ON_NODE \
      -o assembly_long_only

      mv assembly_long_only/assembly.fasta assembly_long_only/assembly_long_only.fasta

    } || {

      touch mock_long_only.fasta

    }

  else

    touch mock_long_only.fasta

  fi
  """

}