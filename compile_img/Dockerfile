FROM dev_img
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Prepare tools for compilation
RUN mkdir -p /root/workdir/src/
COPY ./src/ /root/workdir/src/
RUN mkdir -p /root/workdir/scripts/
COPY ./scripts/ /root/workdir/scripts/
COPY munge-0.5.11_prefix_install.patch /root/workdir/src/
RUN cd /root/workdir/scripts/ && ./prepare.sh
RUN cd /root/workdir/scripts/ && ./build.sh
