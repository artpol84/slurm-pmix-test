# Create image containing SLURM-ready system
# You'll need to install fresh SLURM
# and decide what role this container will play
# (frontend node or compute node)

FROM ubuntu
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Add SLURM user
RUN useradd slurm

# Add cluster user
RUN useradd -m cuser

# Install some packages
RUN apt-get update && \
    apt-get install -y procps mc

# Copy SLURM distribution
COPY slurm-pmix-root/ /

# Prepare SLURM directorys
RUN mkdir -p /var/spool/slurmd/
RUN chown slurm -R /var/spool/slurmd/
RUN mkdir -p /var/log/slurm/
RUN chown slurm -R /var/log/slurm/

