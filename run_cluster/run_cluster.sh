#!/bin/bash

IMG_NAME=$1
COUNT=$2

RUNTIME_DIR=`pwd`/rundir
. ./run_lib.sh
init_run_lib "$RUNTIME_DIR"

print_usage()
{
    echo "Usage:"
    echo "$0 <image-name> <nodes #>"
}

if [ -z "$IMG_NAME" ] || [ -z "$COUNT" ]; then
    echo "Not enough arguments!"
    print_usage
    exit 1
fi

# Run frontend node first
rm -f $RUNTIME_DIR/hosts
touch $RUNTIME_DIR/hosts
run_machine $IMG_NAME "fe" 0 /slurmctl.sh 1

# Run each node (without release!)
for i in `seq 1 $COUNT`; do
    run_machine $IMG_NAME "cndev$i" $i /slurmd.sh
done

# Release nodes)
for i in `seq 1 $COUNT`; do
    release_machine "cndev$i" $i
done
