#!/bin/bash

have_full_IP()
{
    tmp=`cat $1 | awk -F "." '{ print NF }`
    if [ "$tmp" -eq 4 ]; then
        echo "OK"
    else
        echo "ERROR"
    fi
}

run_machine()
{
    img_name=$1
    shift
    hname=$1
    shift
    ip_num=$1
    shift
    run_cmd=$1
    shift
    apply=$1

    lpath=`pwd`/map.$ip_num
    vpath=/host-to-IP-map.$ip_num
    rm -f $lpath
    touch $lpath
    docker run -ti --hostname="$hname" \
           -v `pwd`/hosts:/etc/hosts -v $lpath:$vpath \
           $img_name $run_cmd /host-to-IP-map.$ip_num

    if [ -n "$apply" ]; then
        LCOUNT=0
        while [ "$LCOUNT" -eq 0 ]; do
            LCOUNT=`cat $lpath | wc -l`
        done
        ip=`cat $lpath`
        chk=`have_full_IP $ip`
        if [ "$chk" != "OK" ]; then
            echo "Received bad IP from container"
            exit 1
        fi
    fi
}
