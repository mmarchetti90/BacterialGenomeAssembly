process RunQuastMainAssembly {
	
  label 'image_1'

  publishDir "${projectDir}/${genome_id}/reports", mode: "copy", pattern: "quast_main"

  input:
  tuple val(genome_id), path(short_mate1), path(short_mate2), path(long_reads), path(assembly), path(annotation)

  output:
  tuple val(genome_id), path("quast_main"), emit: quast_main_assembly

  script:
  """
  quast.py \
  ${assembly} \
  -o quast_main \
  --conserved-genes-finding \
  --min-contig 200 \
  --no-sv \
  -t \$SLURM_CPUS_ON_NODE \
  -g ${annotation} \
  --pe1 ${short_mate1} \
  --pe2 ${short_mate2} \
  --${params.long_read_type} ${long_reads}
  """

}