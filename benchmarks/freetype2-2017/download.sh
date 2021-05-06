#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "freetype2" ]
then
git clone git://git.sv.nongnu.org/freetype/freetype2.git
wget https://github.com/libarchive/libarchive/releases/download/v3.4.3/libarchive-3.4.3.tar.xz
tar xf libarchive-3.4.3.tar.xz
rm libarchive-3.4.3.tar.xz
fi

popd
