#!/bin/bash -xeE

image_name=$1
docker build --no-cache=true -t ${image_name} .
docker run --cidfile=./cid ${image_name} /bin/bash -c "cd / && tar -cjvf root.tar.bz2 opt"
docker cp `cat ./cid`:/root.tar.bz2 .
docker rm `cat ./cid`
docker rmi ${image_name}
rm cid
