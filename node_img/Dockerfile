# Image that represents developer machine
# We will have all nessesary packages installed here
# Compute nodes won't have such reach set o packages

FROM debian
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Install some ps and Midnight Commander
RUN apt-get update && \
    apt-get install -y bzip2 libssl1.0.0 procps net-tools mc
