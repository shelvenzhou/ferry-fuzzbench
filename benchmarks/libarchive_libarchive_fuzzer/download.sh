#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/libarchive_fuzzer.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/libarchive_fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "libarchive" ]
then
    git clone --depth 1 https://github.com/libarchive/libarchive.git libarchive

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH libarchive/libarchive_fuzzer.cc
    else
        cp $TARGET_PATH libarchive/libarchive_fuzzer.cc
    fi
fi

popd
