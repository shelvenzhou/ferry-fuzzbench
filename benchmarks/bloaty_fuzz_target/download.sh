#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/fuzz_target_posix.cc

pushd $SOURCE_PATH

if [ ! -d "bloaty" ]
then
    git clone --depth 1 https://github.com/google/bloaty.git bloaty

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH bloaty/tests/fuzz_target.cc
    fi
fi

popd
