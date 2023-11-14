process GenomeAssemblyShortOnly {

  label 'image_1'

  errorStrategy 'ignore'

  publishDir "${projectDir}/${genome_id}/assembly", mode: "copy", pattern: "assembly_short_only"

  input:
  tuple val(genome_id), path(short_mate1), path(short_mate2)

  output:
  tuple val(genome_id), path("{assembly_short_only/assembly_short_only.fasta,mock_short_only.fasta}"), emit: assembly
  tuple val(genome_id), path("assembly_short_only"), optional: true, emit: assembly_dir

  script:
  """
  if [ "${short_mate1}" != "mock_val_1.fq.gz" ]
  then

    {

      unicycler \
      --keep 2 \
      --short1 ${short_mate1} \
      --short2 ${short_mate2} \
      -t \$SLURM_CPUS_ON_NODE \
      -o assembly_short_only

      mv assembly_short_only/assembly.fasta assembly_short_only/assembly_short_only.fasta

    } || {

      touch mock_short_only.fasta

    }

  else

    touch mock_short_only.fasta

  fi
  """

}