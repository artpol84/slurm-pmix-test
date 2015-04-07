#!/bin/bash -lxeE

get_my_IP()
{
    ifconfig eth0 | grep "inet addr" | awk '{ print $2 }' | awk 'BEGIN { FS = ":" } ; { print $2 }'
}

export_my_IP() 
{
    IP=`get_my_IP`
    echo "$IP" > $1
    while [ -f $FNAME ]; do
        # wait until our host appears in /etc/hosts
        # use echo as a short delay
        echo "1" > /dev/null
    done
}
