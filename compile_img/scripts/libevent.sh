#!/bin/bash -xEe

build_libevent()
{
    local CONF_OPTS
    cd $JNKNS_SOURCE_DIR
    wget ${LIBEV_URL}
    tar -xzvf $LIBEV_TAR
    mkdir $LIBEV_BUILD
    cd $LIBEV_BUILD
    CONF_OPTS="--disable-dns --disable-http --disable-rpc \
               --disable-openssl --enable-thread-support \
               --disable-evport --prefix=$LIBEV_INSTALL"
    $LIBEV_SRC/configure $CONF_OPTS
    make
    make install
    cd $JNKNS_TOPDIR
}