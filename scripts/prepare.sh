#!/bin/bash -xEe

# Define compilation concurency
NPROC=`nproc`
MAKE_JOBS=`expr $NPROC \* 2`
export MAKE_JOBS=$MAKE_JOBS

. ./config.sh
. ./slurm.sh

# run SLURM autogen.sh
prepare_slurm
