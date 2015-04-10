#!/bin/bash -eEx

INSTALL_DIR=$1
BASE_DIR=`pwd`
WORK_DIR=$BASE_DIR/workdir/
SOURCE_DIR=$WORK_DIR/src
BUILD_DIR=$WORK_DIR/build
PREP_TOOLS=$WORK_DIR/prep_dir
PREP_TOOLS_INST=$PREP_TOOLS/install/

rm -Rf $WORK_DIR
mkdir -p $WORK_DIR
mkdir -p $BUILD_DIR
mkdir -p $SOURCE_DIR
mkdir -p $PREP_TOOLS

# Keep in sync with "compile_img/scripts/config.sh"
# TODO: make a shared setting somehow
MUNGE_VER="0.5.11"
MUNGE_NAME=munge-${MUNGE_VER}
MUNGE_TAR=$MUNGE_NAME.tar.bz2
MUNGE_URL=https://munge.googlecode.com/files/$MUNGE_TAR
MUNGE_SRC="$SOURCE_DIR/$MUNGE_NAME"
MUNGE_BUILD="$BUILD_DIR/$MUNGE_NAME"
MUNGE_INSTALL="$INSTALL_DIR/"

# SLURM package
SLURM_BRANCH=pmix-new
SLURM_ZIP="$SLURM_BRANCH.zip"
SLURM_URL="https://github.com/artpol84/slurm/archive/$SLURM_ZIP"
SLURM_SRC="$SOURCE_DIR/slurm-$SLURM_BRANCH"
SLURM_BUILD="$BUILD_DIR/slurm-$SLURM_BRANCH/"
SLURM_INSTALL="$INSTALL_DIR/"



build_prepare_tools()
{
    cd prepare_tools
    ./prepare.sh $PREP_TOOLS
    cd $BASE_DIR
}

build_munge()
{
    # get the sources
    cd $SOURCE_DIR
    wget ${MUNGE_URL}
    tar -xjvf ${MUNGE_TAR}

    # patch them
    cd $MUNGE_SRC
    patch -p1 < $BASE_DIR/munge-0.5.11_prefix_install.patch

    # build
    mkdir -p $MUNGE_BUILD
    cd $MUNGE_BUILD
    CONF_OPTS="--prefix=$MUNGE_INSTALL"
    $MUNGE_SRC/configure $CONF_OPTS
    make
    make install
    cd $BASE_DIR
}

prepare_slurm()
{
    # Should stay
    cd $SOURCE_DIR
    wget $SLURM_URL
    unzip $SLURM_ZIP
    cd $SLURM_SRC
    export PATH=$PREP_TOOLS_INST/bin:$PATH
    export LD_LIBRARY_PATH=$PREP_TOOLS_INST/lib:$LD_LIBRARY_PATH
    export ACLOCAL_FLAGS='-I /usr/share/aclocal'
    ./autogen.sh
    rm -R $PREP_TOOLS_INST
}

build_slurm()
{
    mkdir $SLURM_BUILD
    cd $SLURM_BUILD
    CONF_OPTS="--prefix=$SLURM_INSTALL --with-munge=$MUNGE_INSTALL --with-hdf5=no"
    $SLURM_SRC/configure $CONF_OPTS
    make
    make install
    cd $BASE_DIR
    cp ./munge.key $MUNGE_INSTALL/etc/munge/
}

build_prepare_tools
build_munge
prepare_slurm
build_slurm
