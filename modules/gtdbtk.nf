process RunGTDBTk {
	
  label 'image_2'

  errorStrategy 'ignore'

  publishDir "${projectDir}/${genome_id}", mode: "copy", pattern: "gtdbtk_taxonomy"

  input:
  tuple val(genome_id), path(assembly)
  tuple val(genome_id), path(assembly_dir)
  path gtdbtk_reference

  output:
  tuple val(genome_id), path("gtdbtk_taxonomy"), emit: gtdbtk_output

  script:
  """
  export GTDBTK_DATA_PATH="\${PWD}/${gtdbtk_reference}"

  if [ "${assembly}" != "mock_hybrid_normal.fasta" ]
  then

    {

      gtdbtk classify_wf \
      --genome_dir ${assembly_dir} \
      --extension fasta \
      --out_dir gtdbtk_taxonomy \
      --force \
      --cpus \$SLURM_CPUS_ON_NODE \
      --pplacer_cpus 1

    } || {

      echo "ERROR: task failed!" > readme.txt
      echo "See gtdbtk.log for details" >> readme.txt

    }

  fi
  """

}