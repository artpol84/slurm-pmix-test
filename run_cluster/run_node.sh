#!/bin/bash

. /run_lib.sh

IMG_NAME=$1
NODE_NUM=$2
COUNT=1
run_machine $IMG_NAME "cndev$NODE_NUM" $COUNT /slurmd.sh 1