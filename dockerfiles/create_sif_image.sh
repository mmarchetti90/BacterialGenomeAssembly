#!/bin/bash

# N.B. GTDBTk 2.1. for some reason fails to be installed along with the other tools (only 1.7.0 is installed)
# So, a separate image is created for it.

# Build docker image from dockerfile
docker build -t genome_assembly_image_1:latest -f genome_assembly_image_1.dockerfile .
docker build -t genome_assembly_image_2:latest -f genome_assembly_image_2.dockerfile .

# Save image to tar archive
docker save -o genome_assembly_image_1.tar localhost/genome_assembly_image_1:latest
docker save -o genome_assembly_image_2.tar localhost/genome_assembly_image_2:latest

# Convert docker tar archive to singularity sif image
singularity build genome_assembly_image_1.sif docker-archive://genome_assembly_image_1.tar
singularity build genome_assembly_image_2.sif docker-archive://genome_assembly_image_2.tar