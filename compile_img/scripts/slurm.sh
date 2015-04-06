#!/bin/bash -xEe

prepare_slurm()
{
    # Should stay
    cd $SLURM_SRC
    git checkout pmix-new

    export ACLOCAL_FLAGS='-I /usr/share/aclocal'
    ./autogen.sh
}

build_slurm()
{
    mkdir $SLURM_BUILD
    cd $SLURM_BUILD
    CONF_OPTS="--prefix=$SLURM_INSTALL --with-pmix=$PMIX_INSTALL --with-munge=$MUNGE_INSTALL"
    $SLURM_SRC/configure $CONF_OPTS
    make
    make install
    cd $JNKNS_TOPDIR
}