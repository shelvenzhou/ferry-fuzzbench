#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "vorbis" ]
then
git clone https://github.com/xiph/ogg.git
git clone https://github.com/xiph/vorbis.git
fi

popd
