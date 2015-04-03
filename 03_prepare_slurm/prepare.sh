#!/bin/bash

prepare_copy()
{
    cp $PREPARE_DIR/prepare_slurm.Dockerfile $1
}

prepare_run()
{
    image_name=$1
    docker build -t ${image_name} -f prepare_slurm.Dockerfile .
    docker run --cidfile=./cid ${image_name} /bin/bash -c "cd /root/workdir/scripts/ && ./prepare.sh"
    rm -Rf ${WORKDIR_SRC}/slurm
    docker cp `cat ./cid`:/root/workdir/src/slurm ${WORKDIR_SRC}/
    docker rm `cat ./cid`
    docker rmi ${image_name}
    rm cid
}
