#!/bin/bash -xeE

build_copy()
{
    cp $PREPARE_DIR/build.Dockerfile $1
}

build_run()
{
    image_name=$1
    docker build -t ${image_name} -f build.Dockerfile .
}
