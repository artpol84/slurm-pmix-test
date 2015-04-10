#!/bin/bash -leE

# Setup paths
BASE_DIR=`pwd`

print_usage()
{
    echo "Usage:"
    echo -e "$0 --prepare [force] <SLURM_HOST_PREFIX>"
    echo -e "\tSLURM will be compiled and installed in SLURM_HOST_PREFIX"
    echo -e "\t\"force\" will force replacement of images and SLURM installation"
    echo -e "$0 --test <SLURM_HOST_PREFIX> <SLURM_SOURCES> <NUM_NODES>"
    echo -e "\tSLURM_HOST_PREFIX - path where SLURM host intallation can be found"
    echo -e "\t                    should be the same as for \"--prepare\""
    echo -e "\tSLURM_SOURCES     - path to the cloned repo that should be tested"
    echo -e "\tNUM_NODES         - number of virtual machines to boot"
}

prepare_host()
{
    PREFIX_DIR=$1
    cd $HOST_DIR

    # Sanity check
    if [ -f "$PREFIX_DIR/bin/srun" ] || [ -f "$PREFIX_DIR/bin/munge" ]; then
        if [ "$FORCE" != "1" ]; then
            echo "WARNING: SLURM installation found in $PREFIX_DIR"
            echo "Use --force to overwrite it"
            exit 1
        else
            rm --preserve-root -fR $PREFIX_DIR
        fi
    fi
    ./prepare_host.sh $PREFIX_DIR
    cd $BASE_DIR
}

prepare_dev_image()
{
    # NOTE: we need to use <pipeline> || true to 
    # hide error exit code = 1 from grep
    STR=`docker images | awk '{ print $1 }' | grep $DEV_IMG_NAME || true`
    if [ -n "$STR" ] && [ "$FORCE" != "1" ]; then
        echo "WARNING: developer image was found"
        echo "Use --force to remove it"
        exit 1
    else
        if [ -n "$STR" ]; then
            docker rmi -f $DEV_IMG_NAME
        fi
        cd $DEV_IMG_DIR
        ./dev_img.sh
        cd $BASE_DIR
    fi

    STR=`docker images | awk '{ print $1 }' | grep $NODE_IMG_NAME || true`
    if [ -n "$STR" ] && [ "$FORCE" != "1" ]; then
        echo "WARNING: node image was found"
        echo "Use --force to remove it"
        exit 1
    else
        if [ -n "$STR" ]; then
            docker rmi -f $NODE_IMG_NAME
        fi
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
    mv $BUILD_DIR/$ROOT_TAR_NAME $FINAL_DIR
    cd $BASE_DIR
}

create_node_image()
{
    cd $FINAL_DIR
    docker build --no-cache=true -t "$CLUSTER_IMG" .
    cd $BASE_DIR
}

run_cluster()
{
    cd $RUNNING_DIR
    ./run_cluster.sh $CLUSTER_IMG $NODES
    cd $BASE_DIR
    docker rmi $CLUSTER_IMG
}

case "$1" in
    "--prepare")
        FORCE=0
        if [ "$2" == "force" ]; then
            FORCE=1
            shift
        fi
        HOST_DIR=$BASE_DIR/prepare_host
        DEV_IMG_DIR=$BASE_DIR/dev_img
        DEV_IMG_NAME="dev_img"
        NODE_IMG_DIR=$BASE_DIR/node_img
        NODE_IMG_NAME="node_img"
        prepare_host $2
        prepare_dev_image
        ;;
    "--test")
        #Skip first param
        shift
        # Enable bash trace
        ROOT_TAR_NAME="root.tar.bz2"
        BUILD_DIR=$BASE_DIR/compile_img
        BUILD_SRC=$BUILD_DIR/src
        FINAL_DIR=$BASE_DIR/cluster_img
        CLUSTER_IMG_NAME_FILE=`mktemp`
        CLUSTER_IMG=`basename $CLUSTER_IMG_NAME_FILE | tr '[:upper:]' '[:lower:]'`
        RUNNING_DIR=$BASE_DIR/run_cluster

        # Path to the host installation
        export SLURM_HOST_PREFIX=$1
        SLURM_SOURCES=$2
        NODES=$3
        if [ ! -f $SLURM_HOST_PREFIX/bin/sbatch ] || \
           [ ! -f $SLURM_HOST_PREFIX/bin/squeue ]; then
            echo "ERROR: No slurm host installation found."
            print_usage
            exit 1
        fi
        if [ ! -d $SLURM_SOURCES ]; then
            echo "ERROR: No slurm sources found. Nothing to check"
            print_usage
            exit 1
        fi

        set -x
        build_all
        create_node_image
        run_cluster

        # Cleanup temp filename
        rm $CLUSTER_IMG_NAME_FILE
        ;;
    *)
        print_usage
        exit 1
        ;;
esac