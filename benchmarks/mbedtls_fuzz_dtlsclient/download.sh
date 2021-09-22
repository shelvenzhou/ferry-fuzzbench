#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "mbedtls" ]
then
    git clone --recursive https://github.com/ARMmbed/mbedtls.git mbedtls
    # git clone --depth 1 https://github.com/google/boringssl.git boringssl
    # git clone --depth 1 https://github.com/openssl/openssl.git openssl
    git clone https://github.com/ARMmbed/mbed-crypto mbedtls/crypto
fi

popd
