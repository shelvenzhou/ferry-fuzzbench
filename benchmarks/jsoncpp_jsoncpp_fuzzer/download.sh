#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/fuzz_posix.cpp
POSIX_HEADER_PATH=$(dirname $(realpath $0))/fuzz_posix.h

pushd $SOURCE_PATH

if [ ! -d "jsoncpp" ]
then
    git clone --depth 1 https://github.com/open-source-parsers/jsoncpp

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH jsoncpp/src/test_lib_json/fuzz.cpp
        cp $POSIX_HEADER_PATH jsoncpp/src/test_lib_json/fuzz.h
    fi

fi

popd
