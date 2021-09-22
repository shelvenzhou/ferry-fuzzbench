#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/target.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/target_posix.cc

pushd $SOURCE_PATH

if [ ! -d "libpng" ]
then
    wget https://downloads.sourceforge.net/project/libpng/libpng12/older-releases/1.2.56/libpng-1.2.56.tar.gz
    tar xf libpng-1.2.56.tar.gz
    rm libpng-1.2.56.tar.gz

    mv libpng-1.2.56 libpng

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH libpng/target.cc
    else
        cp $TARGET_PATH libpng/target.cc
    fi
fi

popd
