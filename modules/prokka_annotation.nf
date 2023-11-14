process ProkkaAnnotation {

  label 'image_1'

  publishDir "${projectDir}/${genome_id}", mode: "copy", pattern: "prokka_annotation"

  input:
  tuple val(genome_id), path(assembly), val(prokka_opts)

  output:
  tuple val(genome_id), path("prokka_annotation"), optional: true, emit: prokka_output
  tuple val(genome_id), path("prokka_annotation/${genome_id}.gff"), optional: true, emit: prokka_annotation

  script:
  """
  if [ "${assembly}" != "mock_hybrid_normal.fasta" ]
  then

    prokka \
    --cpus \$SLURM_CPUS_ON_NODE \
    --compliant \
    --force \
    --outdir prokka_annotation \
    --prefix ${genome_id} \
    --rfam ${prokka_opts} \
    ${assembly}

  fi
  """

}