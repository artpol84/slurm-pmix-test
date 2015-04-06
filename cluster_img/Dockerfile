FROM debian
MAINTAINER Artem Polyakov <artemp@mellanox.com>

RUN apt-get update && \
    apt-get install -y bzip2 && \
    apt-get install -y libssl1.0.0 && \
    apt-get install -y procps 
#    apt-get install -y mc


# Compile packages to be tested
ADD root.tar.bz2 /

# Add users for SLURM and munge
RUN useradd slurm
RUN useradd munge

# Add cluster user
RUN useradd -m cuser

# Prepare SLURM directorys
COPY patch-root/ /opt/
RUN mkdir -p /opt/var/spool/slurm/
RUN chown slurm -R /opt/var/spool/slurm/
RUN chmod -R 0755 /opt/var/spool/slurm/
RUN mkdir -p /opt/var/log/slurm/
RUN chown slurm -R /opt/var/log/slurm/

# Prepare munge directorys
# etc
RUN dd if=/dev/urandom bs=1 count=1024 > /opt/etc/munge/munge.key
RUN chmod -R 0000 /opt/etc/munge
RUN chmod -R u+rwX /opt/etc/munge
RUN chown -R munge:munge /opt/etc/munge

# /var/lib/munge/
RUN mkdir -p /opt/var/lib/munge
RUN chown -R munge:munge /opt/var/lib/munge
RUN chmod -R 0711 /opt/var/lib/munge

# /var/log/munge
RUN mkdir -p /opt/var/log/munge
RUN chown -R munge:munge /opt/var/log/munge
RUN chmod -R 0700 /opt/var/log/munge

# /var/run/munge
RUN mkdir -p /opt/var/run/munge
RUN chown -R munge /opt/var/run/munge
RUN chmod -R 0755 /opt/var/run/munge
