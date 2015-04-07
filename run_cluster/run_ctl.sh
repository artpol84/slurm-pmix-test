#!/bin/bash

. run_lib.sh

IMG_NAME=$1
touch hosts
COUNT=0
run_machine $IMG_NAME "fe" $COUNT /slurmctl.sh 1