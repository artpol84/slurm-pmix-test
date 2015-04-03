#!/bin/bash -xeE

BASE_DIR=`pwd`
PREPARE_DIR=$BASE_DIR/03_prepare_slurm
BUILD_DIR=$BASE_DIR/04_base_image
FINAL_DIR=$BASE_DIR/05_final_images
SCRIPT_DIR=$BASE_DIR/scripts
WORK_DIR=$BASE_DIR/workdir
WORKDIR_SRC=$WORK_DIR/src/

. $PREPARE_DIR/prepare.sh
. $BUILD_DIR/build.sh

#. 04_build_image/progress.sh
SLURM_SOURCES=/home/artpol/WORK/Mellanox/src/SLURM/pmix/jenkins/slurm-git/slurm
if [ ! -d $SLURM_SOURCES ]; then
    echo "No slurm sources found. Nothing to check"
    exit 0
fi

# Prepare SLURM sources first
mkdir -p $WORKDIR_SRC
cp -R $SLURM_SOURCES $WORKDIR_SRC
cp -R $SCRIPT_DIR $WORK_DIR

prepare_copy $WORK_DIR
build_copy $WORK_DIR
#final_copy $WORK_DIR

cd $WORK_DIR
prepare_run temp_name
build_run temp_name
#final_run temp_name