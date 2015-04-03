# Create image containing SLURM-ready system
# You'll need to install fresh SLURM
# and decide what role this container will play
# (frontend node or compute node)

FROM artpol/cluster_base
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Call slurmctld
CMD su - slurm -c "/sbin/slurmd -f /etc/slurm/slurm.conf -L /var/log/slurm/slurmd.log"

