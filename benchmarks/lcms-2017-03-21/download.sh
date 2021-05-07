#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/cms_transform_fuzzer.cc

pushd $SOURCE_PATH

if [ ! -d "Little-CMS" ]
then
git clone https://github.com/mm2/Little-CMS.git
cp $TARGET_PATH Little-CMS
fi

popd
