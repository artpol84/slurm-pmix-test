#!/bin/bash -lxeE

# Keep in sync with slurm.conf SlurmctldPort
SLURM_PORT=6817

init_run_lib()
{
    LIB_AUX_DIR=./files
    LIB_RUN_DIR=./rundir

    if [ -n "$1" ]; then
        LIB_AUX_DIR=$1
    fi
    shift
    if [ -n "$1" ]; then
        LIB_RUN_DIR=$1
    fi

    if [ ! -d $LIB_RUN_DIR ]; then
        mkdir -p $LIB_RUN_DIR
        if [ "$?" -ne 0 ]; then
            echo "Cant create $LIB_RUN_DIR"
            exit 1
        fi
    fi
    CIDS_FILE=$LIB_RUN_DIR/container_cids
    rm -f $CIDS_FILE
}

have_full_IP()
{
    tmp=`echo $1 | awk -F "." '{ print NF }'`
    if [ "$tmp" -eq 4 ]; then
        echo "OK"
    else
        echo "ERROR, bad IP"
    fi
}

release_machine()
{
    HNAME=$1
    LPATH=$LIB_RUN_DIR/map.$2
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
    echo -e "$IP\t$HNAME" >> $LIB_RUN_DIR/hosts
    cat /dev/null > $LPATH
}

setup_ctl_port()
{
    CID=`cat $LIB_RUN_DIR/tmp.cid`
    PORT_MAP=`docker port $CID`
    PORT=`echo $PORT_MAP | awk '{ print $3 }' | awk -F ":" '{ print $2 }'`

    if [ -z "$PORT" ]; then
        echo "Cannot extract frontend port mapping information"
        exit 1
    fi

    cat $LIB_AUX_DIR/slurm.conf.in | \
        sed -e "s/SlurmctldPort=xxxx/SlurmctldPort=$PORT/" \
        > $LIB_RUN_DIR/slurm.conf
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
    TYPE=$1

    LPATH=$LIB_RUN_DIR/map.$IP_NUM
    VPATH=/host-to-IP-map.$IP_NUM
    rm -f $LPATH
    touch $LPATH
    if [ "$TYPE" = "frontend" ]; then
        APPEND_PARAM="--expose=$SLURM_PORT -P"
    else
        APPEND_PARAM=""
    fi
    docker run -dti --hostname="$HNAME" \
            --cidfile=$LIB_RUN_DIR/tmp.cid \
            -v $LIB_RUN_DIR/hosts:/etc/hosts \
            -v $LPATH:$VPATH \
            -v $LIB_RUN_DIR/shared:/shared \
            $APPEND_PARAM \
            $IMG_NAME \
            $RUN_CMD /host-to-IP-map.$IP_NUM
    cat $LIB_RUN_DIR/tmp.cid >> $CIDS_FILE
    echo >> $CIDS_FILE
    if [ "$TYPE" = "frontend" ]; then
        setup_ctl_port `cat $LIB_RUN_DIR/tmp.cid`
        release_machine $HNAME $IP_NUM
    fi
    rm $LIB_RUN_DIR/tmp.cid
}


# Running the tests

count_test_num()
{
    ls -1 $LIB_AUX_DIR | grep "^[0-9][0-9]_.*\.job\.in" | wc -l
}

wait_for_job()
{
    JOBID=$1
    # Constantly checking job state while job disappears or
    # unexpected state will be discovered
    state=`$SQUEUE -j $JOBID -o "%t" 2>/dev/null | head -n2 | tail -n1`
    while [ -n "$state" ]; do
        if [ "$state" = "PD" ] || [ "$state" = "R" ] || \
           [ "$state" = "CG" ] || [ "$state" = "CD" ]; then
            state=`$SQUEUE -j $JOBID -o "%t" 2>/dev/null | \
                   awk 'BEGIN{ cnt=0; } { if ( cnt == 1 ){ print $1; }; cnt++; }'`
            sleep 0.1
            continue
        fi
        echo "BAD job state!"
        exit 1
    done
}


run_test_num()
{
    NODES=$1
    NUM=$2
    if [ "$NUM" -lt 10 ]; then
        NUM=0$NUM
    fi
    WORKING_DIR=$LIB_RUN_DIR/shared

    # Prepare task files
    test_name=`ls -1 $LIB_AUX_DIR | grep "${NUM}_.*\.job\.in"`
    test_name=${test_name%".job.in"}
    CORES=`cat /proc/cpuinfo | grep 'core id' | uniq | wc -l`
    cat $LIB_AUX_DIR/${test_name}.job.in | \
        sed -e "s/--nodes=xxxx/--nodes=$NODES/" | \
        sed -e "s/--ntasks-per-node=yyyy/--ntasks-per-node=$CORES/" \
        > $WORKING_DIR/${test_name}.job 

    if [ -f "$LIB_AUX_DIR/${test_name}.sh" ]; then
        cp $LIB_AUX_DIR/${test_name}.sh $WORKING_DIR
    fi

    # Submit the job
    export PMIX_TEST_OUTPREFIX="${test_name}"
    # We need to change working dir (-D option) because
    # virtual nodes have different FS layout
    SUBMIT_STR=`$SBATCH -D /shared/ $WORKING_DIR/${test_name}.job`
    JOBID=`echo $SUBMIT_STR | awk '{ print $4 }'`
    if [ -z "$JOBID" ]; then
        echo "ERROR submitting the job"
        exit 1
    fi

    # Wait for a job
    wait_for_job $JOBID

    # Check task result
    if [ ! -f "$WORKING_DIR/${test_name}.count" ]; then
        echo "ERROR running \"${test_name}\" test"
        cat $WORKING_DIR/slurm-$JOBID.out
        exit 1
    fi
    flag=0
    count=`cat $WORKING_DIR/${test_name}.count`
    count=`expr $count - 1`
    for i in `seq 1 $count`; do
        if [ ! -f "$WORKING_DIR/${test_name}.$i" ]; then
            echo "ERROR running \"${test_name}\" test. $WORKING_DIR/${test_name}.$i Not found"
            flag=1
        fi
        rank_result=`cat $WORKING_DIR/${test_name}.$i`
        if [ ! "$rank_result" = "OK" ]; then
            echo "ERROR running \"${test_name}\" test. $WORKING_DIR/${test_name}.$i != OK"
            cat $WORKING_DIR/${test_name}.$i
            flag=1
        fi
    done

    if [ "$flag" -eq 1 ]; then
        cat $WORKING_DIR/slurm-$JOBID.out
        exit 1
    fi
    # Cleanup after ourselfs
    rm -f $WORKING_DIR/${test_name}.*
    rm -f $WORKING_DIR/slurm-$JOBID.out
}

run_cleanup()
{
    for i in `cat $CIDS_FILE`; do
        docker kill $i
        docker rm $i
    done
}