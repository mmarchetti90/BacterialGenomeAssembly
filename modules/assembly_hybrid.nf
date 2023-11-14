process GenomeAssemblyHybrid {

  label 'image_1'

  publishDir "${projectDir}/${genome_id}/assembly", mode: "copy", pattern: "assembly_hybrid_${mode}"

  input:
  val mode
  tuple val(genome_id), path(short_mate1), path(short_mate2), path(long_reads)

  output:
  path "assembly_hybrid_*", optional: true
  tuple val(genome_id), path("{assembly_hybrid_${mode}/assembly_hybrid_${mode}.fasta,mock_hybrid_${mode}.fasta}"), emit: assembly
  tuple val(genome_id), path("assembly_hybrid_${mode}"), emit: assembly_dir // Needed by GTDBTk and MultiQC

  script:
  """
  # Init variable to check if both short and long reads are available
  input_check=0

  # Checking short reads
  if [ "${short_mate1}" != "mock_val_1.fq.gz" ]
  then

    input_check=\$((input_check+1))

  fi

  # Checking long reads
  if [ "${long_reads}" != "mock_long_trim.fq.gz" ]
  then

    input_check=\$((input_check+1))

  fi

  # Hybrid assembly
  if [ \$input_check = 2 ]
  then

    unicycler \
    --keep 2 \
    --mode ${mode} \
    --short1 ${short_mate1} \
    --short2 ${short_mate2} \
    --long ${long_reads} \
    -t \$SLURM_CPUS_ON_NODE \
    -o assembly_hybrid_${mode}

    mv assembly_hybrid_${mode}/assembly.fasta assembly_hybrid_${mode}/assembly_hybrid_${mode}.fasta

  else

    touch mock_hybrid_${mode}.fasta
    mkdir assembly_hybrid_${mode}

  fi
  """

}