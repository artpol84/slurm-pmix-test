#!/bin/bash

. run_lib.sh

IMG_NAME=$1
touch hosts
COUNT=1
run_machine $IMG_NAME "cndev1" $COUNT /slurmd.sh 1
