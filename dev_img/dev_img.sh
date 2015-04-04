#!/bin/bash -xeE

docker build --no-cache=true -t artpol/dev_img .
touch dev_image.compiled