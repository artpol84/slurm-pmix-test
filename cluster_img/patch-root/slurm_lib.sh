#!/bin/bash -lxeE

get_my_IP()
{
    ifconfig eth0 | grep "inet addr" | awk '{ print $2 }' | awk 'BEGIN { FS = ":" } ; { print $2 }'
}

export_my_IP() 
{
    FNAME=$1
    IP=`get_my_IP`
    echo "$IP" > $FNAME
    LCOUNT=1
    while [ "$LCOUNT" -eq 1 ]; do
        # wait until our host appears in /etc/hosts
        # use echo as a short delay
        LCOUNT=`cat $FNAME | wc -l`
    done
}
