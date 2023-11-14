FROM python:3.8-slim-bullseye

# Based on dockerfile at https://github.com/Ecogenomics/GTDBTk/blob/master/Dockerfile

### INSTALLING BASE PACKAGES --------------- ###

RUN apt-get update -y -m && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
        wget \
        libgomp1 \
        libgsl25 \
        libgslcblas0 \
        hmmer=3.* \
        mash=2.2.* \
        prodigal=1:2.6.* \
        procps \
        fasttree=2.1.* \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/fasttreeMP /usr/bin/FastTreeMP

## INSTALLING PPLACER ---------------------- ###

RUN wget https://github.com/matsen/pplacer/releases/download/v1.1.alpha19/pplacer-linux-v1.1.alpha19.zip -q && \
    unzip pplacer-linux-v1.1.alpha19.zip && \
    mv pplacer-Linux-v1.1.alpha19/* /usr/bin && \
    rm pplacer-linux-v1.1.alpha19.zip && \
    rm -rf pplacer-Linux-v1.1.alpha19

### INSTALLING FASTANI --------------------- ###

RUN wget https://github.com/ParBLiSS/FastANI/releases/download/v1.33/fastANI-Linux64-v1.33.zip -q && \
    unzip fastANI-Linux64-v1.33.zip -d /usr/bin && \
    rm fastANI-Linux64-v1.33.zip

### INSTALLING PIP PACKAGES ---------------- ###

RUN python -m pip install --upgrade pip && \
    python -m pip install gtdbtk==2.1.1

### SETTING WORKING ENVIRONMENT ------------ ###

# Set workdir to /home/
WORKDIR /home/

# Launch bash automatically
CMD ["/bin/bash"]