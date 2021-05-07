#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "vorbis" ]
then
git clone https://github.com/xiph/ogg.git
git clone https://github.com/xiph/vorbis.git
wget -qO vorbis/decode_fuzzer.cc \
    https://raw.githubusercontent.com/google/oss-fuzz/688aadaf44499ddada755562109e5ca5eb3c5662/projects/vorbis/decode_fuzzer.cc
fi

popd
