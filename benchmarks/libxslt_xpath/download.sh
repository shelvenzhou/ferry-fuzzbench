#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/xpath_posix.c

pushd $SOURCE_PATH

if [ ! -d "libxslt/libxslt" ]
then
    git clone --depth 1 https://gitlab.gnome.org/GNOME/libxml2.git libxslt/libxml2
    git clone --depth 1 https://gitlab.gnome.org/GNOME/libxslt.git libxslt/libxslt

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH libxslt/libxslt/tests/fuzz/xpath.c
    fi
fi

popd
