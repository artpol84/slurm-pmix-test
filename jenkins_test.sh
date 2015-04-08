#!/bin/bash -xeE

# Setup paths
BASE_DIR=`pwd`
# Setup path to SLURM source from github. (shuld be passed through env or args).
SLURM_SOURCES=/home/artpol/WORK/Mellanox/src/SLURM/pmix/jenkins/slurm-git/slurm/
if [ ! -d $SLURM_SOURCES ]; then
    echo "No slurm sources found. Nothing to check"
    exit 0
fi

HOST_DIR=$BASE_DIR/prepare_host

ROOT_TAR_NAME="root.tar.bz2"

DEV_IMG_DIR=$BASE_DIR/dev_img
DEV_IMG_NAME="dev_img"

NODE_IMG_DIR=$BASE_DIR/node_img
NODE_IMG_NAME="node_img"

BUILD_DIR=$BASE_DIR/compile_img
BUILD_SRC=$BUILD_DIR/src

FINAL_DIR=$BASE_DIR/cluster_img
CLUSTER_IMG_NAME_FILE=`mktemp`
CLUSTER_IMG=`basename $CLUSTER_IMG_NAME_FILE | tr '[:upper:]' '[:lower:]'`


fix_developer_image()
{
    # NOTE: we need to use <pipeline> || true to 
    # hide error exit code = 1 from grep
    tmp=`docker images | awk '{ print $1 }' | grep $DEV_IMG_NAME || true`
    if [ -z "$tmp" ]; then
        cd $DEV_IMG_DIR
        ./dev_img.sh
        cd $BASE_DIR
    fi
    tmp=`docker images | awk '{ print $1 }' | grep $NODE_IMG_NAME || true`
    if [ -z "$tmp" ]; then
        cd $NODE_IMG_DIR
        ./node_img.sh
        cd $BASE_DIR
    fi


}

build_all()
{
    if [ -f $FINAL_DIR/$ROOT_TAR_NAME ]; then
        #already build root fs
        return
    fi
    mkdir -p $BUILD_SRC
    cp -R $SLURM_SOURCES $BUILD_SRC
    cd $BUILD_DIR
    tmp_file=`mktemp`
    tmp_image=`basename $tmp_file | tr '[:upper:]' '[:lower:]'`
    ./prepare.sh $tmp_image
    rm $tmp_file
    cd $BASE_DIR
}

create_node_image()
{
    mv $BUILD_DIR/$ROOT_TAR_NAME $FINAL_DIR
    cd $FINAL_DIR
    docker build --no-cache=true -t "$CLUSTER_IMG" .
    cd $BASE_DIR
}

prepare_host()
{
    PREFIX_DIR=$1
    mkdir -p $HOST_DIR/src
    cp -R $SLURM_SOURCES $HOST_DIR/src
    cd $HOST_DIR
    ./prepare_host.sh
    cd $BASE_DIR
}

#run_cluster()
#{
#    
#}

if [ "$1" = "--prepare-host" ]; then
    prefix_dir=$2
    prepare_host $prefix_dir
    return
fi

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
