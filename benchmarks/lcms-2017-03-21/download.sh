#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/cms_transform_fuzzer.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/cms_transform_fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "lcms" ]
then
    git clone https://github.com/mm2/Little-CMS.git lcms

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH lcms/cms_transform_fuzzer.cc
    else
        cp $TARGET_PATH lcms/cms_transform_fuzzer.cc
    fi
fi

popd
