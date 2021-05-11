#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/zlib_uncompress_fuzzer.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/zlib_uncompress_fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "zlib" ]
then
    git clone --depth 1 -b develop https://github.com/madler/zlib.git

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH zlib/zlib_uncompress_fuzzer.cc
    else
        cp $TARGET_PATH zlib/zlib_uncompress_fuzzer.cc
    fi
fi

popd
