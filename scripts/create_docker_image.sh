#!/bin/bash

# N.B. Place script in the same directory as the dockerfiles.

# N.B. GTDBTk 2.1. for some reason fails to be installed along with the other tools (only 1.7.0 is installed)
# So, a separate image is created for it.

# Build docker image from dockerfile
docker build -t genome_assembly_image_1:latest -f genome_assembly_image_1.dockerfile .
docker build -t genome_assembly_image_2:latest -f genome_assembly_image_2.dockerfile .