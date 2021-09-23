#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/set_eval_fuzzer.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/set_eval_fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "muparser" ]
then
    git clone https://github.com/beltoforion/muparser.git muparser

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH muparser/set_eval_fuzzer.cc
    else
        cp $TARGET_PATH muparser/set_eval_fuzzer.cc
    fi
fi

popd
