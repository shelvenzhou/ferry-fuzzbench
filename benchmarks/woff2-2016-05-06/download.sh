#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/target.cc

pushd $SOURCE_PATH

if [ ! -d "woff2" ]
then
git clone https://github.com/google/woff2.git
git clone https://github.com/google/brotli.git
cp $TARGET_PATH woff2
fi

popd
