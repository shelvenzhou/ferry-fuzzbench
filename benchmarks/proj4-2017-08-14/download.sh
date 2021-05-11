#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/standard_fuzzer_posix.cpp

pushd $SOURCE_PATH

if [ ! -d "PROJ" ]
then
    git clone https://github.com/OSGeo/PROJ

    cd PROJ
    git checkout d00501750b210a73f9fb107ac97a683d4e3d8e7a
    cd ..

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH PROJ/test/fuzzers/standard_fuzzer.cpp
    fi
fi

popd
