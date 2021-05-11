#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/ftfuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "freetype2" ]
then
    git clone git://git.sv.nongnu.org/freetype/freetype2.git
    wget https://github.com/libarchive/libarchive/releases/download/v3.4.3/libarchive-3.4.3.tar.xz
    tar xf libarchive-3.4.3.tar.xz
    rm libarchive-3.4.3.tar.xz

    cd freetype2
    git checkout cd02d359a6d0455e9d16b87bf9665961c4699538
    cd ..

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH freetype2/src/tools/ftfuzzer/ftfuzzer.cc
    fi
fi

popd
