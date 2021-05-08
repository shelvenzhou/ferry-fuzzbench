#!/bin/bash -ex

TARGET_PATH=$(dirname $(realpath $0))/patch.diff

pushd $SOURCE_PATH

if [ ! -d "libpcap" ]
then
git clone --depth 1 https://github.com/the-tcpdump-group/libpcap.git libpcap
# # for corpus as wireshark
# git clone --depth=1 https://github.com/the-tcpdump-group/tcpdump.git tcpdump
# cp $TARGET_PATH libpcap
fi

popd
