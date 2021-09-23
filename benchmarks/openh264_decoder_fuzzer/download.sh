#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/decoder_fuzzer.cpp
POSIX_TARGET_PATH=$(dirname $(realpath $0))/decoder_fuzzer_posix.cpp

pushd $SOURCE_PATH

if [ ! -d "openh264" ]
then
    git clone --depth 1 https://github.com/cisco/openh264.git openh264

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH openh264/decoder_fuzzer.cpp
    else
        cp $TARGET_PATH openh264/decoder_fuzzer.cpp
    fi
fi

popd
