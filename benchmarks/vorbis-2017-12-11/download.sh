#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/decode_fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "vorbis" ]
then
    git clone https://github.com/xiph/ogg.git
    git clone https://github.com/xiph/vorbis.git

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH vorbis/decode_fuzzer.cc
    else
        wget -qO vorbis/decode_fuzzer.cc \
            https://raw.githubusercontent.com/google/oss-fuzz/688aadaf44499ddada755562109e5ca5eb3c5662/projects/vorbis/decode_fuzzer.cc
    fi
fi

popd
