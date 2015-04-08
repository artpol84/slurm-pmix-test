#!/bin/bash

have_full_IP()
{
    tmp=`echo $1 | awk -F "." '{ print NF }'`
    if [ "$tmp" -eq 4 ]; then
        echo "OK"
    else
        echo "ERROR"
    fi
}

release_machine()
{
    HNAME=$1
    LPATH=`pwd`/map.$2
    LCOUNT=0
    while [ "$LCOUNT" -eq 0 ]; do
        LCOUNT=`cat $lpath | wc -l`
    done
    IP=`cat $LPATH`
    CHECK=`have_full_IP $IP`
    if [ "$CHECK" != "OK" ]; then
        echo "Received bad IP from container"
        exit 1
    fi
    echo -e "$IP\t$HNAME" >> hosts
    cat /dev/null > $LPATH
}

run_machine()
{
    IMG_NAME=$1
    shift
    HNAME=$1
    shift
    IP_NUM=$1
    shift
    RUN_CMD=$1
    shift
    APPLY=$1

    LPATH=`pwd`/map.$IP_NUM
    VPATH=/host-to-IP-map.$IP_NUM
    rm -f $LPATH
    touch $LPATH
    docker run -dti --hostname="$HNAME" \
           -v `pwd`/hosts:/etc/hosts \
           -v $LPATH:$VPATH \
           -v `pwd`/shared:/shared \
           $IMG_NAME \
           $RUN_CMD /host-to-IP-map.$IP_NUM

    if [ -n "$APPLY" ]; then
        release_machine $LPATH $HNAME.
    fi
}
