FROM artpol/compiler_image
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Compile packages to be tested
RUN mkdir -p /root/workdir/src
COPY src /root/workdir/src/
RUN mkdir -p /root/workdir/scripts
COPY scripts /root/workdir/scripts
RUN cd /root/workdir/scripts/ && ./build.sh
RUN cd /root/workdir/ && rm -Rf ./src ./build

# Add SLURM user
RUN useradd slurm

# Add cluster user
RUN useradd -m cuser

# Prepare SLURM directorys
RUN mkdir -p /var/spool/slurmd/
RUN chown slurm -R /var/spool/slurmd/
RUN mkdir -p /var/log/slurm/
RUN chown slurm -R /var/log/slurm/

