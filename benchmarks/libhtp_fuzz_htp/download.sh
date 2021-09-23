#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/fuzz_htp_posix.c

pushd $SOURCE_PATH

if [ ! -d "libhtp" ]
then
    git clone https://github.com/OISF/libhtp.git libhtp

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH libhtp/test/fuzz/fuzz_htp.c
    fi
fi

popd
