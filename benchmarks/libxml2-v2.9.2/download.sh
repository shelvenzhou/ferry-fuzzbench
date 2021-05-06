#!/bin/bash -ex

TARGET_PATH=$(realpath target.cc)

pushd $SOURCE_PATH

if [ ! -d "libxml2" ]
then
git clone https://gitlab.gnome.org/GNOME/libxml2.git
cp $TARGET_PATH libxml2
fi

popd
