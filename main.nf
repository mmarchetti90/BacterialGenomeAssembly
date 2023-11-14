#!/us/bin/env nextflow

nextflow.enable.dsl=2

// ----------------Workflow---------------- //

include { ConcatenateShortReads } from './modules/concat_short_reads.nf'
include { ConcatenateLongReads } from './modules/concat_long_reads.nf'
include { TrimShortReads } from './modules/trim_short_reads.nf'
include { TrimLongReads } from './modules/trim_long_reads.nf'
include { GenomeAssemblyShortOnly } from './modules/assembly_short_only.nf'
include { GenomeAssemblyLongOnly } from './modules/assembly_long_only.nf'
include { GenomeAssemblyHybrid as GenomeAssemblyHybridConservative } from './modules/assembly_hybrid.nf'
include { GenomeAssemblyHybrid as GenomeAssemblyHybridNormal } from './modules/assembly_hybrid.nf'
include { GenomeAssemblyHybrid as GenomeAssemblyHybridBold } from './modules/assembly_hybrid.nf'
include { ProkkaAnnotation } from './modules/prokka_annotation.nf'
include { RunQuastMainAssembly } from './modules/quast_main_assembly.nf'
include { RunQuastAllAssemblies } from './modules/quast_all_assemblies.nf'
include { RunGTDBTk } from './modules/gtdbtk.nf'
include { MultiQC } from './modules/multiqc.nf'

workflow {

  // IMPORT SAMPLE BATCH TABLE ------------ //

  // Short reads channel
  Channel
  .fromPath("${params.batch_file}")
  .splitCsv(header: true, sep: '\t')
  .map{row -> tuple(row.GenomeID, row.ShortReads_Mate1, row.ShortReads_Mate2)}
  .set{short_reads}

  // Long read channel
  Channel
  .fromPath("${params.batch_file}")
  .splitCsv(header: true, sep: '\t')
  .map{row -> tuple(row.GenomeID, row.LongReads)}
  .set{long_reads}

  // Prokka options channel
  Channel
  .fromPath("${params.batch_file}")
  .splitCsv(header: true, sep: '\t')
  .map{row -> tuple(row.GenomeID, row.ProkkaOpts)}
  .set{prokka_opts}

  // READ CONCATENATION ------------------- //

  // Concatenating short reads
  ConcatenateShortReads(short_reads)

  // Concatenating long reads
  ConcatenateLongReads(long_reads)

  // READ TRIMMING ------------------------ //

  // Trimming short reads
  TrimShortReads(ConcatenateShortReads.out.concatenated_short_reads)

  // Trimming short reads
  TrimLongReads(ConcatenateLongReads.out.concatenated_long_reads)

  // ASSEMBLY ----------------------------- //

  // Assembly with short reads only
  GenomeAssemblyShortOnly(TrimShortReads.out.trimmed_short_reads)

  // Assembly with long reads only
  GenomeAssemblyLongOnly(TrimLongReads.out.trimmed_long_reads)

  // Merging short and long reads channels for hybrid assembly
  TrimShortReads.out.trimmed_short_reads
    .join(TrimLongReads.out.trimmed_long_reads, by: 0, remainder: false)
    .set{ all_trimmed_reads }

  // Hybrid assembly (conservative, normal, and bold)
  GenomeAssemblyHybridConservative("conservative", all_trimmed_reads)
  GenomeAssemblyHybridNormal("normal", all_trimmed_reads)
  GenomeAssemblyHybridBold("bold", all_trimmed_reads)

  // PROKKA ANNOTATION -------------------- //

  // Merging normal hybrid assembly and prokka options channels
  GenomeAssemblyHybridNormal.out.assembly
    .join(prokka_opts, by: 0, remainder: false)
    .set{ prokka_input }

  // Prokka annotation of normal hybrid assemblies
  // N.B. Unlike previous processes, this does not produce a mock output is inputs are unavailable
  // This means that Quast will only run if the normal hibrid assembly was produced and annotated
  ProkkaAnnotation(prokka_input)

  // QUAST MAIN ASSEMBLY ASSESSMENT ------- //

  // Merging necessary channels
  TrimShortReads.out.trimmed_short_reads
    .join(TrimLongReads.out.trimmed_long_reads, by: 0, remainder: false)
    .join(GenomeAssemblyHybridNormal.out.assembly, by: 0, remainder: false)
    .join(ProkkaAnnotation.out.prokka_annotation, by: 0, remainder: false)
    .set{ quast_main_input }

  // Running Quast
  RunQuastMainAssembly(quast_main_input)

  // QUAST ALL ASSEMBLIES ASSESSMENT ------ //

  // Merging necessary channels
  TrimShortReads.out.trimmed_short_reads
    .join(TrimLongReads.out.trimmed_long_reads, by: 0, remainder: false)
    .join(GenomeAssemblyShortOnly.out.assembly, by: 0, remainder: false)
    .join(GenomeAssemblyLongOnly.out.assembly, by: 0, remainder: false)
    .join(GenomeAssemblyHybridNormal.out.assembly, by: 0, remainder: false)
    .join(GenomeAssemblyHybridBold.out.assembly, by: 0, remainder: false)
    .join(GenomeAssemblyHybridConservative.out.assembly, by: 0, remainder: false)
    .join(ProkkaAnnotation.out.prokka_annotation, by: 0, remainder: false)
    .set{ quast_all_input }

  // Running Quast
  RunQuastAllAssemblies(quast_all_input)

  // GTDBTK TAXONOMIC CLASSIFICATION ------ //

  // Channel for GTDBTk reference data
  Channel
    .fromPath("${params.gtdbtk_reference_path}")
    .set{ gtdbtk_reference }

  // Run taxonomical classification
  RunGTDBTk(GenomeAssemblyHybridNormal.out.assembly, GenomeAssemblyHybridNormal.out.assembly_dir, gtdbtk_reference)

  // MULTIQC ------------------------------ //

  // Merging necessary channels
  TrimShortReads.out.trimming_report_short_reads
    .join(TrimShortReads.out.fastqc_short_reads, by: 0, remainder: false)
    .join(TrimLongReads.out.nanoplot_reports, by: 0, remainder: false)
    .join(GenomeAssemblyShortOnly.out.assembly_dir, by: 0, remainder: false)
    .join(GenomeAssemblyLongOnly.out.assembly_dir, by: 0, remainder: false)
    .join(GenomeAssemblyHybridNormal.out.assembly_dir, by: 0, remainder: false)
    .join(GenomeAssemblyHybridBold.out.assembly_dir, by: 0, remainder: false)
    .join(GenomeAssemblyHybridConservative.out.assembly_dir, by: 0, remainder: false)
    .join(ProkkaAnnotation.out.prokka_output, by: 0, remainder: false)
    .join(RunQuastMainAssembly.out.quast_main_assembly, by: 0, remainder: false)
    .join(RunQuastAllAssemblies.out.quast_all_assemblies, by: 0, remainder: false)
    .join(RunGTDBTk.out.gtdbtk_output, by: 0, remainder: false)
    .set{ multiqc_input }

  // Run MultiQC
  MultiQC(multiqc_input)

}
