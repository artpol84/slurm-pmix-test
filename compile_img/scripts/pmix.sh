#!/bin/bash -xEe

build_pmix()
{
    cd $JNKNS_SOURCE_DIR
    if [ -d $PMIX_SRC ]; then
        rm -Rf "$PMIX_SRC"
    fi
    git clone ${PMIX_GIT_URL}
    cd $PMIX_SRC
    ./autogen.sh
    mkdir $PMIX_BUILD
    cd $PMIX_BUILD
    CONF_OPTS="--prefix=$PMIX_INSTALL --with-libevent=$LIBEV_INSTALL"
    $PMIX_SRC/configure $CONF_OPTS
    make
    make install
    cd $JNKNS_TOPDIR
}