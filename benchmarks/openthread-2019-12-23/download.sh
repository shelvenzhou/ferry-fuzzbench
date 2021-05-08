#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "openthread" ]
then
git clone https://github.com/openthread/openthread.git
fi

popd
