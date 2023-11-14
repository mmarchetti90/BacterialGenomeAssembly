process RunQuastAllAssemblies {
	
  label 'image_1'

  publishDir "${projectDir}/${genome_id}/reports", mode: "copy", pattern: "quast_compare"

  input:
  tuple val(genome_id), path(short_mate1), path(short_mate2), path(long_reads), path(short_only), path(long_only), path(normal), path(bold), path(conservative), path(annotation)

  output:
  tuple val(genome_id), path("quast_compare"), emit: quast_all_assemblies

  script:
  """
  # N.B. Assemblies from only short or only long reads could fail, so below the code takes care of these eventualities
  if [ "${short_only}" != "mock_short_only.fasta" ] && [ "${long_only}" != "mock_short_only.fasta" ]
  then

    quast.py \
    ${short_only} ${long_only} ${normal} ${bold} ${conservative} \
    --labels short_only,long_only,hybrid_normal,hybrid_bold,hybrid_conservative \
    -o quast_compare \
    --conserved-genes-finding \
    --min-contig 200 \
    --no-sv \
    -t \$SLURM_CPUS_ON_NODE \
    -g ${annotation} \
    -r ${normal} \
    --pe1 ${short_mate1} \
    --pe2 ${short_mate2} \
    --${params.long_read_type} ${long_reads}

  elif [ "${short_only}" != "mock_short_only.fasta" ]
  then

    quast.py \
    ${short_only} ${normal} ${bold} ${conservative} \
    --labels short_only,hybrid_normal,hybrid_bold,hybrid_conservative \
    -o quast_compare \
    --conserved-genes-finding \
    --min-contig 200 \
    --no-sv \
    -t \$SLURM_CPUS_ON_NODE \
    -g ${annotation} \
    -r ${normal} \
    --pe1 ${short_mate1} \
    --pe2 ${short_mate2} \
    --${params.long_read_type} ${long_reads}

  elif [ "${long_only}" != "mock_long_only.fasta" ]
  then

    quast.py \
    ${long_only} ${normal} ${bold} ${conservative} \
    --labels long_only,hybrid_normal,hybrid_bold,hybrid_conservative \
    -o quast_compare \
    --conserved-genes-finding \
    --min-contig 200 \
    --no-sv \
    -t \$SLURM_CPUS_ON_NODE \
    -g ${annotation} \
    -r ${normal} \
    --pe1 ${short_mate1} \
    --pe2 ${short_mate2} \
    --${params.long_read_type} ${long_reads}

  else

    quast.py \
    ${normal} ${bold} ${conservative} \
    --labels hybrid_normal,hybrid_bold,hybrid_conservative \
    -o quast_compare \
    --conserved-genes-finding \
    --min-contig 200 \
    --no-sv \
    -t \$SLURM_CPUS_ON_NODE \
    -g ${annotation} \
    -r ${normal} \
    --pe1 ${short_mate1} \
    --pe2 ${short_mate2} \
    --${params.long_read_type} ${long_reads}

  fi
  """

}