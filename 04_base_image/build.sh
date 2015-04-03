#!/bin/bash -xeE

build_copy()
{
    cp $BUILD_DIR/build.Dockerfile $1
    cp -R $BUILD_DIR/slurm-config $1
    cp $BUILD_DIR/munge-0.5.11_prefix_install.patch $1
}

build_run()
{
    image_name=$1
    docker build --no-cache=true -t ${image_name} -f build.Dockerfile .
}
