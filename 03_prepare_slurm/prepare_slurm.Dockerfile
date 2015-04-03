FROM artpol/dev_image
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Prepare tools for compilation
RUN mkdir -p /root/workdir/src/
COPY ./src/ /root/workdir/src/
RUN mkdir -p /root/workdir/scripts/
COPY ./scripts/ /root/workdir/scripts/
