#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/cms_transform_fuzzer.cc
POSIX_TARGET_PATH=$(dirname $(realpath $0))/cms_transform_fuzzer_posix.cc

pushd $SOURCE_PATH

if [ ! -d "Little-CMS" ]
then
    git clone https://github.com/mm2/Little-CMS.git

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH Little-CMS/cms_transform_fuzzer.cc
    else
        cp $TARGET_PATH Little-CMS/cms_transform_fuzzer.cc
    fi
fi

popd
