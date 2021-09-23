#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/hevc_dec_fuzzer_posix.cpp

pushd $SOURCE_PATH

if [ ! -d "libhevc" ]
then
    git clone https://android.googlesource.com/platform/external/libhevc libhevc

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH libhevc/fuzzer/hevc_dec_fuzzer.cpp
    fi
fi

popd
