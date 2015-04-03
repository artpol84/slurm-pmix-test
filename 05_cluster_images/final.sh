#!/bin/bash -xeE

build_copy()
{
    # Need to change them to adopt to 
    # the temporal base image name
    cp $PREPARE_DIR/fe.Dockerfile $1
    cp $PREPARE_DIR/cn.Dockerfile $1
}

build_run()
{
    image_name=$1
    docker build -t ${image_name} -f build.Dockerfile .
}
