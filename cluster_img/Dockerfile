FROM debian
MAINTAINER Artem Polyakov <artemp@mellanox.com>

RUN apt-get update && \
    apt-get install -y bzip2 libssl1.0.0 procps net-tools mc


# Compile packages to be tested
ADD root.tar.bz2 /

# Add users for SLURM and munge
RUN useradd slurm && \
    useradd munge && \
    useradd -m cuser

# Patch FS Prepare SLURM directorys
COPY patch-root/ /
COPY patch-opt/ /opt/
RUN ldconfig

# Prepare SLURM directorys
RUN mkdir -p /opt/var/spool/slurm/ && \
    chown slurm -R /opt/var/spool/slurm/ && \
    chmod -R 0755 /opt/var/spool/slurm/ && \
    mkdir -p /opt/var/log/slurm/ && \
    chown slurm -R /opt/var/log/slurm/ && \
    chmod -R 0755 /opt/var/log/slurm/ && \
    mkdir -p /opt/var/run/slurm/ && \
    chown slurm -R /opt/var/run/slurm/ && \
    chmod -R 0755 /opt/var/run/slurm/ && \

# Prepare munge directorys
# etc
RUN dd if=/dev/urandom bs=1 count=1024 > /opt/etc/munge/munge.key && \
    chmod -R 0000 /opt/etc/munge && \
    chmod -R u+rwX /opt/etc/munge && \
    chown -R munge:munge /opt/etc/munge && \
    mkdir -p /opt/var/lib/munge && \
    chown -R munge:munge /opt/var/lib/munge && \
    chmod -R 0711 /opt/var/lib/munge && \
    mkdir -p /opt/var/log/munge && \
    chown -R munge:munge /opt/var/log/munge && \
    chmod -R 0700 /opt/var/log/munge && \
    mkdir -p /opt/var/run/munge && \
    chown -R munge /opt/var/run/munge && \
    chmod -R 0755 /opt/var/run/munge
