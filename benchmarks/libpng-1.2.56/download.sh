#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/target.cc

pushd $SOURCE_PATH

if [ ! -d "libpng-1.2.56" ]
then
wget https://downloads.sourceforge.net/project/libpng/libpng12/older-releases/1.2.56/libpng-1.2.56.tar.gz
tar xf libpng-1.2.56.tar.gz
rm libpng-1.2.56.tar.gz
cp $TARGET_PATH libpng-1.2.56
fi

popd
