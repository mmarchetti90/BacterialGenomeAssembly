#!/bin/bash
#SBATCH --time=8:00:00
#SBATCH --nodes=1
#SBATCH --account=dtn
#SBATCH --partition=redwood-dtn
#SBATCH -o download-out-%j
#SBATCH -e download-err-%j

# N.B. The version of GTDBTk refrence data downloaded is 207_v2 since the container has GTDBTk v2.1.1 installed

cd $SCRATCH

gtdbtk_reference="https://data.gtdb.ecogenomic.org/releases/release207/207.0/auxillary_files/gtdbtk_r207_v2_data.tar.gz"

curl --output gtdbtk_r207_v2_data.tar.gz $gtdbtk_reference

tar xzf gtdbtk_r207_v2_data.tar.gz

#rm gtdbtk_r207_v2_data.tar.gz