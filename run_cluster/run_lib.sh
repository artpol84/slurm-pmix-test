#!/bin/bash

init_run_lib()
{
    if [ -n "$1" ]; then
        LIB_RUNTIME_DIR=$1
    else
        LIB_RUNTIME_DIR=./rundir
    fi
    if [ ! -d $LIB_RUNTIME_DIR ]; then
        mkdir -p $LIB_RUNTIME_DIR
        if [ "$?" -ne 0 ]; then
            echo "Cant create $LIB_RUNTIME_DIR"
            exit 1
        fi
    fi
    CIDS_FILE=$LIB_RUNTIME_DIR/container_cids
    rm -f $CIDS_FILE
}

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
    LPATH=$LIB_RUNTIME_DIR/map.$2
    LCOUNT=0
    while [ "$LCOUNT" -eq 0 ]; do
        LCOUNT=`cat $LPATH | wc -l`
    done
    IP=`cat $LPATH`
    CHECK=`have_full_IP $IP`
    if [ "$CHECK" != "OK" ]; then
        echo "Received bad IP from container"
        exit 1
    fi
    echo -e "$IP\t$HNAME" >> $LIB_RUNTIME_DIR/hosts
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

    LPATH=$LIB_RUNTIME_DIR/map.$IP_NUM
    VPATH=/host-to-IP-map.$IP_NUM
    rm -f $LPATH
    touch $LPATH
    docker run -dti --hostname="$HNAME" \
            --cidfile=$LIB_RUNTIME_DIR/tmp.cid \
            -v $LIB_RUNTIME_DIR/hosts:/etc/hosts \
            -v $LPATH:$VPATH \
            -v $LIB_RUNTIME_DIR/shared:/shared \
            $IMG_NAME \
            $RUN_CMD /host-to-IP-map.$IP_NUM
    cat $LIB_RUNTIME_DIR/tmp.cid >> $CIDS_FILE
    echo >> $CIDS_FILE
    rm $LIB_RUNTIME_DIR/tmp.cid

    if [ -n "$APPLY" ]; then
        release_machine $HNAME $IP_NUM
    fi
}
