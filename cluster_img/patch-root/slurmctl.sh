#!/bin/bash -lxeE

. slurm_lib.sh
FNAME=$1
export_my_IP $FNAME

/opt/etc/init.d/munge start
slurmctld -f /opt/etc/slurm.conf -L/opt/var/log/slurm/slurmctld.log
/bin/bash -l