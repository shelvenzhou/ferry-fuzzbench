#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/hb-fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "harfbuzz" ]
then
    git clone https://github.com/behdad/harfbuzz.git

    cd harfbuzz
    git checkout f73a87d9a8c76a181794b74b527ea268048f78e3
    cd ..

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH harfbuzz/test/fuzzing/hb-fuzzer.cc
    fi
fi

popd
