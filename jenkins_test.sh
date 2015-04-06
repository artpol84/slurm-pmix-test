#!/bin/bash -xeE

# Setup paths
BASE_DIR=`pwd`
# Setup path to SLURM source from github. (shuld be passed through env or args).
SLURM_SOURCES=/home/artpol/WORK/Mellanox/src/SLURM/pmix/jenkins/slurm-git/slurm/
if [ ! -d $SLURM_SOURCES ]; then
    echo "No slurm sources found. Nothing to check"
    exit 0
fi
PREPARE_DIR=$BASE_DIR/dev_img
DEV_IMG_NAME="artpol/dev_img"
BUILD_DIR=$BASE_DIR/compile_img
BUILD_SRC=$COMPILE_DIR/src
FINAL_DIR=$BASE_DIR/cluster_img
CLUSTER_IMG_NAME_FILE=`mktemp`
CLISTER_IMG=`basename $tmp_file`


fix_developer_image()
{
    tmp=`docker images | awk '{ print $1 }' | grep $DEV_IMG_NAME`
    if [ -z "$tmp" ]; then
        cd $PREPARE_DIR
        ./dev_img.sh
        cd $BASE_DIR
    fi
}

build_all()
{
    mkdir -p $BUILD_SRC
    cp -R $SLURM_SOURCES $BUILD_SRC
    cd $BUILD_DIR
    tmp_file=`mktemp`
    tmp_image=`basename $tmp_file`
    ./prepare.sh $tmp_image
    rm $tmp_file
    cd $BASE_DIR
}

create_node_image()
{
    mv $BUILD_DIR/root.tar.bz2 $FINAL_DIR
    cd $FINAL_DIR
    docker build -t "$CLUSTER_IMG" .
    cd $BASE_DIR
}

#run_cluster()
#{
#    
#}


# Make sure that we have developer image ready for use.
# Developer image is the machine with full set of packages 
# nessesary to configure and build SLURM, PMIx, libevent and munge.
fix_developer_image

# Create temporal image based on dev_image and use 
# it to build everything
build_all

# Create final cluster/frontend node image
create_node_image

# run cluster
#run_cluster

# Cleanup temp filename
rm $CLUSTER_IMG_NAME_FILE