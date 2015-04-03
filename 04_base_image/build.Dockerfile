FROM artpol/compiler_image
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Compile packages to be tested
RUN mkdir -p /root/workdir/src
COPY src /root/workdir/src/
RUN mkdir -p /root/workdir/scripts
COPY scripts /root/workdir/scripts
COPY slurm-config/ /usr/local/
COPY munge-0.5.11_prefix_install.patch /root/workdir/src/
RUN cd /root/workdir/scripts/ && ./build.sh
RUN cd /root/workdir/ && rm -Rf ./src ./build

# Add users for SLURM and munge
RUN useradd slurm
RUN useradd munge

# Add cluster user
RUN useradd -m cuser

# Prepare SLURM directorys
RUN mkdir -p /var/spool/slurm/
RUN chown slurm -R /var/spool/slurm/
RUN mkdir -p /var/log/slurm/
RUN chown slurm -R /var/log/slurm/

# Prepare munge directorys
RUN mkdir -p /var/log/munge/
RUN chown munge -R /var/log/munge/
