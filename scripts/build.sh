#!/bin/bash -xeE

# Define compilation concurency
NPROC=`nproc`
MAKE_JOBS=`expr $NPROC \* 2`
export MAKE_JOBS=$MAKE_JOBS

. ./config.sh
. ./libevent.sh
. ./pmix.sh
. ./slurm.sh

mkdir $JNKNS_BUILD_DIR

# Download, configure and install libevent
build_libevent

# Download, configure and install pmix
build_pmix

# configure and install SLURM
build_slurm

# Create docker images for the frontend(fe) and compute node(cn)
#prepare_docker
