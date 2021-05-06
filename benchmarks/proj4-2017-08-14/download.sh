#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "PROJ" ]
then
git clone https://github.com/OSGeo/PROJ
fi

popd
