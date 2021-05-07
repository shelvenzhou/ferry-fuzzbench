#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/target.cc

pushd $SOURCE_PATH

if [ ! -d "re2" ]
then
git clone https://github.com/google/re2.git
cp $TARGET_PATH re2
fi

popd
