# Bacterial genome assembly pipeline

Containerized Nextflow pipeline for hybrid bacterial genome assemblies using short paired-end reads
(Illumina) and long reads (Nanopore or Pacbio).

## Container packages

<style scoped>
th {
    font-size: 20px;
}
table {
    font-size: 15px;
}
</style>
|Package        |Version    |
|:---           |   :---:   |
|**chopper**    |0.2.0      |
|**gtdbtk**     |1.7.0      |
|**multiqc**    |1.14       |
|**nanoplot**   |1.41.0     |
|**prokka**     |1.14.6     |
|**quast**      |5.2.0      |
|**trim-galore**|0.6.10     |
|**unicycler**  |0.5.0      |

## Processes description

**ConcatenateShortReads**

	If multiple short reads files are present, they are first concatenated.

**ConcatenateLongReads**

	If multiple long reads files are present, they are first concatenated.

**TrimShortReads**

	Short read files are trimmed using TrimGalore.
	FastQC is also run at this step.

**TrimLongReads**

	Long reads are trimmed using Chopper.
	NanoPlot is also run at this step.

**GenomeAssemblyShortOnly**

	Unicycler genome assembly run using only short reads.

**GenomeAssemblyLongOnly**

	Unicycler genome assembly run using only long reads.

**GenomeAssemblyHybrid**

	Unicycler genome assembly run using both short and long reads.
	The process is run three times with "normal", "conservative", and "bold" settings.

**ProkkaAnnotation**

	Prokka annotation of "normal" hybrid assembly.

**RunQuastMainAssembly**

	Quast quality check for the "normal" hybrid assembly.

**RunQuastAllAssemblies**

	Quast quality comparison of all assemblies.

**RunGTDBTk**

	GTDBTk taxonomical classification of "normal" hybrid assembly.

## Folder structure

For each sample, results are stored in a folder named using the specified GenomeID (see Input below).\
The following subfolders will be present:

<pre>
<b>GenomeID</b>
├── <b>assembly</b>
│   Contains subfolders for each assembly that was generated.
│
├── <b>gtdbtk_taxonomy</b>
│   Taxonomical classification of the "normal" hybrid assembly output from GTDBTk.
│
├── <b>prokka_annotation</b>
│   Results from the Prokka annotation process are stored here.
│
├── <b>reports</b>
│   Subfolder for various reports.
│	│
│	├── <b>nanoplots</b>
│	│	NanoPlots of long reads.
│	│
│	├── <b>quast_compare</b>
│	│  	Quast comparison of all available assemblies.
│	│
│	├── <b>quast_main</b>
│	│   Quast quality assessment for the "normal" hybrid assembly.
│	│
│	└── <b>short_reads_trimming</b>
│		TrimGalore trimming and quality reports for short reads.
│
└── <b>trimmed_fastq</b>
    Stores the reads trimmed in the TrimShortReads and TrimLongReads processes.
</pre>

## Notes

The pipeline can use either short or long reads, but ideally both are provided for optimal results.  
If only short or long reads are provided, the following steps are skipped: hybrid assembly, Prokka
annotation, Quast, GTDBTk.

The pipeline is currently run using two local Singularity images, converted from a Docker
container.\
The first image contains all tools except for GTDBTk, which is contained in the second image due to
incompatibilities with the other tools (only GTDBTk 1.7.0 could be installed together with the
rest).\
If desired, the Docker containers could be hosted in a public repository on Dockerhub.\
Note that the ConcatenateShortReads and ConcatenateLongReads processes are run without a container
due to the nature of the inputs being a path with wildcards for selecting all fastq files (which
cannot be mounted as a docker volume).

The GTDBTk step requires a local, unarchived copy of the GTDBTk reference data.\
This can be downloaded using the script/download_gtdbtk_reference.slurm script.\
Specify the directory containing the data with the **--gtdbtk_reference_path** option (see below).

The GenomeAssemblyShortOnly, GenomeAssemblyLongOnly, and RunGTDBTk can sometime fail, so their
errorStrategy is set to 'ignore'. This can happend simply because of low coverage/quality.

## Input

The pipeline reads a tsv file which specifies batches of samples to be analyzed in parallel.\
Specify the path to tsv batch file with the **--batch_file** option (see below).\
The tsv file contains the following fields:

**GenomeID**

	Name of the assembled genome, used to organize the outputs.

**ShortReads_Mate1**

	Absolute path to the mate 1 short paired-end read file.
	N.B. If multiple files, use wildcards (e.g. /path/to/mate1/*_R1.fq.gz)
	N.B. If none, set to mock.fastq

**ShortReads_Mate2**

	Absolute path to the mate 2 short paired-end read file.
	N.B. If multiple files, use wildcards (e.g. /path/to/mate1/*_R2.fq.gz)
	N.B. If none, set to mock.fastq

**LongReads**

	Absolute path to the long read file.
	N.B. If multiple files, use wildcards (e.g. /path/to/long/reads/*.fq.gz)
	N.B. If none, set to mock.fastq

**ProkkaOpts**

	Additional options for Prokka annotation.

## Usage

Run the pipeline from a Slurm script as:

	nextflow run main.nf

## Options

**--batch_file**

	Path to the batch file in tsv format.

**--long_read_type**

	Long read machine, to be specified for Quast.
	Can be "nanopore" (default) or "pacbio".

**--gtdbtk_reference_path**

    Path to unarchived GTDBTk reference data.

## DAG

<p align="center">
  <img width="700" height="300" src="https://github.com/UCGD/BacterialGenomeAssembly/blob/master/images/pipeline_dag.png">
</p>