#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "harfbuzz" ]
then
git clone https://github.com/behdad/harfbuzz.git
fi

popd
