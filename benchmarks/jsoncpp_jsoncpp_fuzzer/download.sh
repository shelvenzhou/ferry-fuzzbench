#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "jsoncpp" ]
then
git clone --depth 1 https://github.com/open-source-parsers/jsoncpp
fi

popd
