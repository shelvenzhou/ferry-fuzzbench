#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/standard_fuzzer_posix.cpp

pushd $SOURCE_PATH

if [ ! -d "proj4" ]
then
    git clone https://github.com/OSGeo/PROJ proj4

    cd proj4
    git checkout d00501750b210a73f9fb107ac97a683d4e3d8e7a
    cd ..

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH proj4/test/fuzzers/standard_fuzzer.cpp
    fi
fi

popd
