#!/bin/bash -xeE

TOOLS_BASE_PATH=$1

. ./env.sh

rm -Rf $DISTR_PATH
mkdir -p $DISTR_PATH

wget -P $DISTR_PATH $M4_URL
wget -P $DISTR_PATH $AUTOCONF_URL
wget -P $DISTR_PATH $AUTOMAKE_URL
wget -P $DISTR_PATH $LIBTOOL_URL
wget -P $DISTR_PATH $FLEX_URL 
mv $DISTR_PATH/download $DISTR_PATH/$FLEX_DISTR


# Use as much processors 
# as we can to speedup
NPROC=`nproc`
MAKE_JOBS=`expr $NPROC \* 2`
export MAKE_JOBS=$MAKE_JOBS

. ./env.sh

rm -Rf $SRC_PATH $PREFIX
mkdir $SRC_PATH

export PATH="$PREFIX/bin/":$PATH
export LD_LIBRARY_PATH="$PREFIX/bin/":$LD_LIBRARY_PATH

tar -xjvf $DISTR_PATH/$M4_DISTR -C $SRC_PATH
cd $SRC_PATH/$M4_NAME
./configure --prefix=$PREFIX
make
make install

tar -xzvf $DISTR_PATH/$AUTOCONF_DISTR -C $SRC_PATH
cd $SRC_PATH/$AUTOCONF_NAME
./configure --prefix=$PREFIX
make
make install

tar -xzvf $DISTR_PATH/$AUTOMAKE_DISTR -C $SRC_PATH
cd $SRC_PATH/$AUTOMAKE_NAME
./configure --prefix=$PREFIX
make
make install

tar -xzvf $DISTR_PATH/$LIBTOOL_DISTR -C $SRC_PATH
cd $SRC_PATH/$LIBTOOL_NAME
./configure --prefix=$PREFIX
make
make install

tar -xjvf $DISTR_PATH/$FLEX_DISTR -C $SRC_PATH
cd $SRC_PATH/$FLEX_NAME
./configure --prefix=$PREFIX
make
make install
