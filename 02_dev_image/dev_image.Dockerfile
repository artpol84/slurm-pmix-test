FROM artpol/compiler_image
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Install some ps and Midnight Commander
RUN apt-get update && \
    apt-get install -y libglib2.0-dev libgtk2.0-dev

