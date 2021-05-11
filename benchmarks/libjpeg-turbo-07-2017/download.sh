#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/libjpeg_turbo_fuzzer.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/libjpeg_turbo_fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "libjpeg-turbo" ]
then
    git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH libjpeg-turbo/libjpeg_turbo_fuzzer.cc
    else
        cp $TARGET_PATH libjpeg-turbo/libjpeg_turbo_fuzzer.cc
    fi
fi

popd
