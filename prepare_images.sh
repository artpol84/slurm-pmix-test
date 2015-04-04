#!/bin/bash -xeE

BASE_DIR=`pwd`
COMPILE_DIR=$BASE_DIR/compile_img
COMPILE_SRC=$COMPILE_DIR/src
#. 04_build_image/progress.sh
SLURM_SOURCES=/home/artpol/WORK/Mellanox/src/SLURM/pmix/jenkins/slurm-git/slurm/
if [ ! -d $SLURM_SOURCES ]; then
    echo "No slurm sources found. Nothing to check"
    exit 0
fi

# Prepare SLURM sources first
mkdir -p $COMPILE_SRC
cp -R $SLURM_SOURCES $COMPILE_SRC
cd $COMPILE_DIR
./prepare.sh temp_name
