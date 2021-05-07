#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "bloaty" ]
then
git clone --depth 1 https://github.com/google/bloaty.git bloaty
fi

popd
