#!/bin/bash -ex

PATCH_PATH=$(dirname $(realpath $0))/patch.diff
POSIX_TARGET_PATH=$(dirname $(realpath $0))/fuzz_both_posix.c

pushd $SOURCE_PATH

if [ ! -d "libpcap" ]
then
    git clone --depth 1 https://github.com/the-tcpdump-group/libpcap.git libpcap
    # # for corpus as wireshark
    # git clone --depth=1 https://github.com/the-tcpdump-group/tcpdump.git tcpdump
    # cp $PATCH_PATH libpcap

    # if [ -v USE_POSIX_TARGET ]
    # then
    #     cp $POSIX_TARGET_PATH libpcap/testprogs/fuzz/fuzz_both.c
    # fi
fi

popd
