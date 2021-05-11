#!/bin/bash -ex

POSIX_TARGET_PATH=$(dirname $(realpath $0))/ip6_send_posix.cpp
POSIX_TARGET2_PATH=$(dirname $(realpath $0))/cli_uart_received_posix.cpp
POSIX_TARGET3_PATH=$(dirname $(realpath $0))/ncp_uart_received_posix.cpp
POSIX_TARGET4_PATH=$(dirname $(realpath $0))/radio_receive_done_posix.cpp

pushd $SOURCE_PATH

if [ ! -d "openthread" ]
then
    git clone https://github.com/openthread/openthread.git

    cd openthread
    # we use `reset` install of `checkout` since the .gitattribute file of openthread
    # will cause the repo to be modified immediately after get cloned
    git reset --hard 5b0af03afb8e70e8216f69623bd18bcd3d4b8b43
    cd ..

    if [ -v USE_POSIX_TARGET ]
    then
        cp $POSIX_TARGET_PATH openthread/tests/fuzz/ip6_send.cpp
        cp $POSIX_TARGET2_PATH openthread/tests/fuzz/cli_uart_received.cpp
        cp $POSIX_TARGET3_PATH openthread/tests/fuzz/ncp_uart_received.cpp
        cp $POSIX_TARGET4_PATH openthread/tests/fuzz/radio_receive_done.cpp
    fi
fi

popd
