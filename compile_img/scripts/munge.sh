#!/bin/bash -xEe

build_munge()
{
    # get the sources
    cd $JNKNS_SOURCE_DIR
    wget ${MUNGE_URL}
    tar -xjvf ${MUNGE_TAR}

    # patch them
    cd $MUNGE_SRC
    patch -p1 < $JNKNS_SOURCE_DIR/munge-0.5.11_prefix_install.patch

    # build
    mkdir $MUNGE_BUILD
    cd $MUNGE_BUILD
    CONF_OPTS="--prefix=$MUNGE_INSTALL"
    $MUNGE_SRC/configure $CONF_OPTS
    make
    make install
    cd $JNKNS_TOPDIR
}