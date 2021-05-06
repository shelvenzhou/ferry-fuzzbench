#!/bin/bash -ex

TARGET_PATH=$(realpath zlib_uncompress_fuzzer.cc)

pushd $SOURCE_PATH

if [ ! -d "zlib" ]
then
git clone --depth 1 -b develop https://github.com/madler/zlib.git
cp $TARGET_PATH zlib
fi

popd
