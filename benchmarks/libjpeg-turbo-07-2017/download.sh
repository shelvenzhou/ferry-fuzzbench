#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/libjpeg_turbo_fuzzer.cc

pushd $SOURCE_PATH

if [ ! -d "libjpeg-turbo" ]
then
git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
cp $TARGET_PATH libjpeg-turbo
fi

popd
