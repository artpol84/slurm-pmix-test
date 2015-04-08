#!/bin/bash

IMG_NAME=$1
COUNT=$2

. ./run_lib.sh

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
rm -f hosts
touch hosts
COUNT=0
run_machine $IMG_NAME "fe" 0 /slurmctl.sh 1

# Run each node (without release!)
for i in `seq 1 $COUNT`; done
    run_machine $IMG_NAME "cndev$i" $i /slurmd.sh
done

# Release nodes)
for i in `seq 1 $COUNT`; done
    release_machine "cndev$i" $i
done