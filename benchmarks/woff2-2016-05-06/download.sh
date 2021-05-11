#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/target.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/target_posix.cc

pushd $SOURCE_PATH

if [ ! -d "woff2" ]
then
    git clone https://github.com/google/woff2.git
    git clone https://github.com/google/brotli.git

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH woff2/target.cc
    else
        cp $TARGET_PATH woff2/target.cc
    fi
fi

popd
